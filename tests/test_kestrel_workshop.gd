extends "res://tests/test_suite.gd"

var screen: WorkshopUI

func run() -> void:
	root.size = Vector2i(1920,1080)
	DirAccess.make_dir_recursive_absolute("res://artifacts/kestrel-workshop")
	var session: WorkshopRuntime = root.get_node("WorkshopSession")
	var team := WorkshopState.new("res://artifacts/kestrel-workshop/team-test.json")
	var kestrel := WorkshopState.new("res://artifacts/kestrel-workshop/kestrel-test.json", "hx7_kestrel")
	# Isolated stores keep this test away from the player's saves.
	for path in [team.save_path, kestrel.save_path]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	session.store = team
	session.stores = {"m9_teamster":team, "hx7_kestrel":kestrel}
	session.save_available = true
	screen = load("res://workshop/Workshop.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	await frames(4)
	screen.frame_choice.item_selected.emit(1)
	await frames(4)
	check(screen.base.id == "hx7_kestrel" and screen.preview.frame_id == "hx7_kestrel", "Selector changes both the frame data and the model")
	check(screen.slot_buttons.size() == 14, "All fourteen Kestrel components have controls")
	check(screen.store.validate(screen.draft).is_empty(), "Factory Kestrel fit is compatible and valid")
	check(screen.store.weapon_ids(screen.draft) == ["lr3_rifle", "vb2_knife", "agm_stores"], "Factory weapons use Kestrel equipment")
	check(screen.store.weapon_for(screen.store.part_for("right_arm.armour",screen.draft),"right_arm.armour") == "vb2_knife" and screen.store.weapon_for(screen.store.part_for("left_arm.actuator",screen.draft),"left_arm.actuator").is_empty(), "VB-2 belongs to the right forearm shell shown on the model")
	check(screen.preview.animator is KestrelAnimator and screen.animation_choice.item_count == 19, "Kestrel has its own full animation menu")
	var regions := screen.preview.model.find_children("Region_*", "Node3D", true, false)
	check(regions.size() == 8, "All eight imported regions appear")
	check(screen.preview.model.find_child("Chest_fuselage", true, false) != null, "Workshop displays the curved Kestrel asset")
	check(screen.preview.model.find_child("Hornet_12_cell_pod", true, false) == null, "Kestrel has no Teamster pod")
	check(screen.store.resolve(screen.base,screen.draft).structure == 60 and screen.store.resolve(screen.base,screen.draft).energy_capacity == 5, "Standard fit preserves catalogue stats")
	screen.set_camera_angle(0)
	await capture("kestrel-workshop/front", 6)
	screen.set_camera_angle(PI)
	await capture("kestrel-workshop/rear", 6)
	screen.set_camera_angle(PI/2)
	await capture("kestrel-workshop/side", 6)
	screen.set_camera_angle(-.6)
	await capture("kestrel-workshop/assembled", 6)
	screen.set_inspection("exploded")
	check(regions.any(func(n: Node3D) -> bool: return not n.position.is_equal_approx(n.get_meta("rest_position"))), "Exploded inspection moves the imported regions")
	await capture("kestrel-workshop/exploded", 6)
	for region in screen.store.regions:
		screen.select_region(region.id)
		screen.picker.hide()
		screen.set_inspection("isolated")
		regions = screen.preview.model.find_children("Region_*", "Node3D", true, false)
		check(regions.filter(func(n: Node3D) -> bool: return n.visible).size() == 1, "Isolation hides other regions: " + region.id)
		check(screen.preview.inspection_size > 0, "Isolated camera frames geometry: " + region.id)
		if region.id == "head": await capture("kestrel-workshop/isolated-head", 6)
	await capture("kestrel-workshop/isolated-wings", 6)
	screen.set_inspection("assembled")
	screen.set_camera_angle(0)
	await physics_frame
	var selected: Array[String] = []
	screen.preview.region_selected.connect(func(id: String) -> void: selected.append(id))
	var head_point := screen.preview.camera.unproject_position(screen.preview.rig.to_global(Vector3(0,1.30,-.15)))
	screen.preview.pick_region(head_point)
	check("head" in selected, "Camera-projected click picks the Kestrel head")
	screen.picker.hide()
	var chest := screen.preview.model.find_child("Chest_fuselage", true, false) as MeshInstance3D
	check(WorkshopAppearance.surface_colour(chest,0).is_equal_approx(Color("263c56")), "Factory finish preserves navy armour")
	var uid: String = screen.draft.installed["torso.armour"]
	screen.draft.part_finishes[uid] = "winter"
	screen.refresh()
	check(screen.frame_choice.disabled, "Pending changes block frame switching")
	chest = screen.preview.model.find_child("Chest_fuselage", true, false)
	var winter := WorkshopAppearance.finish_by_id("winter")
	check(WorkshopAppearance.surface_colour(chest,0).is_equal_approx(Color(winter.primary)), "Per-component paint reaches Kestrel armour")
	screen.apply_refit()
	check(FileAccess.file_exists(kestrel.save_path) and not screen.frame_choice.disabled, "Apply saves the Kestrel and enables switching")
	var restored := WorkshopState.new(kestrel.save_path, "hx7_kestrel")
	check(restored.load_save() and restored.owned.part_finishes[uid] == "winter", "Kestrel customisation survives a save/load round trip")
	var spare := screen.store.spare_of("hx7_sensor_standard", screen.draft)
	var trial := screen.store.with_part(screen.draft,"head.sensor",spare)
	check(screen.store.validate(trial).is_empty() and screen.store.cost(trial) == WorkshopState.LABOUR, "Factory replacement part is mount-compatible and charges fitting labour")
	check(not screen.store.parts.has("arm_cannon"), "Kestrel inventory excludes Teamster upgrades")
	screen.select_frame(0)
	await frames(4)
	check(screen.store == team and screen.preview.animator != null, "Switching back restores the Teamster and animation controls")
	check(team.owned.part_finishes.is_empty() and not FileAccess.file_exists(team.save_path), "Kestrel edits do not overwrite the Teamster")
	screen.select_frame(1)
	await frames(4)
	check(screen.store.owned.part_finishes[uid] == "winter", "Returning restores the saved Kestrel finish")
	root.size = Vector2i(1440,900)
	await frames(4)
	check(screen.preview.get_global_rect().size.x >= 240, "Model bay retains usable width at 1440 by 900")
	check(screen.frame_choice.get_global_rect().end.x < screen.credits_label.get_global_rect().position.x, "Frame selector does not overlap the credits")
	await capture("kestrel-workshop/workshop-1440", 6)
	# Configure the real squad loadouts and record damage against the selected frame.
	session.active = true
	var catalogue := Catalogue.new()
	session.configure(catalogue)
	var loadouts: Array = catalogue.loadouts.filter(func(n: UnitLoadout) -> bool: return n.id == "blue_kestrel")
	check(loadouts.size() == 1 and loadouts[0].workshop_part_finishes.has("Component_torso_armour"), "Deployment applies finishes to the Kestrel loadout")
	var team_loadouts: Array = catalogue.loadouts.filter(func(n: UnitLoadout) -> bool: return n.id == "blue_teamster")
	check(team_loadouts[0].workshop_finish.is_empty(), "Kestrel deployment leaves the Teamster loadout standard")
	# Use the same catalogue battle construction as the existing workshop tests.
	var game: BattleController = load("res://battle/world/Battlefield.tscn").instantiate()
	root.add_child(game)
	await frames(8)
	game.manager.paused = true
	var actor: UnitActor = game.actors["blue_kestrel"]
	check(actor.animation is KestrelAnimator, "Battle actor uses the Kestrel animator")
	check(actor.animation.player.current_animation == "hover", "Airborne deployment starts in hover")
	var before := JSON.stringify(game.manager.battle.to_dict())
	for pair in [["lr3_rifle","fire_rifle"],["agm_stores","fire_missiles"],["vb2_knife","fire_knife"]]:
		actor.fire_animation(pair[0])
		check(actor.animation.player.current_animation == pair[1], "Battle weapon event selects " + pair[1])
	check(before == JSON.stringify(game.manager.battle.to_dict()), "Animation playback leaves authoritative battle state unchanged")
	var mech := game.manager.battle.unit_by_id("blue_kestrel")
	mech.structure = mech.loadout.frame.structure - 9
	session.battle_id = "kestrel-workshop-qa"
	check(session.capture_result(game.manager.battle) and kestrel.owned.hull_damage == 9, "Sortie return records damage on the Kestrel")
	check(team.owned.hull_damage == 14, "Kestrel sortie leaves Teamster damage unchanged")
	session.active = false
	game.queue_free()
	await frames(4)
	finish()
