extends "res://tests/test_suite.gd"

const SAVE := "res://artifacts/workshop-test.json"

func run() -> void:
	var store := WorkshopState.new()
	var catalogue := Catalogue.new()
	var base: FrameData = catalogue.frames.m9_teamster
	check(store.slots.size() == 14, "Teamster has fourteen installed components")
	for region in store.regions:
		check(region.slots.size() <= 2, region.id + " never exceeds two components")
	check(store.validate_state(store.owned).is_empty(), "Initial owned state is valid")
	var edit := store.draft()
	check(store.cost(edit) == 0 and not store.changed(edit), "Unedited draft is free and clean")
	check(store.resolve(base, edit).stat_fractions.get("melee") == -0.25, "Damaged actuator applies its declared penalty as a fraction")
	edit.repairs.append(edit.installed["left_arm.actuator"])
	edit.repair_hull = true
	check(store.cost(edit) == 202, "Repairs quote exact hull and component costs")
	var standard := store.resolve(base, edit)
	for key in WorkshopState.FRAME_STATS:
		check(standard.get(key) == base.get(key), "Standard fit preserves " + key)
	check(standard.stat_bonuses.get("melee", 0) == 0, "Repair removes the wear penalty")
	check(base.stat_bonuses.hash() == Catalogue.new().frames.m9_teamster.stat_bonuses.hash() and base.structure == 72, "Resolver leaves shared frame untouched")
	check(store.owned.credits == 1800 and store.owned.hull_damage == 14, "Preview does not mutate resources")
	check(store.apply(edit, SAVE), "Repair transaction saves")
	check(store.owned.credits == 1598 and store.owned.hull_damage == 0, "Repair applies once at quoted cost")
	var reloaded := WorkshopState.new()
	check(reloaded.load_save(SAVE), "Saved configuration reloads")
	check(reloaded.owned == store.owned, "Reload round trips every owned field")
	edit = store.draft()
	var original_uid: String = edit.installed["left_arm.actuator"]
	edit.installed["left_arm.actuator"] = "spare_arm_precision"
	check(store.cost(edit) == 40, "One replacement has one fitting charge")
	check(store.resolve(base, edit).stat_fractions.gunnery == 0.25, "Replacement changes resolved hardware stats")
	check(store.apply(edit, SAVE), "Replacement saves over an existing save")
	check(store.owned.inventory.has(original_uid) and original_uid not in store.owned.installed.values(), "Removed part returns to stores")
	var before := JSON.stringify(store.owned)
	edit = store.draft()
	edit.installed["right_arm.actuator"] = edit.installed["left_arm.actuator"]
	check(not store.apply(edit, SAVE), "Same owned part cannot equip both arms")
	check(JSON.stringify(store.owned) == before, "Rejected duplicate refit is atomic")
	edit = store.draft()
	edit.installed["head.sensor"] = "spare_foreign_sensor"
	check(not store.apply(edit, SAVE), "Wrong-interface components are rejected")
	check(JSON.stringify(store.owned) == before, "Rejected incompatible refit is atomic")
	edit = store.draft()
	edit.finish = "winter"
	check(store.cost(edit) == 0 and store.apply(edit, SAVE), "Cosmetic changes save without a fitting fee")
	edit = store.draft()
	edit.installed["torso.armour"] = "spare_torso_heavy"
	store.owned.credits = 0
	check(not store.apply(edit, SAVE), "Unaffordable refit is rejected")
	check(store.owned.installed["torso.armour"] != "spare_torso_heavy", "Unaffordable refit does not equip the part")
	store.owned.credits = 1000
	check(not store.apply(edit, "res://artifacts/missing-directory/workshop.json"), "Filesystem failure rejects commit")
	check(store.owned.credits == 1000 and store.owned.installed["torso.armour"] != "spare_torso_heavy", "Failed save leaves resources and inventory intact")
	check(store.record_result("sortie-one", 29, SAVE), "Battle hull damage persists")
	check(not store.record_result("sortie-one", 0, SAVE) and store.owned.hull_damage == 29, "Repeated battle result cannot erase damage")
	edit = store.draft()
	store.owned.inventory[edit.installed["power.plant"]].integrity = 0
	check(not store.readiness(base, edit).is_empty(), "Disabled essential component blocks deployment")
	store.owned.inventory[edit.installed["power.plant"]].integrity = 100
	store.owned.hull_damage = 100
	check(not store.readiness(base, edit).is_empty(), "Destroyed hull blocks deployment")
	store.owned.hull_damage = 0
	# Exercise the real deployment adapter without altering the player's save.
	var session := root.get_node("WorkshopSession")
	var previous_store: WorkshopState = session.store
	session.store = store
	session.active = true
	edit = store.draft()
	edit.installed["backpack.module"] = "spare_module_recovery"
	edit.finish = "winter"
	check(store.apply(edit, SAVE), "Recovery module refit applies")
	session.configure(catalogue)
	var battle := BattleState.new(catalogue, 42)
	var teamster := battle.unit_by_id("blue_teamster")
	check(teamster.loadout.frame.structure == 77 and teamster.structure == 77, "Deployment receives resolved Structure")
	check(teamster.loadout.weapons.size() == 3 and teamster.loadout.weapons[-1].id == "hands_medium" and not teamster.loadout.weapons.any(func(w: WeaponData) -> bool: return w.id == "hornet_pod"), "Recovery module removes missile weapon; hands stay")
	check(teamster.loadout.workshop_finish == "winter", "Deployment receives paint finish")
	check(Catalogue.new().frames.m9_teamster.structure == 72, "Workshop does not alter standalone catalogue")
	session.active = false
	session.store = previous_store
	var corrupt := FileAccess.open(SAVE, FileAccess.WRITE)
	corrupt.store_string("{broken")
	corrupt.close()
	before = JSON.stringify(store.owned)
	check(not store.load_save(SAVE) and JSON.stringify(store.owned) == before, "Corrupt save is reported without mutating state")
	DirAccess.remove_absolute(SAVE)
	test_power_and_compatibility()
	test_component_finishes()
	test_workshop_pilots()
	finish()

func test_workshop_pilots() -> void:
	var store := WorkshopState.new(SAVE)
	check(store.pilots.entries.size() == 3, "Workshop has three pilot profiles")
	for entry in store.pilots.entries.values():
		var total := 0.0
		for value in entry.stats.values(): total += value
		check(total == 7.0, entry.id + " uses the same seven-point stat budget")
		check(ResourceLoader.exists(entry.portrait), entry.id + " has an imported generated portrait")
	var edit := store.draft()
	edit.pilot = "rook"
	check(store.changed(edit) and store.cost(edit) == 0 and store.owned.pilot == "anchor", "Pilot reassignment is a free detached draft change")
	check(store.apply(edit), "Pilot reassignment saves")
	var reloaded := WorkshopState.new(SAVE)
	check(reloaded.load_save() and reloaded.draft().pilot == "rook", "Pilot assignment survives a save/load")
	var session := root.get_node("WorkshopSession")
	var previous_store: WorkshopState = session.store
	session.store = reloaded
	session.active = true
	var catalogue := Catalogue.new()
	session.configure(catalogue)
	var unit := BattleState.new(catalogue,42).unit_by_id("blue_teamster")
	check(unit.loadout.pilot.id == "rook" and unit.loadout.callsign == "ROOK", "Deployment receives selected pilot and callsign")
	for stat in UnitState.STAT_NAMES:
		var fractions := UnitState.toward_zero(unit.loadout.frame.stat_fractions.get(stat,0))
		var expected := clampf(reloaded.pilots.entries.rook.stats[stat] + unit.loadout.frame.stat_bonuses.get(stat,0) + fractions,0,unit.stat_max(stat))
		check(unit.stat(stat) == expected, "Deployed " + stat + " uses capped pilot plus frame and equipment")
	unit.loadout.pilot.stats.gunnery = 4
	check(reloaded.pilots.entries.rook.stats.gunnery == 1 and Catalogue.new().pilots.anchor.stats.gunnery == 1, "Deployment pilot is detached from roster and standalone catalogue")
	edit = reloaded.draft()
	edit.pilot = "unknown"
	var before := JSON.stringify(reloaded.owned)
	check(not reloaded.apply(edit) and JSON.stringify(reloaded.owned) == before, "Unknown pilot assignment is rejected atomically")
	var legacy := reloaded.owned.duplicate(true)
	legacy.erase("pilot")
	check(reloaded.write_state(legacy,SAVE) and reloaded.load_save() and reloaded.owned.pilot == "anchor", "Old workshop saves acquire Anchor by default")
	session.active = false
	session.store = previous_store
	DirAccess.remove_absolute(SAVE)

func test_component_finishes() -> void:
	var store := WorkshopState.new(SAVE)
	var edit := store.draft()
	var uid: String = edit.installed["head.sensor"]
	edit.part_finishes[uid] = "desert"
	check(store.changed(edit) and store.cost(edit) == 0, "Per-component finish is a free draft change")
	check(store.owned.part_finishes.is_empty(), "Custom finish draft is detached from owned inventory")
	check(store.fit_finishes(edit).Component_head_sensor.primary == "ac9870", "Visual adapter resolves only the customised component")
	check(store.apply(edit), "Component finish transaction saves")
	var reloaded := WorkshopState.new(SAVE)
	check(reloaded.load_save() and reloaded.draft().part_finishes == edit.part_finishes, "Custom finishes persist through a full save/load")
	edit = store.draft()
	edit.installed["head.sensor"] = "spare_sensor_precision"
	check(store.apply(edit), "Customised component can return to stores")
	check(store.fit_finishes(store.draft()).is_empty() and store.owned.part_finishes.has(uid), "Customisation follows the owned part, not its slot")
	edit = store.draft()
	edit.part_finishes["unknown_uid"] = "desert"
	check(not store.validate(edit).is_empty(), "Unknown customisation target is rejected")
	edit = store.draft()
	edit.part_finishes[uid] = "unknown_finish"
	check(not store.validate(edit).is_empty(), "Unknown component finish is rejected")
	var legacy := store.owned.duplicate(true)
	legacy.erase("part_finishes")
	check(store.write_state(legacy, SAVE) and reloaded.load_save() and reloaded.owned.part_finishes.is_empty(), "Existing saves migrate with factory finishes")
	DirAccess.remove_absolute(SAVE)

func test_power_and_compatibility() -> void:
	var store := WorkshopState.new(SAVE)
	var base: FrameData = Catalogue.new().frames.m9_teamster
	check(base.manufacturer == "brannock_hale" and base.size_class == "medium", "Teamster carries its manufacturer and existing frame size")
	for part in store.parts.values():
		check(store.manufacturers.has(part.manufacturer) and SizeClass.valid(part.size_class), part.id + " has a known manufacturer and size")
		check(part.energy_reservation >= 0 and is_equal_approx(part.energy_reservation * 4, roundf(part.energy_reservation * 4)), part.id + " reserves nonnegative quarter Energy")
	check(store.compatibility(store.parts.foreign_sensor, "head.sensor").begins_with("Manufacturer"), "Manufacturer restriction is independent of the mount family")
	check(store.compatibility(store.parts.oversize_arm, "left_arm.actuator").begins_with("Size"), "Same-brand mount does not bypass size matching")
	var large: FrameData = base.duplicate(true)
	large.size_class = "large"
	check(store.compatibility(store.parts.arm_standard, "left_arm.actuator", large).begins_with("Size"), "Smaller components also fail exact frame-size matching")
	large = base.duplicate(true)
	large.compatible_manufacturers.assign(["brannock_hale", "halcyon"])
	check(store.compatibility(store.parts.foreign_sensor, "head.sensor", large).is_empty(), "An explicit licensed manufacturer can be accepted")
	var edit := store.draft()
	edit.repair_hull = true
	edit.repairs.append(edit.installed["left_arm.actuator"])
	edit.installed["head.sensor"] = "spare_sensor_precision"
	var resolved := store.resolve(base, edit)
	check(resolved.energy_capacity == 3 and resolved.energy_reserved == 0.5 and resolved.energy_available() == 2.5, "Hardware reserves a fraction without changing the plant's rated capacity")
	check(base.energy_reserved == 0, "Resolution never reserves energy on shared definitions")
	var loadout: UnitLoadout
	for candidate in Catalogue.new().loadouts:
		if candidate.id == "blue_teamster": loadout = candidate
	loadout.frame = resolved
	var unit := UnitState.new(loadout)
	check(unit.energy == 2.5, "Battle starts with exact fractional available Energy")
	unit.energy -= 2
	check(unit.energy == 0.5, "Spending whole Energy retains the fractional remainder")
	var manager := TurnManager.new()
	manager.ai_enabled = false
	var data := Catalogue.new()
	for candidate in data.loadouts:
		if candidate.id == "blue_teamster": candidate.frame = resolved
	manager.setup(42, data)
	var mech := manager.battle.unit_by_id("blue_teamster")
	mech.energy = 2.0
	manager.phase = TurnManager.Phase.END
	manager.advance()
	check(mech.energy == 2.5, "End-of-round recharge stops at fractional usable maximum")
	manager.free()
	edit.installed["left_arm.actuator"] = "spare_arm_precision"
	edit.installed["left_leg.drive"] = "spare_leg_fast"
	# Give the right leg its own instance; inventory ownership still applies.
	store.owned.inventory["second_march_drive"] = {"part":"leg_fast", "integrity":100}
	edit.installed["right_leg.drive"] = "second_march_drive"
	edit.installed["backpack.service"] = "spare_service_upgraded"
	check(store.budget(edit).reserved == 3.25 and not store.budget(edit).valid, "Intensive parts can exceed the plant budget")
	var before := JSON.stringify(store.owned)
	check(not store.apply(edit) and store.error.begins_with("Energy budget exceeded"), "Overbudget refit is rejected with a reason")
	check(JSON.stringify(store.owned) == before, "Overbudget rejection never consumes parts or funds")
	check(not store.readiness(base, edit).is_empty(), "Overbudget loaded configuration cannot deploy")
	edit.installed["power.plant"] = "spare_power_buffered"
	check(store.budget(edit).valid and store.budget(edit).available == 1.75, "Larger plant can support the same intensive fit")
	check(store.apply(edit), "Valid intensive fit can be applied")
	var reload := WorkshopState.new(SAVE)
	check(reload.load_save() and reload.budget(reload.draft()).reserved == 3.25, "Reservations resolve consistently after saving and loading")
	DirAccess.remove_absolute(SAVE)
