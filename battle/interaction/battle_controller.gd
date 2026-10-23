class_name BattleController
extends Node3D

var workshop_session: WorkshopRuntime:
	get:
		return get_node("/root/WorkshopSession") as WorkshopRuntime

const UNIT_SCENE := preload("res://units/presentation/UnitActor.tscn")
const TERRAIN_SCENE := preload("res://battle/world/TerrainActor.tscn")
const UI_SCENE := preload("res://ui/BattleUI.tscn")
var battle_input: BattleInput
var overlay_renderer: BattleOverlayRenderer
var planning: PlanningSession
var manager: TurnManager
var camera: TacticalCamera
var world_environment: WorldEnvironment
var ui: BattleUI
var actors: Dictionary = {}
var actors_root: Node3D
var terrain_root: Node3D
var overlays: Node3D
var fx_root: Node3D
var selected: UnitState
var target: UnitState
var drafts_root: Node3D
var weapon_index: int = 0
var use_will: bool = false
var use_push: bool = false
var show_los: bool = false
var show_arcs: bool = true
var show_ranges: bool = true
## Enemy threat zones while planning. Kept on their own root so hover/aim redraws never rebuild them.
var show_threats: bool = true
var threats_root: Node3D
var presentation: BattlePresentation
var cinematic_frame: CinematicFrame

func _ready() -> void:
	battle_input = BattleInput.new()
	battle_input.controller = self
	add_child(battle_input)
	planning = PlanningSession.new()
	planning.controller = self
	add_child(planning)
	overlay_renderer = BattleOverlayRenderer.new()
	overlay_renderer.controller = self
	add_child(overlay_renderer)
	manager = TurnManager.new()
	add_child(manager)
	manager.state_changed.connect(refresh_all)
	manager.phase_changed.connect(on_phase_changed)
	manager.active_changed.connect(on_active_changed)
	manager.unit_moved.connect(func(unit: UnitState, path: PackedVector2Array) -> void:
		var actor: UnitActor = actors[unit.loadout.id]
		actor.animate(path)
		# Let the heavier walk finish before revealing the next movement activation.
		if actor.animation != null:
			manager.hold = maxf(manager.hold, actor.move_duration - manager.resolution_delay))
	manager.attack_resolved.connect(on_attack_resolved)
	var catalogue := Catalogue.new()
	workshop_session.configure(catalogue)
	manager.setup(-1, catalogue)
	build_table()
	spawn_battle()
	presentation = BattlePresentation.new()
	add_child(presentation)
	presentation.setup(self)
	ui = UI_SCENE.instantiate()
	add_child(ui)
	selected = manager.battle.units[0]
	ui.setup(self)
	camera.focus_provider = focus_rect
	camera.clear_rect_provider = field_rect
	camera.reset_view()
	select_unit(selected)
	if "--capture" in OS.get_cmdline_user_args():
		capture_preview.call_deferred()

func build_table() -> void:
	world_environment = BattlefieldBuilder.build(self, manager.battle.bounds)
	camera = TacticalCamera.new()
	add_child(camera)
	camera.configure(manager.battle.bounds)
	camera.current = true
	camera.close_target_provider = close_focus
	camera.cinematic_finished.connect(func() -> void: set_cinematic_view(false))
	OvaRendering.install(self, camera)
	cinematic_frame = CinematicFrame.new()
	add_child(cinematic_frame)
	actors_root = Node3D.new()
	add_child(actors_root)
	terrain_root = Node3D.new()
	add_child(terrain_root)
	overlays = Node3D.new()
	add_child(overlays)
	drafts_root = Node3D.new()
	add_child(drafts_root)
	fx_root = Node3D.new()
	add_child(fx_root)
	threats_root = Node3D.new()
	add_child(threats_root)

func clear_nodes(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func spawn_battle() -> void:
	clear_nodes(fx_root)
	clear_nodes(actors_root)
	clear_nodes(terrain_root)
	actors.clear()
	for unit in manager.battle.units:
		var actor: UnitActor = UNIT_SCENE.instantiate()
		actors_root.add_child(actor)
		actor.setup(unit)
		actors[unit.loadout.id] = actor
	for data in manager.battle.terrain:
		var actor: TerrainActor = TERRAIN_SCENE.instantiate()
		terrain_root.add_child(actor)
		actor.setup(data)

func restart() -> void:
	if workshop_session.active:
		return_to_workshop()
		return
	camera.skip_cinematic()
	selected = null
	target = null
	planning.draft = null
	manager.setup()
	spawn_battle()
	ui.commands.last_result = null
	camera.reset_view()
	select_unit(manager.battle.units[0])

func return_to_workshop() -> void:
	workshop_session.return_to_workshop(manager.battle)

func remember_plan() -> void:
	planning.remember_plan()

func select_unit(unit: UnitState) -> void:
	remember_plan()
	selected = unit
	# Inspecting another unit mid-attack must not discard the active unit's weapon choice.
	if not blue_attacking():
		weapon_index = 0
	planning.select_unit(unit)
	# The close view follows whichever unit is being inspected or planned.
	if camera.mode == TacticalCamera.Mode.CLOSE and actors.has(unit.loadout.id):
		camera.follow = actors[unit.loadout.id].body
	refresh_all()

## Close view orbits the unit under the cursor, else the selected unit.
func close_focus(screen_point: Vector2) -> Node3D:
	if screen_point != Vector2.INF:
		var hit := battle_input.raycast(screen_point, 2)
		if not hit.is_empty():
			return actors[hit.collider.get_meta("unit_id")].body
	if selected != null and actors.has(selected.loadout.id):
		return actors[selected.loadout.id].body
	return null

func choose_manoeuvre(id: String) -> void:
	planning.choose_manoeuvre(id)

func choose_altitude(altitude: int) -> void:
	planning.choose_altitude(altitude)

func rotate_plan(degrees: float) -> void:
	planning.rotate_plan(degrees)

func planning_aircraft() -> bool:
	return planning.planning_aircraft()

func update_draft() -> void:
	planning.update_draft()

## Radial pick: the first click selects a flight path, clicking the selected path again confirms it.
func choose_option(id: String) -> void:
	planning.choose_option(id)

func set_hover_option(id: String) -> void:
	planning.set_hover_option(id)

func begin_facing() -> void:
	planning.begin_facing()

func aim_plan_at(point: Vector2) -> void:
	planning.aim_plan_at(point)

func cancel_facing() -> void:
	planning.cancel_facing()

func confirm_move() -> void:
	planning.confirm_move()

func suggest_move() -> void:
	planning.suggest_move()

func commit_orders() -> void:
	if planning.choosing_facing:
		return
	if manager.commit():
		planning.draft = null
		presentation.ping()
		refresh_all()

func current_weapon() -> WeaponData:
	var unit: UnitState = manager.active if manager.phase == TurnManager.Phase.ATTACK and manager.active != null else selected
	if unit == null:
		return null
	weapon_index = clampi(weapon_index, 0, unit.loadout.weapons.size() - 1)
	return unit.loadout.weapons[weapon_index]

func blue_attacking() -> bool:
	return manager.phase == TurnManager.Phase.ATTACK and manager.active != null and manager.active.loadout.faction == 0

func choose_weapon(index: int) -> void:
	weapon_index = index
	# Keep the chosen target; the command panel explains if this weapon cannot reach it.
	refresh_all()

func choose_target(unit: UnitState) -> void:
	target = unit
	refresh_all()

func fire_selected() -> void:
	if target != null and CombatRules.target_error(manager.battle, manager.active, target, current_weapon()).is_empty():
		manager.fire(current_weapon(), target, use_will, use_push)

func on_active_changed(unit: UnitState) -> void:
	if unit.loadout.faction == 0 and manager.phase in [TurnManager.Phase.ACTION, TurnManager.Phase.ATTACK]:
		selected = unit
		weapon_index = 0
		if manager.phase == TurnManager.Phase.ATTACK:
			for i in unit.loadout.weapons.size():
				if not CombatRules.legal_targets(manager.battle, unit, unit.loadout.weapons[i]).is_empty():
					weapon_index = i
					break
		target = null
		use_will = false
		use_push = false
	if actors.has(unit.loadout.id):
		camera.focus_on(actors[unit.loadout.id].body, field_rect())
	refresh_all()

## Where the action is: living units plus breathing room, kept on the table.
func focus_rect() -> Rect2:
	var living := manager.battle.living()
	if living.is_empty():
		return manager.battle.bounds
	var area := Rect2(living[0].position, Vector2.ZERO)
	for unit in living:
		area = area.expand(unit.position)
	area = area.grow(2.5)
	# A minimum extent stops a lone survivor from filling the screen.
	area = area.grow_individual(maxf(0, 7 - area.size.x * 0.5), maxf(0, 4 - area.size.y * 0.5), maxf(0, 7 - area.size.x * 0.5), maxf(0, 4 - area.size.y * 0.5))
	return area.intersection(manager.battle.bounds) if area.intersects(manager.battle.bounds) else manager.battle.bounds

## Screen area not covered by the HUD panels (see BattleUI layout offsets).
func field_rect() -> Rect2:
	var screen := get_viewport().get_visible_rect().size
	return Rect2(Vector2(300, 150), screen - Vector2(300 + 330, 150 + 230))

func on_attack_resolved(result: AttackResult) -> void:
	ui.commands.last_result = result
	var attacker := manager.battle.unit_by_id(result.attacker_id)
	var defender := manager.battle.unit_by_id(result.defender_id)
	if not actors.has(attacker.loadout.id) or not actors.has(defender.loadout.id):
		return
	var weapon_id := ""
	for weapon in attacker.loadout.weapons:
		if weapon.display_name == result.weapon_name:
			weapon_id = weapon.id
			break
	if play_attack_cinematic(attacker, defender, result):
		# The camera swings in first; the shot fires once it is over the attacker's shoulder.
		get_tree().create_timer(AttackCinematic.lead()).timeout.connect(play_attack_visuals.bind(result, weapon_id, manager.battle))
	else:
		play_attack_visuals(result, weapon_id, manager.battle)

func play_attack_visuals(result: AttackResult, weapon_id: String, battle: BattleState) -> void:
	# A restart can replace the battle while a cinematic lead-in is pending.
	if battle != manager.battle or not actors.has(result.attacker_id) or not actors.has(result.defender_id):
		return
	var attacker: UnitActor = actors[result.attacker_id]
	var defender: UnitActor = actors[result.defender_id]
	attacker.fire_animation(weapon_id)
	var from: Vector3 = attacker.muzzle_position(weapon_id)
	var to: Vector3 = defender.body.global_position + Vector3.UP * 0.5
	var fx := AttackFX.new()
	fx_root.add_child(fx)
	fx.play(from, to, attacker.faction_color, result, defender.unit.loadout.faction, maxf(1.0, TacticalCamera.view_height(camera, to) / 17.5))
	if result.damage > 0:
		defender.hit_react(AttackFX.TRAVEL)
		var jolt := func() -> void: camera.nudge(0.35 if result.destroyed else 0.12)
		get_tree().create_timer(AttackFX.TRAVEL + (0.3 if result.destroyed else 0.0)).timeout.connect(jolt)

## Starts the attack camera when this side's setting allows and a clear shot exists. Paces the turn to match.
func play_attack_cinematic(attacker: UnitState, defender: UnitState, result: AttackResult) -> bool:
	if not CinematicSettings.plays_for(attacker.loadout.faction):
		return false
	var attacker_actor: UnitActor = actors[attacker.loadout.id]
	var defender_actor: UnitActor = actors[defender.loadout.id]
	var attacker_scale := attacker.loadout.frame.model_scale()
	var defender_scale := defender.loadout.frame.model_scale()
	var steps := AttackCinematic.plan(manager.battle, attacker_actor.body.global_position + Vector3.UP * 0.8 * attacker_scale, defender_actor.body.global_position + Vector3.UP * 0.7 * defender_scale, result, attacker_scale, defender_scale)
	if steps.is_empty():
		return false
	var seconds := camera.play_cinematic(steps)
	manager.hold = maxf(manager.hold, seconds + 0.2 - manager.resolution_delay)
	# Damage drain and death wait for the cut to the target.
	defender_actor.presentation_delay = AttackCinematic.reaction_start() - 0.05
	cinematic_frame.show_caption("%s  →  %s   ·   %s" % [attacker.loadout.callsign.split(" / ")[-1], defender.loadout.callsign.split(" / ")[-1], result.weapon_name.to_upper()], attacker_actor.faction_color)
	set_cinematic_view(true)
	return true

## The HUD and planning overlays step aside for a cinematic; the combat log still records everything.
func set_cinematic_view(playing: bool) -> void:
	if ui != null:
		ui.visible = not playing
	for layer in [overlays, drafts_root, threats_root]:
		layer.visible = not playing
	# Captions, health bars and cover labels are table furniture; up close they block the shot.
	for actor in actors.values():
		actor.caption.visible = not playing
		actor.health_fill.get_parent().visible = not playing
	for label in terrain_root.find_children("*", "Label3D", true, false):
		label.visible = not playing
	if not playing:
		cinematic_frame.close()

func skip_cinematic() -> void:
	if camera.mode != TacticalCamera.Mode.CINEMATIC:
		return
	camera.skip_cinematic()
	manager.hold = 0.0

func on_phase_changed() -> void:
	if manager.phase == TurnManager.Phase.BATTLE_OVER and workshop_session.active:
		workshop_session.capture_result(manager.battle)
	# Remembered plans hold positions from this round only.
	planning.plan_memory.clear()
	planning.draft = null
	planning.destination_fixed = false
	planning.choosing_facing = false
	if ui != null and manager.phase == TurnManager.Phase.PLANNING:
		var friendly := manager.battle.living(0)
		var to_plan := friendly.filter(manager.needs_order)
		if not to_plan.is_empty():
			select_unit(to_plan[0])
		elif not friendly.is_empty():
			select_unit(friendly[0])

func refresh_all() -> void:
	if ui == null:
		return
	ensure_attack_target()
	for actor in actors.values():
		actor.sync()
	refresh_threats()
	refresh_overlays()
	ui.refresh()
	presentation.refresh()

func refresh_threats() -> void:
	overlay_renderer.refresh_threats()

func toggle_threats() -> void:
	show_threats = not show_threats
	refresh_all()

## Which enemies could hit the selected unit where its draft ends: in an arc right now, or only after moving.
func draft_threats() -> Dictionary:
	var result := {"in_arc": [], "in_reach": []}
	if planning.draft == null or not planning.draft.valid or selected == null:
		return result
	var projected := targeting_unit()
	for enemy in manager.battle.living(1 - selected.loadout.faction):
		var in_arc := false
		for weapon in enemy.loadout.weapons:
			if CombatRules.target_error(manager.battle, enemy, projected, weapon).is_empty():
				in_arc = true
				break
		if in_arc:
			result.in_arc.append(enemy)
			continue
		var reach := CombatRules.threat_reach(manager.battle, enemy, projected.altitude)
		if reach >= 0 and enemy.position.distance_to(projected.position) <= reach:
			result.in_reach.append(enemy)
	return result

func refresh_overlays() -> void:
	overlay_renderer.refresh_overlays()

func targeting_unit() -> UnitState:
	if manager.phase == TurnManager.Phase.ATTACK and manager.active != null:
		return manager.active
	if selected == null or planning.draft == null or not planning.draft.valid or manager.phase != TurnManager.Phase.PLANNING or selected.loadout.faction != 0:
		return selected
	var projected := UnitState.new(selected.loadout)
	projected.position = planning.draft.destination
	projected.facing = planning.draft.facing
	projected.altitude = planning.draft.altitude
	projected.energy = selected.energy - planning.draft.energy_cost
	projected.structure = selected.structure
	selected.copy_stats_to(projected)
	return projected

func show_movement_envelope() -> void:
	overlay_renderer.show_movement_envelope()

func refresh_draft() -> void:
	overlay_renderer.refresh_draft()

func set_plan_point(point: Vector2) -> void:
	planning.set_plan_point(point)

func capture_preview() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	get_viewport().get_texture().get_image().save_png("res://artifacts/battlefield.png")
	print("CAPTURE / res://artifacts/battlefield.png")
	get_tree().quit()

func ensure_attack_target() -> void:
	if not blue_attacking() or (target != null and target.alive()):
		return
	var legal := CombatRules.legal_targets(manager.battle, manager.active, current_weapon())
	var enemies := manager.battle.living(1)
	target = legal[0] if not legal.is_empty() else (enemies[0] if not enemies.is_empty() else null)

func set_use_will(enabled: bool) -> void:
	use_will = enabled
	ui.refresh.call_deferred()

func set_use_push(enabled: bool) -> void:
	use_push = enabled
	ui.refresh.call_deferred()

func clear_hover_option() -> void:
	planning.hover_option = ""

func _unhandled_input(event: InputEvent) -> void:
	battle_input.handle_input(event)
