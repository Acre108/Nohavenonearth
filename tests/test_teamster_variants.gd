extends "res://tests/test_suite.gd"
const SAVE := "res://artifacts/variants-test-save.json"

func make_model(fit: Dictionary) -> Node3D:
	var model := Node3D.new()
	root.add_child(model)
	UnitModelFactory.build_model(model, "ground", ArtPalette.FRIEND, "m9_teamster")
	TeamsterParts.apply(model, fit)
	WorkshopAppearance.apply(model, WorkshopAppearance.finish_by_id("depot"), "", fit.get("backpack.module") == "module_recovery")
	return model

func run() -> void:
	var store := WorkshopState.new(SAVE)
	var edit := store.draft()
	edit.installed["right_arm.actuator"] = "spare_arm_marksman"
	check(store.validate(edit).contains("requires"), "Two-handed rifle cannot be applied without a support arm")
	check(not store.apply(edit), "Incomplete paired kit cannot commit")
	edit.installed["left_arm.actuator"] = "spare_arm_support"
	check(store.validate(edit).is_empty(), "Complete paired kit is legal")
	check(store.weapon_ids(edit).has("br90_rifle") and not store.weapon_ids(edit).has("ar40_rifle") and not store.weapon_ids(edit).has("pb4_stake"), "Two-handed rifle replaces both original arm weapons")
	check(is_equal_approx(store.budget(edit).reserved, 0.75), "Both arm components reserve their Energy")
	check(not store.compatibility(store.parts.arm_support, "right_arm.actuator").is_empty(), "Support assembly respects its side-specific mount")
	check(store.apply(edit), "Paired kit saves")
	var loaded := WorkshopState.new(SAVE)
	check(loaded.load_save() and TeamsterParts.two_handed(loaded.fit_parts(loaded.draft())), "Paired kit survives reload")
	var session := root.get_node("WorkshopSession")
	var previous_store: WorkshopState = session.store
	var previous_active: bool = session.active
	session.store = store
	session.active = true
	var catalogue := Catalogue.new()
	session.configure(catalogue)
	var battle := BattleState.new(catalogue, 42)
	var unit := battle.unit_by_id("blue_teamster")
	check(unit.loadout.weapons.any(func(w: WeaponData) -> bool: return w.id == "br90_rifle") and not unit.loadout.weapons.any(func(w: WeaponData) -> bool: return w.id in ["ar40_rifle", "pb4_stake"]), "Deployment mounts BR-90 and stows both original arm weapons")
	check(TeamsterParts.two_handed(unit.loadout.workshop_parts), "Deployment carries the paired visual configuration")
	battle.terrain.clear()
	unit.position = Vector2.ZERO
	unit.facing = 0
	var foe := battle.unit_by_id("red_medved")
	foe.position = Vector2(0,-3)
	check(CombatRules.target_error(battle, unit, foe, catalogue.weapons.br90_rifle).is_empty(), "New rifle is usable through normal targeting rules")
	unit.energy = 0.75
	check(CombatRules.target_error(battle, unit, foe, catalogue.weapons.br90_rifle) == "Insufficient Energy.", "Fractional remaining Energy cannot pay for a full-Energy rifle attack")
	session.store = previous_store
	session.active = previous_active
	var model := make_model(store.fit_parts(edit))
	var animator := TeamsterAnimator.new()
	model.add_child(animator)
	animator.two_handed = true
	animator.setup(model)
	animator.flashes_enabled = false
	var left: Node3D = model.find_child("Joint_left_wrist_actuator", true, false)
	var grip: Node3D = model.find_child("Socket_twohand_support", true, false)
	for clip in ["twohand_idle", "twohand_walk", "twohand_ready", "twohand_fire", "twohand_turn_left", "twohand_turn_right"]:
		for fraction in [0.0, 0.25, 0.5, 0.75, 1.0]:
			animator.play(clip, 0)
			animator.player.seek(animator.player.get_animation(clip).length * fraction, true)
			check(left.global_position.distance_to(grip.global_position) < 0.006, "%s keeps support hand at foregrip, phase %s" % [clip, str(fraction)])
	animator.play("twohand_reload", 0)
	animator.player.seek(1.0, true)
	check(left.global_position.distance_to(grip.global_position) > 0.10, "Reload releases the support hand toward the magazine")
	animator.player.seek(2.0, true)
	check(left.global_position.distance_to(grip.global_position) < 0.006, "Reload returns the hand to the foregrip")
	animator.walk(1)
	check(animator.player.current_animation == "twohand_walk", "Paired loadout uses a stabilised walk")
	animator.fire("br90_rifle")
	check(animator.player.current_animation == "twohand_fire", "BR-90 attack selects its paired recoil clip")
	check(animator.socket("br90_rifle") != null and animator.socket("br90_rifle").is_visible_in_tree(), "BR-90 has a visible moving muzzle socket")
	check(not model.find_child("AR40_Longhorn", true, false).is_visible_in_tree() and not model.find_child("PB4_Stake_driver", true, false).is_visible_in_tree(), "Paired kit stows stock rifle and stake geometry")
	model.free()
	var all_parts := {"head.sensor":"sensor_precision", "torso.structure":"structure_braced", "torso.armour":"torso_heavy",
		"left_arm.actuator":"arm_support", "right_arm.actuator":"arm_marksman", "left_arm.armour":"arm_reinforced", "right_arm.armour":"arm_reinforced",
		"left_leg.drive":"leg_fast", "right_leg.drive":"leg_fast", "left_leg.armour":"leg_braced", "right_leg.armour":"leg_braced",
		"power.plant":"power_buffered", "backpack.service":"service_upgraded", "backpack.module":"module_recovery"}
	model = make_model(all_parts)
	for region in store.regions:
		var node := model.find_child("Region_" + region.id, true, false)
		check(node.find_children("Variant_*", "Node3D", true, false).size() > 0, region.id + " has visible alternate geometry")
		check(node.get_children().filter(func(n: Node) -> bool: return String(n.name).begins_with("Component_")).size() <= 2, region.id + " retains the two-component limit")
	model.free()
	for pair in [["arm_cannon","right_arm.actuator","ac30_cannon","fire_cannon"],["arm_breacher","left_arm.actuator","sg12_breacher","fire_breacher"]]:
		model = make_model({pair[1]:pair[0]})
		animator = TeamsterAnimator.new()
		model.add_child(animator)
		animator.setup(model)
		animator.fire(pair[2])
		check(animator.player.current_animation == pair[3], pair[0] + " selects its weapon animation")
		check(animator.socket(pair[2]) != null, pair[0] + " has its own muzzle socket")
		model.free()
	# Existing demo saves gain the new spares once while keeping resources and installed gear.
	var old := store.initial_state()
	old.erase("content_revision")
	for uid in WorkshopState.NEW_SPARES: old.inventory.erase(uid)
	check(store.write_state(old, SAVE), "Legacy save fixture writes")
	check(loaded.load_save() and loaded.owned.credits == old.credits and loaded.owned.installed == old.installed, "Content migration preserves funds and installed equipment")
	check(loaded.owned.inventory.has("spare_arm_marksman") and loaded.owned.inventory.has("spare_arm_support"), "Content migration provides the new demo kit")
	DirAccess.remove_absolute(SAVE)
	finish()
