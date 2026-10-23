extends SceneTree

var checks := 0
var failures := 0
var screen: WorkshopUI

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("WORKSHOP UI FAIL / " + message)

func frames(count: int = 3) -> void:
	for i in count:
		await process_frame

func capture(name: String) -> void:
	await frames(5)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://artifacts/" + name + ".png")

func find_button(parent: Node, prefix: String) -> Button:
	for node in parent.find_children("*", "Button", true, false):
		if node.text.begins_with(prefix):
			return node
	return null

func run() -> void:
	root.size = Vector2i(1440,900)
	var session := root.get_node("WorkshopSession")
	var previous_store: WorkshopState = session.store
	session.store = WorkshopState.new("res://artifacts/workshop-ui-test.json")
	screen = load("res://workshop/Workshop.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	await frames(5)
	check(screen.selected_region == "left_arm", "Initial inspection opens damaged arm")
	check(screen.preview.model != null, "Imported Teamster model appears in the bay")
	check(not screen.picker.visible, "Character sheet starts without an inspector obscuring the model")
	check(screen.slot_buttons.size() == 14, "Every installed component has a clickable equipment icon")
	check(screen.slot_buttons["head.sensor"].get_global_rect().end.x < screen.preview.get_global_rect().position.x, "Left slots flank the model")
	check(screen.slot_buttons["power.plant"].get_global_rect().position.x > screen.preview.get_global_rect().end.x, "Right slots flank the model")
	check(screen.stats_column.get_global_rect().position.x > screen.preview.get_global_rect().end.x, "Frame and pilot breakdown sits to the right of the model")
	check(screen.find_children("StatsTable", "GridContainer", true, false).size() == 1, "A single stat table replaces the duplicated sidebars")
	check(screen.pilot_bar.get_global_rect().position.y > screen.preview.get_global_rect().end.y, "Pilot selection occupies the bottom bar")
	check(screen.pilot_bar.get_child_count() == 3 and screen.pilot_bar.get_children().all(func(n: Button) -> bool: return n.icon != null), "All three generated pilot portraits appear in the bottom bar")
	var original_move: String = screen.stats_column.find_child("Stat_move",true,false).text
	screen.pilot_bar.get_node("Pilot_rook").pressed.emit()
	await frames()
	check(screen.draft.pilot == "rook" and screen.store.owned.pilot == "anchor", "Pilot selector edits the draft without mutating the saved assignment")
	check(screen.stats_column.find_child("Stat_reflex",true,false).text == "2" and screen.stats_column.find_child("Stat_move",true,false).text == original_move, "Pilot stats update capped Reflex while movement remains frame-derived")
	check(find_button(screen.footer,"Deploy").disabled, "Pending pilot assignment requires Apply before deployment")
	screen.pilot_bar.get_node("Pilot_kestrel").pressed.emit()
	await frames()
	check(screen.stats_column.find_child("Stat_gunnery",true,false).text == "1.5" and screen.stats_column.find_child("Stat_precision",true,false).text == "1", "Marksman profile updates shooting and precision totals")
	check(screen.stats_column.find_child("Frame_gunnery",true,false).text == "0" and screen.stats_column.find_child("Pilot_gunnery",true,false).text == "1.5", "Table separates frame hardware from pilot contribution")
	var original_base: FrameData = screen.base
	screen.base = screen.base.duplicate(true)
	screen.base.stat_max.gunnery = 1.0
	screen.refresh()
	check(screen.stats_column.find_child("Threshold_gunnery",true,false).text == "1" and screen.stats_column.find_child("Stat_gunnery",true,false).text == "1", "Total is capped by the displayed frame threshold")
	screen.base = original_base
	screen.refresh()
	await capture("workshop-pilot-kestrel")
	find_button(screen.footer,"Discard").pressed.emit()
	await frames()
	check(screen.draft.pilot == "anchor" and screen.pilot_stats.gunnery == 1, "Discard restores both the pilot and stat display")
	check(EquipmentSlot.RARITIES.standard == Color("67cd83") and EquipmentSlot.RARITIES.uncommon == Color("58a9f4") and EquipmentSlot.RARITIES.rare == Color("ee666d"), "Rarity palette is green, blue and red")
	await capture("workshop-sheet")
	var animation_choice := screen.find_child("AnimationChoice", true, false) as OptionButton
	animation_choice.select(5)
	find_button(screen, "Play").pressed.emit()
	await frames()
	check(screen.preview.animator.player.current_animation == "fire_rifle", "Workshop Play previews the selected firing clip")
	find_button(screen, "Pause").pressed.emit()
	check(screen.preview.animator.paused, "Workshop can pause a clip for inspection")
	find_button(screen, "Rest").pressed.emit()
	check(not screen.preview.animator.player.is_playing(), "Workshop Rest returns to a neutral static pose")
	screen.inspection_buttons.isolated.pressed.emit()
	var region_roots := screen.preview.model.find_children("Region_*", "Node3D", true, false)
	check(region_roots.filter(func(n: Node3D) -> bool: return n.visible).size() == 1, "Isolate mode displays only the selected region")
	screen.inspection_buttons.exploded.pressed.emit()
	check(region_roots.all(func(n: Node3D) -> bool: return n.visible), "Exploded mode shows all regions")
	check(screen.preview.inspection_mode == "exploded" and screen.inspection_buttons.exploded.button_pressed, "Visible Exploded button selects and indicates the mode")
	check(region_roots.any(func(n: Node3D) -> bool: return not n.position.is_equal_approx(n.get_meta("rest_position"))), "Exploded view physically separates the region meshes")
	screen.select_pilot("rook")
	await frames()
	check(screen.preview.inspection_mode == "exploded" and screen.inspection_buttons.exploded.button_pressed, "Pilot and stat updates preserve exploded inspection")
	screen.select_pilot("anchor")
	region_roots = screen.preview.model.find_children("Region_*", "Node3D", true, false)
	await capture("teamster-v2-exploded")
	screen.inspection_buttons.assembled.pressed.emit()
	check(region_roots.all(func(n: Node3D) -> bool: return n.position.is_equal_approx(n.get_meta("rest_position"))), "Assembled button restores every region to its mounting point")
	# Actual model picking uses the same camera projection and input handler as the bay.
	await physics_frame
	var head_position := screen.preview.camera.unproject_position(screen.preview.rig.to_global(Vector3(0,1.21,-0.16)))
	var click := InputEventMouseButton.new()
	click.position = head_position
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	screen.preview._gui_input(click)
	click = click.duplicate()
	click.pressed = false
	screen.preview._gui_input(click)
	await frames()
	check(screen.selected_region == "head", "Clicking the model selects the intersected component region")
	screen.select_region("left_arm")
	check(find_button(screen.footer, "Deploy").disabled == false, "Serviceable mech may deploy despite damage")
	await capture("workshop-initial")
	find_button(screen.picker_content, "Repair ·").pressed.emit()
	await frames()
	check(screen.draft.repairs.size() == 1 and find_button(screen.footer, "Deploy").disabled, "Repair queues and blocks deploying an unapplied draft")
	find_button(screen.footer, "Discard").pressed.emit()
	await frames()
	check(screen.draft.repairs.is_empty(), "Discard clears pending repairs")
	screen.open_slot('left_arm.actuator')
	await frames()
	screen.picker_content.find_child("Inspect_spare_arm_standard", true, false).pressed.emit()
	await frames()
	find_button(screen.picker_content, "Equip").pressed.emit()
	await frames()
	check(screen.draft.installed["left_arm.actuator"] == "spare_arm_standard", "Store replacement control previews a real owned component")
	screen.repair_all()
	screen.tool_buttons.paint.pressed.emit()
	await frames()
	find_button(screen.picker_content, "Winter service").pressed.emit()
	await frames()
	check(screen.draft.finish == "winter", "Paint selection updates draft")
	await capture("workshop-paint")
	# Commit to a test-only path, then rebuild the UI exactly as a returning session does.
	find_button(screen.footer, "Apply refit").pressed.emit()
	await frames()
	check(not screen.store.changed(screen.draft) and screen.store.owned.finish == "winter", "Apply control commits combined repair, replacement and paint")
	screen.select_region("backpack")
	screen.selected_slot = "backpack.module"
	screen.open_slot("backpack.module")
	await frames()
	screen.picker_content.find_child("Inspect_spare_module_recovery", true, false).pressed.emit()
	await frames()
	find_button(screen.picker_content, "Equip").pressed.emit()
	await frames()
	check(screen.store.part_for("backpack.module", screen.draft).id == "module_recovery", "Mission module previews from inventory")
	screen.tool_buttons.weapons.pressed.emit()
	await frames()
	check(screen.preview.model.find_children("Hornet_12_cell_pod*", "", true, false).all(func(n: Node) -> bool: return not n.visible), "Recovery fit hides Hornet geometry")
	await capture("workshop-recovery")
	screen.select_region("head")
	screen.show_incompatible = true
	screen.refresh()
	await frames()
	screen.picker_content.find_child("Inspect_spare_foreign_sensor", true, false).pressed.emit()
	await frames()
	check(screen.picker_content.find_children("*", "Button", true, false).any(func(n: Node) -> bool: return n.text == "Equip" and n.disabled), "Incompatible parts are visible but cannot be installed")
	screen.show_incompatible = false
	screen.open_slot("head.sensor")
	var custom_uid: String = screen.draft.installed["head.sensor"]
	screen.set_part_finish(custom_uid, "desert")
	await frames()
	var icon: EquipmentSlot = screen.slot_buttons["head.sensor"]
	var phase := icon.phase
	await frames(8)
	check(icon.customised and icon.is_processing() and icon.phase != phase, "Custom component has a moving rarity border")
	check(not screen.slot_buttons["torso.armour"].is_processing(), "Factory equipment keeps a static border")
	check(icon.rarity_colour() == EquipmentSlot.RARITIES.standard, "Customisation does not change equipment rarity")
	check(screen.store.owned.part_finishes.is_empty(), "Customisation preview does not mutate the save")
	var head := screen.preview.model.find_child("Component_head_sensor", true, false)
	check(head.find_children("*", "MeshInstance3D", true, false).any(func(mesh: MeshInstance3D) -> bool:
		var material: Material = mesh.get_active_material(0)
		return material is ShaderMaterial and (material.get_shader_parameter("paint") as Color).is_equal_approx(Color("ac9870"))
	), "Custom finish changes the matching model component")
	await capture("workshop-customised")
	screen.set_part_finish(custom_uid, "")
	check(not icon.customised and not icon.is_processing(), "Factory finish removes the animated customisation marker")
	screen.set_part_finish(custom_uid, "desert")
	for region in screen.store.regions:
		screen.select_region(region.id)
		await frames()
		check(screen.selected_slot == region.slots[0].id, "Region navigation selects a valid slot: " + region.id)
	root.size = Vector2i(1280,720)
	screen.picker.hide()
	await capture("workshop-720")
	check(screen.footer.get_global_rect().end.y <= screen.get_viewport_rect().end.y, "Footer remains within the stretched viewport at 720p")
	check(screen.preview.size.y >= 260, "Service bay retains a useful minimum height")
	# Complete the real workshop -> battle -> workshop route with an isolated save.
	screen.apply_refit()
	await frames()
	find_button(screen.footer, "Deploy").pressed.emit()
	await frames(8)
	var game := current_scene as BattleController
	check(game != null and session.active, "Deploy opens the tactical battle with workshop session active")
	if game != null:
		game.manager.paused = true
		var mech := game.manager.battle.unit_by_id("blue_teamster")
		check(mech.loadout.frame.structure == 77 and mech.loadout.weapons.size() == 3 and not mech.loadout.weapons.any(func(w: WeaponData) -> bool: return w.id == "hornet_pod"), "Battle receives the applied recovery fit (two weapons plus hands)")
		check(mech.loadout.workshop_finish == "winter", "Battle receives the applied finish")
		check(mech.loadout.workshop_part_finishes.has("Component_head_sensor"), "Per-component customisation reaches battle presentation")
		var before_fire := JSON.stringify(game.manager.battle.to_dict())
		var shot := AttackResult.new()
		shot.attacker_id = "blue_teamster"
		shot.defender_id = "red_medved"
		shot.weapon_name = "AR-40 Longhorn Rifle"
		for weapon in mech.loadout.weapons:
			if weapon.id == "ar40_rifle": shot.weapon_name = weapon.display_name
		shot.shots.assign([AttackResult.Shot.MISS])
		game.on_attack_resolved(shot)
		# Cinematic attacks wait for the camera lead-in before the weapon fires.
		await create_timer(AttackCinematic.lead() + 0.05).timeout
		check(game.actors["blue_teamster"].animation.player.current_animation == "fire_rifle", "Battle attack event triggers the matching firing animation")
		check(JSON.stringify(game.manager.battle.to_dict()) == before_fire, "Firing presentation leaves authoritative combat state unchanged")
		game.select_unit(mech)
		await capture("workshop-deployed")
		mech.structure -= 12
		check(session.capture_result(game.manager.battle), "Result recording succeeds")
		check(session.capture_result(game.manager.battle) and session.store.owned.hull_damage == 12, "Repeated capture is idempotent")
		game.return_to_workshop()
		await frames(8)
		screen = current_scene as WorkshopUI
		check(screen != null and not session.active, "Return opens the workshop and ends the sortie")
		check(screen.store.owned.hull_damage == 12 and screen.store.owned.finish == "winter", "Return retains paint and records actual hull damage")
		await capture("workshop-returned")
		screen.tool_buttons.weapons.pressed.emit()
		await frames()
		find_button(screen.picker_content, "Preview two-handed rifle kit").pressed.emit()
		await frames()
		check(TeamsterParts.two_handed(screen.store.fit_parts(screen.draft)), "Weapons tab previews both components of the rifle kit together")
		check(screen.preview.animator.two_handed, "Workshop model adopts paired weapon handling")
		check(not find_button(screen.footer, "Apply refit").disabled, "Complete rifle-kit draft can be applied")
		await capture("workshop-twohand-kit")
	screen.queue_free()
	current_scene = null
	await frames()
	session.store = previous_store
	DirAccess.remove_absolute("res://artifacts/workshop-ui-test.json")
	print("WORKSHOP UI: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
