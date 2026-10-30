extends "res://tests/test_suite.gd"

var game: BattleController

func command_text(from: Node = null) -> String:
	var parts: PackedStringArray = []
	var pending: Array[Node] = [game.ui.commands.command if from == null else from]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		if (node is Label or node is Button) and not node.is_queued_for_deletion():
			parts.append(node.text)
		pending.append_array(node.get_children())
	return " ".join(parts)

func click_world(point: Vector3, double_click: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.position = game.camera.unproject_position(point)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.double_click = double_click
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	event.double_click = false
	root.push_input(event, true)

func aim_world(point: Vector3) -> void:
	var event := InputEventMouseMotion.new()
	event.position = game.camera.unproject_position(point)
	root.push_input(event, true)

func test_movement_gestures() -> void:
	var ace := game.selected
	var start := ace.position
	click_world(Vector3(0, 0, 0))
	await frames(2)
	check(not game.planning.choosing_facing and not game.planning.destination_fixed and ace.order == null, "Clicking an invalid destination never confirms or pins movement")
	check(game.ui.commands.feedback.text.begins_with("INVALID"), "Invalid destination reason is shown")
	game.select_unit(ace)
	var destination := start + ace.forward() * 2
	click_world(Vector3(destination.x, 0, destination.y))
	await frames(2)
	check(game.planning.choosing_facing and ace.order == null, "Single click on a mech destination enters the aim step without ordering")
	check(game.ui.commands.feedback.text.begins_with("AIM"), "Aim step is announced in the command panel")
	check(command_text().contains("Aim · click to lock"), "Command panel shows the numbered order steps")
	var pinned := game.planning.draft.destination
	var enemy := game.manager.battle.units[3]
	click_world(game.actors[enemy.loadout.id].body.global_position + Vector3.UP * 0.5)
	await frames(2)
	check(ace.order == null and game.selected == enemy and not game.planning.choosing_facing, "Clicking another unit while aiming switches selection without confirming")
	game.select_unit(ace)
	check(game.planning.draft.destination.is_equal_approx(pinned), "Returning after aiming restores the pinned destination")
	game.begin_facing()
	var locked := game.planning.draft.destination
	var heading := ace.facing + deg_to_rad(30)
	var aim := locked + Vector2(sin(heading), -cos(heading)) * 2.5
	aim_world(Vector3(aim.x, 0.15 + game.planning.plan_altitude * 1.7, aim.y))
	await frames(2)
	check(is_equal_approx(game.planning.plan_rotation, 30) and game.planning.draft.destination.is_equal_approx(locked), "Mouse rotates airborne preview without moving its destination")
	check(ace.position == start, "Facing preview never moves authoritative unit state")
	var overlay: TargetingOverlay
	for child in game.overlays.get_children():
		if child is TargetingOverlay:
			overlay = child
	check(overlay != null and Vector2(overlay.position.x, overlay.position.z).is_equal_approx(locked), "Planned weapon range follows ghost destination")
	await capture("qa-facing", 2)
	aim_world(Vector3(locked.x, 0.15 + game.planning.plan_altitude * 1.7, locked.y + 3))
	await frames(2)
	check(is_equal_approx(game.planning.plan_rotation, 45), "Mouse facing clamps to Cruise turn limit")
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape, true)
	await frames(2)
	check(not game.planning.choosing_facing and ace.order == null, "Escape returns to destination selection without ordering")
	click_world(Vector3(destination.x, 0, destination.y))
	aim_world(Vector3(aim.x, 0.15 + game.planning.plan_altitude * 1.7, aim.y))
	click_world(Vector3(aim.x, 0.15 + game.planning.plan_altitude * 1.7, aim.y))
	await frames(2)
	check(ace.order != null and ace.order.confirmed and is_equal_approx(rad_to_deg(ace.order.facing - ace.facing), 30), "Next left click locks cursor-facing order")
	check(game.selected != ace and not game.planning.choosing_facing, "Facing confirmation selects the next unordered unit")
	var fighter := game.manager.battle.units[2]
	game.select_unit(fighter)
	await frames(2)
	var options := MovementRules.available(game.manager.battle, fighter).size()
	check(game.ui.flight_radial.radial_items.size() == options and game.planning.option_orders.size() == options, "Aircraft get a radial button and an order for every available flight path")
	var preview: MovementPreview = game.drafts_root.get_child(0)
	var path_lines := preview.get_children().filter(func(node: Node) -> bool: return node is Node3D and not node is Label3D).size()
	var ghost_models := preview.find_children("*", "MeshInstance3D", true, false).filter(func(node: Node) -> bool: return node.mesh is BoxMesh).size()
	check(path_lines >= options and ghost_models == 0, "Aircraft flight paths draw as lines only, with no ghost models")
	var field := game.battle_input.field_point(game.camera.unproject_position(Vector3(fighter.position.x + 1, 0, fighter.position.y)))
	click_world(Vector3(field.x, 0, field.y))
	await frames(2)
	check(fighter.order == null and not game.planning.choosing_facing, "Field clicks never order an aircraft")
	game.set_hover_option("bank_r")
	check(game.planning.hover_option == "bank_r" and game.planning.manoeuvre_id != "bank_r", "Hovering a ring option highlights its ghost without selecting it")
	var bank_left: Button
	for item in game.ui.flight_radial.radial_items:
		if item.order.manoeuvre_id == "bank_l":
			bank_left = item.button
	await frames(2)
	check(bank_left != null and game.ui.get_viewport().get_visible_rect().has_point(bank_left.position), "Radial buttons are laid out on screen around the aircraft")
	await capture("qa-radial", 2)
	game.choose_option("bank_l")
	check(game.planning.manoeuvre_id == "bank_l" and fighter.order == null, "First ring click selects a flight path")
	await capture("qa-radial-selected", 2)
	game.choose_option("bank_l")
	await frames(2)
	check(fighter.order != null and not game.planning.choosing_facing and is_equal_approx(fighter.order.facing, fighter.facing - PI / 4), "Clicking the selected ring option again confirms its fixed heading")
	game.select_unit(game.manager.battle.units[1])
	game.suggest_move()
	game.confirm_move()
	check(game.manager.can_commit(), "All three gesture-test orders can be committed")
	game.select_unit(ace)
	game.begin_facing()
	check(game.planning.choosing_facing and game.ui.commands.commit_button.disabled, "Commit is disabled while editing confirmed-order facing")
	game.commit_orders()
	check(game.manager.phase == TurnManager.Phase.PLANNING, "Commit cannot bypass the facing stage")
	game.manager.setup(20261017)
	game.spawn_battle()
	game.select_unit(game.manager.battle.units[0])
	await frames(2)

## Close view, the orthographic/perspective handoff, picking in perspective, and attack cinematics.
func test_camera_modes() -> void:
	var camera: TacticalCamera = game.camera
	var unit: UnitState = game.selected
	var body: Node3D = game.actors[unit.loadout.id].body
	var overview_size := camera.size
	var before := camera.unproject_position(camera.pivot)
	camera.toggle_close()
	camera.blend_time = 0.004
	camera.update_camera()
	check(camera.projection == Camera3D.PROJECTION_PERSPECTIVE and camera.unproject_position(camera.applied.target).distance_to(before) < 2.0, "Close view starts from a perspective frame matching the table view")
	await create_timer(TacticalCamera.BLEND + 0.25).timeout
	check(camera.mode == TacticalCamera.Mode.CLOSE and camera.projection == Camera3D.PROJECTION_PERSPECTIVE and is_equal_approx(camera.fov, TacticalCamera.CLOSE_FOV), "V enters a perspective close view")
	check(camera.close_target.distance_to(body.global_position + Vector3.UP * 0.8) < 0.1, "Close view orbits the selected unit")
	var ground := body.global_position + Vector3(0.8, 0, 0.6)
	ground.y = 0
	var picked := game.battle_input.field_point(camera.unproject_position(ground))
	check(picked != Vector2.INF and picked.distance_to(Vector2(ground.x, ground.z)) < 0.05, "Destination picking works in close view")
	check(game.battle_input.raycast(camera.unproject_position(body.global_position + Vector3.UP * 0.5), 2).has("collider"), "Unit picking works in close view")
	var caption: Label3D = game.actors[unit.loadout.id].caption
	await frames(2)
	var caption_pixels := caption.font_size * caption.pixel_size * root.size.y / TacticalCamera.view_height(camera, caption.global_position)
	check(absf(caption_pixels - caption.font_size) < 0.5, "Captions keep their pixel size in perspective")
	camera.toggle_close()
	await create_timer(TacticalCamera.BLEND + 0.25).timeout
	check(camera.mode == TacticalCamera.Mode.OVERVIEW and camera.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(camera.size, overview_size), "Leaving close view restores the orthographic table view")
	camera.toggle_close()
	camera.reset_view()
	await create_timer(TacticalCamera.BLEND + 0.25).timeout
	check(camera.mode == TacticalCamera.Mode.OVERVIEW and is_zero_approx(camera.azimuth) and is_equal_approx(camera.size, camera.default_size), "R leaves close view and reframes the table")
	# Attack cinematics.
	var defender: UnitState = game.manager.battle.living(1)[0]
	var result := AttackResult.new()
	result.attacker_id = unit.loadout.id
	result.defender_id = defender.loadout.id
	result.weapon_name = unit.loadout.weapons[0].display_name
	result.damage = 6
	var a := body.global_position + Vector3.UP * 0.8
	var b: Vector3 = game.actors[defender.loadout.id].body.global_position + Vector3.UP * 0.7
	check(AttackCinematic.plan(game.manager.battle, a, b, result).size() == 2, "An open attack plans a shoulder shot and a reaction shot")
	var terrain: Array = game.manager.battle.terrain
	var count := terrain.size()
	for wall in [[0.6, 0, 0.1, 0.8], [-0.6, 0, 0.1, 0.8], [0, 0.6, 0.8, 0.1], [0, -0.6, 0.8, 0.1]]:
		terrain.append({"position": [a.x + wall[0], a.z + wall[1]], "half_size": [wall[2], wall[3]], "height": 40.0, "blocks_los": true, "blocks_move": true})
	check(AttackCinematic.plan(game.manager.battle, a, b, result).is_empty(), "A fully walled-in attacker skips the cinematic")
	terrain.resize(count)
	CinematicSettings.blue_attacks = false
	check(not game.play_attack_cinematic(unit, defender, result), "Blue cinematics can be switched off")
	CinematicSettings.blue_attacks = true
	game.manager.hold = 0.0
	check(game.play_attack_cinematic(unit, defender, result), "Blue attack plays a cinematic when enabled")
	check(camera.mode == TacticalCamera.Mode.CINEMATIC and not game.ui.visible and not game.overlays.visible and game.cinematic_frame.visible, "Cinematic hides the HUD and overlays behind letterbox bars")
	check(game.manager.hold >= AttackCinematic.reaction_start(), "The turn waits for the cinematic")
	var skip := InputEventKey.new()
	skip.physical_keycode = KEY_SPACE
	skip.pressed = true
	game.battle_input.handle_input(skip)
	check(camera.mode == TacticalCamera.Mode.OVERVIEW and game.ui.visible and game.overlays.visible and is_zero_approx(game.manager.hold), "Any key skips the cinematic and releases the turn")
	game.play_attack_cinematic(unit, defender, result)
	await create_timer(AttackCinematic.total(AttackCinematic.plan(game.manager.battle, a, b, result)) + 0.2).timeout
	check(camera.mode == TacticalCamera.Mode.OVERVIEW and game.ui.visible, "A finished cinematic hands back the table view and HUD")
	await create_timer(TacticalCamera.RETURN_BLEND + 0.4).timeout
	check(not game.cinematic_frame.visible and camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "Letterbox clears after the cinematic")
	CinematicSettings.blue_attacks = false
	game.manager.hold = 0.0
	game.refresh_all()

func run() -> void:
	# Existing checks time attack visuals without the camera; test_camera_modes enables cinematics itself.
	CinematicSettings.loaded = true
	CinematicSettings.blue_attacks = false
	CinematicSettings.red_attacks = false
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	root.size = Vector2i(1440, 900)
	root.gui_embed_subwindows = true
	game = load("res://battle/world/Battlefield.tscn").instantiate()
	root.add_child(game)
	game.manager.setup(20261017)
	game.spawn_battle()
	game.select_unit(game.manager.battle.units[0])
	game.manager.paused = true
	await frames(2)
	check(game.actors.size() == 7, "Seven visual actors")
	check(game.ui.root.size.x >= 1400, "HUD fills viewport")
	check(game.planning.draft != null and game.planning.draft.valid, "Initial movement preview")
	var inspector := command_text(game.ui.units_panel.inspector)
	var jargon := RegEx.create_from_string("\\bA\\d \\(|\\bP\\d\\b|\\bARM \\d|\\bEVA \\d|\\bE\\d\\b|FRAME CAP")
	check(jargon.search(inspector) == null and inspector.contains("Full stats"), "Inspector uses plain language and offers a Full stats window")
	check(command_text(game.ui.units_panel.roster).contains("NEEDS ORDER"), "Roster names each unit's order state in words")
	game.ui.units_panel.show_stats(game.selected)
	await frames(2)
	check(game.ui.units_panel.stats_window.visible and command_text(game.ui.units_panel.stats_window).contains("Each point"), "Full stats window opens with the detailed breakdown")
	var terrain_text := game.terrain_root.find_children("*", "Label3D", true, false).map(func(node: Label3D) -> String: return node.text)
	check(not terrain_text.is_empty() and terrain_text.all(func(text: String) -> bool: return text.ends_with("COVER")), "Terrain labels show only the cover they give")
	# A blocking building inside the arc must carve a shadow out of the firing preview.
	var shadow_battle := BattleState.new(game.manager.battle.catalogue, 1)
	shadow_battle.terrain = [{"position": [2, 0], "half_size": [0.4, 0.4], "height": 3.0, "cover": 2, "blocks_move": true, "blocks_los": true}]
	var spotter := shadow_battle.unit_by_id("blue_teamster")
	spotter.position = Vector2.ZERO
	spotter.facing = PI * 0.5
	spotter.altitude = 0
	var shadow := TargetingOverlay.new()
	game.add_child(shadow)
	shadow.show_arc(spotter, spotter.loadout.weapons[0], null, false, shadow_battle)
	check(shadow.find_children("*", "Label3D", true, false).is_empty(), "Firing arc draws no floating text without a target")
	var arc_target := shadow_battle.unit_by_id("red_medved")
	arc_target.position = Vector2(0, -3)
	arc_target.altitude = 0
	var ruled := TargetingOverlay.new()
	game.add_child(ruled)
	ruled.show_arc(spotter, spotter.loadout.weapons[0], arc_target, false, shadow_battle)
	var ruler_text := ruled.find_children("*", "Label3D", true, false).map(func(node: Label3D) -> String: return node.text)
	check(ruler_text == ["3.0"], "With a target, the arc shows only the distance")
	ruled.queue_free()
	var limits := shadow.sight_limits(shadow_battle, spotter, spotter.loadout.weapons[0].arc, 6.0)
	check(limits[TargetingOverlay.SIGHT_RAYS / 2] < 2.0 and limits[0] > 5.0, "Firing preview stops at sight-blocking terrain and stays open elsewhere")
	shadow.queue_free()
	await capture("qa-stats", 2)
	game.ui.units_panel.stats_window.hide()
	var coloured := game.ui.telemetry.log_bbcode(["01 / ACE fires LR-3 Linear Rifle at 04 / BULWARK.", "LR-3 Linear Rifle: 3 hits, 0 dodged → 6 damage. DESTROYED."])
	check(coloured.contains("[color=#%s]01 / ACE" % BattleUI.BLUE.to_html(false)) and coloured.contains("[color=#%s]04 / BULWARK" % BattleUI.RED.to_html(false)) and coloured.contains("[b][color="), "Combat log colours callsigns by faction and emphasises kills")
	check(game.battle_input.raycast(game.camera.unproject_position(game.selected.world_position() + Vector3.UP * 0.5), 2).has("collider"), "Mouse ray hits unit collider")
	check(game.battle_input.field_point(game.camera.unproject_position(Vector3.ZERO)) != Vector2.INF, "Mouse ray hits battlefield")
	game.camera.azimuth = 0.4
	game.camera.pivot = Vector3(1, 0, 1)
	game.camera.size = 12
	game.camera.reset_view()
	check(is_zero_approx(game.camera.azimuth) and is_equal_approx(game.camera.size, game.camera.default_size), "Camera resets orbit and framing")
	var framed := true
	for unit in game.manager.battle.living():
		framed = framed and game.field_rect().has_point(game.camera.unproject_position(unit.world_position()))
	check(framed, "Default view frames every unit inside the area the HUD leaves clear")
	for unit in game.manager.battle.living():
		check(game.field_rect().grow(1).has_point(game.camera.unproject_position(unit.world_position())), "Reset camera keeps living units clear of the HUD")
	check(game.battle_input.field_point(game.camera.unproject_position(Vector3(16, 0, 10))) != Vector2.INF, "New outer battlefield area accepts destination raycasts")
	await test_camera_modes()
	await test_movement_gestures()
	check(game.threats_root.get_child_count() == game.manager.battle.living(1).size(), "Planning shows one threat zone per enemy")
	check(game.ui.commands.threat_label != null and game.ui.commands.threat_label.text.begins_with("THREAT /"), "Draft reports which enemies could hit its end position")
	# Bring an enemy beside a legal draft: it must be reported as threatening that end position.
	var near := game.manager.battle.units[3]
	var home := near.position
	check(game.planning.draft != null and game.planning.draft.valid, "Threat check starts from a legal draft")
	near.position = game.planning.draft.destination + Vector2(1.5, 0)
	var near_threats: Dictionary = game.draft_threats()
	check(near in near_threats.in_arc or near in near_threats.in_reach, "Draft next to an enemy is flagged as threatened")
	near.position = home
	game.refresh_all()
	game.toggle_threats()
	check(game.threats_root.get_child_count() == 0, "Threat zones toggle off")
	game.toggle_threats()
	await capture("qa-planning", 2)
	game.ui.toggle_debug()
	await frames(2)
	check(game.ui.sandbox.debug_window.visible, "Debug menu opens")
	await capture("qa-debug", 2)
	game.ui.toggle_debug()
	# Exercise the same UI commands players use, including automatic next selection.
	for i in range(3):
		game.suggest_move()
		check(game.planning.draft != null and game.planning.draft.valid, "Suggestion produces legal movement")
		game.confirm_move()
		await frames(2)
	check(game.manager.can_commit() and not game.ui.commands.commit_button.disabled, "Commit button enables only after all three orders")
	game.commit_orders()
	check(game.manager.phase == TurnManager.Phase.REVEAL, "Commit callback reveals orders")
	game.manager.paused = false
	game.manager._process(10.0)
	game.manager.paused = true
	check(game.manager.phase == TurnManager.Phase.REVEAL, "Reveal waits for the player")
	check(command_text().contains("RESOLVE MOVEMENT"), "Reveal offers a continue button")
	await capture("qa-reveal", 2)
	game.manager.advance()
	for i in range(game.manager.battle.units.size() + 1):
		game.manager.advance()
		await frames(2)
	check(game.manager.phase == TurnManager.Phase.ACTION, "Movement transitions to actions")
	check(game.manager.active == game.manager.battle.units[0], "Only units with a lock or power to use get an Action turn (Ace has Newtype)")
	game.manager.rotate_ability(15)
	check(game.manager.battle.units[0].will == 3, "Pilot power connected to Action UI")
	var guard := 0
	while game.manager.phase in [TurnManager.Phase.ACTION, TurnManager.Phase.ATTACK] and guard < 12:
		guard += 1
		game.manager.advance()
		await frames(2)
	check(game.manager.log_lines.any(func(line: String) -> bool: return line.contains(TurnManager.NO_ACTION_PREFIX)), "Skipped actions are reported in the log")
	check(game.manager.phase == TurnManager.Phase.END, "Opening fire stage automatically skips every unit without a legal target")
	# Stage a later close encounter so the firing UI is still tested after automatic skips.
	var staged_ace := game.manager.battle.units[0]
	staged_ace.position = Vector2(-3, 0)
	staged_ace.facing = PI * 0.5
	staged_ace.altitude = 0
	game.manager.battle.units[3].position = Vector2(0, 0)
	game.manager.battle.units[3].altitude = 0
	for unit in game.manager.battle.living():
		unit.attacked = false
	for actor in game.actors.values():
		if actor.tween != null:
			actor.tween.kill()
		actor.sync(true)
	game.manager.queue = game.manager.attack_queue.duplicate()
	game.manager.cursor = 0
	game.manager.set_phase(TurnManager.Phase.ATTACK)
	game.manager.next_active()
	check(game.manager.phase == TurnManager.Phase.ATTACK and game.manager.active == staged_ace, "Unit with a legal shot receives its attack normally")
	game.target = null
	game.ui.refresh()
	check(game.target == null, "Refreshing the UI does not choose a target")
	game.refresh_all()
	check(game.target != null, "Controller supplies the initial attack target")
	game.choose_target(game.manager.battle.units[3])
	await capture("qa-attack", 2)
	if game.blue_attacking():
		var attacker := game.manager.active
		game.choose_weapon(attacker.loadout.weapons.size() - 1)
		game.select_unit(game.manager.battle.living(0)[-1])
		check(game.weapon_index == attacker.loadout.weapons.size() - 1, "Inspecting a unit mid-attack keeps the chosen weapon")
		for enemy in game.manager.battle.living(1):
			game.choose_target(enemy)
			await frames(1)
			check(game.target == enemy, "Clicked target is kept, legal or not")
			var legal := CombatRules.target_error(game.manager.battle, attacker, enemy, game.current_weapon()).is_empty()
			var structure := enemy.structure
			if not legal:
				game.fire_selected()
				check(game.manager.active == attacker and enemy.structure == structure, "FIRE on an illegal target does nothing")
		check(game.actors[attacker.loadout.id].active_ring.visible, "Active unit carries the pulsing marker")
		# Round one rarely has anyone in range on the large table, so stage a target in the forward arc.
		game.choose_weapon(0)
		var staged := game.manager.battle.living(1)[0]
		var legal_now: Array[UnitState] = []
		for heading in range(0, 360, 45):
			attacker.facing = deg_to_rad(heading)
			staged.position = attacker.position + attacker.forward() * 3.0
			staged.altitude = attacker.altitude
			legal_now = CombatRules.legal_targets(game.manager.battle, attacker, game.current_weapon())
			if not legal_now.is_empty():
				break
		game.refresh_all()
		check(not legal_now.is_empty(), "Staged target is a legal shot")
		if not legal_now.is_empty():
			game.choose_target(legal_now[0])
			await frames(1)
			check(command_text().contains("FORECAST"), "Legal target shows a hit forecast")
			game.fire_selected()
			await frames(8)
			check(game.fx_root.get_child_count() > 0, "Firing spawns a shot effect")
			await capture("qa-fire", 2)
	# Complete a full battle through the renderer to catch UI and lifecycle errors.
	game.manager.auto_blue = true
	var steps := 0
	while game.manager.phase != TurnManager.Phase.BATTLE_OVER and steps < 2000:
		steps += 1
		if game.manager.phase == TurnManager.Phase.PLANNING:
			for unit in game.manager.battle.living(0).filter(game.manager.needs_order):
				game.select_unit(unit)
				game.suggest_move()
				game.confirm_move()
			game.commit_orders()
		else:
			game.manager.advance()
		await frames(1)
	check(game.manager.phase == TurnManager.Phase.BATTLE_OVER, "Full battle through the rendered scene reaches victory")
	check(is_instance_valid(game.ui.results.victory_panel), "Victory overlay appears")
	await capture("qa-victory", 2)
	game.restart()
	await frames(2)
	check(game.manager.phase == TurnManager.Phase.PLANNING and game.manager.battle.living().size() == 7, "Restart returns seven living units to round one")
	check(not is_instance_valid(game.ui.results.victory_panel), "Restart dismisses victory overlay")
	await test_melee_flow()
	game.queue_free()
	await frames(2)
	finish()

## Plan blue units that still need orders, commit, and step until the given phase (Blue passes everything).
func play_until(phase: TurnManager.Phase, stop_on: UnitState = null) -> void:
	var steps := 0
	while steps < 200 and not (game.manager.phase == phase and (stop_on == null or game.manager.active == stop_on)):
		steps += 1
		var manager := game.manager
		if manager.phase == TurnManager.Phase.PLANNING:
			for unit in manager.battle.living(0).filter(manager.needs_order):
				game.select_unit(unit)
				game.suggest_move()
				game.confirm_move()
			game.commit_orders()
		elif manager.phase == TurnManager.Phase.ACTION and manager.active != null and manager.active.loadout.faction == 0:
			manager.end_action()
		elif manager.phase == TurnManager.Phase.ATTACK and manager.active != null and manager.active.loadout.faction == 0:
			manager.pass_attack()
		else:
			manager.advance()
		await frames(1)

func test_melee_flow() -> void:
	var manager := game.manager
	manager.auto_blue = false
	manager.set_ai(false)
	var battle := manager.battle
	var teamster := battle.unit_by_id("blue_teamster")
	var medved := battle.unit_by_id("red_medved")
	teamster.position = Vector2(-2, 0)
	teamster.facing = PI * 0.5
	medved.position = Vector2(1, 0)
	medved.facing = -PI * 0.5
	game.refresh_all()
	game.select_unit(teamster)
	game.choose_manoeuvre("charge")
	await frames(2)
	check(game.planning.draft != null and game.planning.draft.valid and game.planning.draft.target_id == "red_medved", "Choosing Charge aims at the nearest reachable enemy")
	check(game.actors["red_medved"].target_ring.visible, "Chargeable enemies carry the target crosshair")
	check(command_text().contains("CHARGE /") and command_text().contains("Click an enemy to charge"), "Command panel explains the charge steps")
	await capture("qa-charge-plan", 2)
	click_world(medved.world_position() + Vector3.UP * 0.5)
	await frames(2)
	check(teamster.order != null and teamster.order.target_id == "red_medved", "Clicking the charge target again confirms the charge")
	await play_until(TurnManager.Phase.ACTION, teamster)
	check(MeleeRules.engaged_with(teamster, medved), "The charge connects and engages both units")
	check(game.actors["blue_teamster"].caption.text.contains("MELEE"), "Engaged units are tagged on the field")
	check(command_text().contains("ENGAGED /") and command_text().contains("BREAK OFF"), "Action panel offers Break Off to an engaged unit")
	await capture("qa-melee", 2)
	# Stay and trade blows; next round the unit has nothing to plan.
	await play_until(TurnManager.Phase.PLANNING)
	game.select_unit(teamster)
	await frames(2)
	check(MeleeRules.is_engaged(battle, teamster) and command_text().contains("ENGAGED /") and game.planning.draft == null, "Engaged units show their lock instead of movement controls")
	await play_until(TurnManager.Phase.ACTION, teamster)
	var lock_held := MeleeRules.is_engaged(battle, teamster)
	check(lock_held, "Engagement persists while both units stand")
	if lock_held:
		check(manager.break_off(), "Break Off succeeds from the Action phase")
		await frames(4)
		check(not MeleeRules.is_engaged(battle, teamster) and MeleeRules.edge_gap(teamster, medved) > MeleeRules.ENGAGE_REACH, "Breaking off leaves melee reach")
		check(not game.actors["blue_teamster"].caption.text.contains("MELEE"), "Field tag clears after breaking off")
	manager.set_ai(true)
