extends SceneTree

var passed: int = 0
var failed: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL / " + description)

func fresh(seed_value: int = 42) -> BattleState:
	return BattleState.new(Catalogue.new(), seed_value)

func isolate(battle: BattleState, ids: Array[String]) -> void:
	battle.terrain.clear()
	for unit in battle.units:
		if unit.loadout.id not in ids:
			unit.structure = 0

func run() -> void:
	test_catalogue_validation()
	test_stats()
	test_long_skirmish_setup()
	test_movement()
	test_terrain()
	test_wreckage()
	test_combat()
	test_melee()
	test_size_and_hands()
	test_charge_and_engagement()
	test_forecast()
	test_abilities_and_locks()
	test_turns()
	test_attack_skipping()
	test_horizontal_range()
	for seed_value in range(1, 9):
		test_full_battle(seed_value)
	print("RULE TESTS / %d passed / %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func test_catalogue_validation() -> void:
	var definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/catalogues/standard.json"))
	var scenario: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/skirmish.json"))
	check(Catalogue.new().errors.is_empty(), "Default scenario loads its shared catalogue")
	check(CatalogueValidator.validate(definitions, scenario).is_empty(), "Shipped content validates")
	var broken := definitions.duplicate(true)
	broken.weapons.append(broken.weapons[0].duplicate(true))
	check(not CatalogueValidator.validate(broken, scenario).is_empty(), "Duplicate definition IDs are rejected")
	broken = definitions.duplicate(true)
	broken.frames[0].manoeuvres.append("missing_move")
	check(not CatalogueValidator.validate(broken, scenario).is_empty(), "Unknown frame manoeuvres are rejected")
	var deployment := scenario.duplicate(true)
	deployment.units[0].pilot = "missing_pilot"
	check(not CatalogueValidator.validate(definitions, deployment).is_empty(), "Unknown deployment pilots are rejected")
	deployment = scenario.duplicate(true)
	deployment.units[0].weapons = ["missing_weapon"]
	check(not CatalogueValidator.validate(definitions, deployment).is_empty(), "Unknown deployment weapons are rejected")
	deployment = scenario.duplicate(true)
	deployment.battlefield.size = [0, 26]
	check(not CatalogueValidator.validate(definitions, deployment).is_empty(), "Empty battlefield bounds are rejected")
	deployment = scenario.duplicate(true)
	deployment.units[0].start_position = ["invalid", 0]
	check(not CatalogueValidator.validate(definitions, deployment).is_empty(), "Malformed deployment coordinates are rejected")

func test_stats() -> void:
	var battle := fresh()
	check(battle.units.size() == 7, "Seven loadouts spawn")
	var ace := battle.units[0]
	var values: Array = []
	for stat in UnitState.STAT_NAMES:
		values.append(ace.stat(stat))
	# Gunnery, Melee, Precision, Reflex (1 + Kestrel 2), Guard, Systems (1 + 1), Countermeasures (1 + 1), Spirit.
	check(values == [2.0, 2.0, 2.0, 3.0, 1.0, 2.0, 2.0, 4.0], "Ace totals are pilot plus Kestrel bonus")
	check(ace.will == 4 and ace.will_max() == 4, "Spirit sets maximum Will")
	ace.pilot_stats.reflex = 0
	check(ace.stat("reflex") == 2 and int(ace.loadout.pilot.stats.reflex) == 1, "Debug overrides do not mutate base Resource")
	check(fresh().units[0].stat("reflex") == 3, "New battle resets overrides")
	ace.pilot_stats.reflex = 5
	check(ace.stat("reflex") == float(ace.loadout.frame.stat_max.reflex) and ace.stat_max("reflex") == 4, "Frame max caps the total")
	ace.pilot_stats.spirit = 3.0 - 0.000001
	check(ace.whole_stat("spirit") == 3, "Float error never loses a whole point")
	ace.pilot_stats.gunnery = 2
	ace.bonus_stats.gunnery = 0.3
	check(ace.stat("gunnery") == 2.25, "Stats resolve to quarter points")
	ace.bonus_stats.gunnery = 10
	check(ace.stat("gunnery") == UnitState.STAT_CAPS.gunnery, "Pilot plus bonuses is capped")
	var teamster := battle.units[1]
	teamster.bonus_stats.gunnery = 10
	check(teamster.stat("gunnery") == 3.0, "A lower frame max caps below the global cap")
	var ground: ManoeuvreData = battle.catalogue.manoeuvres.ground
	teamster.pilot_stats.reflex = 2
	check(is_equal_approx(MovementRules.maximum_distance(teamster, ground), teamster.loadout.frame.base_move), "Reflex no longer changes move distance")
	check(ace.stat("systems") > 0 and "systems" in UnitState.RESERVED_STATS and "countermeasures" in UnitState.RESERVED_STATS, "Electronic stats are stored but reserved")
	var queue := battle.initiative(false)
	for i in range(1, queue.size()):
		check(queue[i - 1].stat("reflex") >= queue[i].stat("reflex"), "Initiative runs from highest Reflex")
	check(not battle.to_dict().units.is_empty(), "Battle state serialisation boundary")

func test_movement() -> void:
	var battle := fresh()
	isolate(battle, ["blue_kestrel", "blue_teamster", "red_medved"])
	var ace := battle.units[0]
	var ground := battle.units[1]
	var enemy := battle.units[3]
	ground.position = Vector2(-5, 0)
	enemy.position = Vector2(8, 5)
	var ground_move: ManoeuvreData = battle.catalogue.manoeuvres.ground
	check(MovementRules.create_order(battle, ground, ground_move, Vector2(-3, 0), 180).valid, "Ground moves freely and turns 180")
	check(not MovementRules.create_order(battle, ground, ground_move, Vector2(0, 0)).valid, "Ground distance limit")
	ace.position = Vector2(-4, 0)
	ace.altitude = 0
	check(MovementRules.create_order(battle, ground, ground_move, Vector2(-2.5, 0)).valid, "Ground may pass through friendlies")
	check(not MovementRules.create_order(battle, ground, ground_move, ace.position).valid, "Cannot end on a friendly")
	ace.altitude = 1
	check(MovementRules.create_order(battle, ground, ground_move, ace.position).valid, "Different altitude bands may overlap horizontally")
	ace.position = Vector2(0, 0)
	ace.facing = 0
	var cruise: ManoeuvreData = battle.catalogue.manoeuvres.cruise
	check(MovementRules.create_order(battle, ace, cruise, Vector2(0, -3), 45).valid, "Cruise forward and turn")
	check(not MovementRules.create_order(battle, ace, cruise, Vector2(3, 0)).valid, "Cruise cannot move sideways")
	check(not MovementRules.create_order(battle, ace, cruise, Vector2(0, -0.5)).valid, "Flying minimum movement")
	var lateral: ManoeuvreData = battle.catalogue.manoeuvres.lateral
	check(MovementRules.create_order(battle, ace, lateral, Vector2(2, 0)).valid, "Lateral Thrust")
	for stat in UnitState.STAT_NAMES:
		ace.pilot_stats[stat] = 0
	check(MovementRules.create_order(battle, ace, lateral, Vector2(2, 0)).valid, "No stat opens or closes a manoeuvre")
	ace.altitude = 0
	check(MovementRules.available(battle, ace).size() == ace.loadout.frame.manoeuvres.size(), "Every frame manoeuvre is available with all stats at 0")
	ace.altitude = 1
	ace.energy = 0
	check(not MovementRules.create_order(battle, ace, lateral, Vector2(2, 0)).valid, "Movement requires Energy")
	ace.energy = 5
	var reverse: ManoeuvreData = battle.catalogue.manoeuvres.reverse
	ace.order = MovementRules.create_order(battle, ace, reverse, Vector2(0, 2), 90)
	check(ace.order.valid, "Reverse Vector legal")
	MovementRules.resolve(battle, ace)
	check(ace.position.is_equal_approx(Vector2(0, 2)) and ace.energy == 3, "Movement spends exact Energy")
	# Both orders are initially legal; earlier unit occupies the later endpoint.
	ground.position = Vector2(-4, -2)
	enemy.position = Vector2(0, -2)
	enemy.facing = -PI * 0.5
	ground.order = MovementRules.create_order(battle, ground, ground_move, Vector2(-2, -2))
	enemy.order = MovementRules.create_order(battle, enemy, ground_move, Vector2(-2, -2))
	check(ground.order.valid and enemy.order.valid, "Revealed destination conflict can arise")
	MovementRules.resolve(battle, ground)
	var resolution := MovementRules.resolve(battle, enemy)
	check("collision" in resolution.message and not MovementRules.overlaps(battle, enemy, enemy.position, 0), "Later unit stops before collision")
	var jet := battle.units[2]
	jet.structure = 5
	jet.position = Vector2(0, 5)
	jet.facing = 0
	var bank: ManoeuvreData = battle.catalogue.manoeuvres.bank_l
	var bank_order := MovementRules.create_order(battle, jet, bank, Vector2.ZERO)
	check(bank_order.valid and bank_order.path.size() == 65 and is_equal_approx(bank_order.facing, -PI / 4), "Aircraft curved path and final facing")
	jet.position = Vector2(0, battle.bounds.position.y + 1)
	jet.order = MovementRules.create_order(battle, jet, battle.catalogue.manoeuvres.straight4, Vector2.ZERO)
	check(jet.order.valid and jet.order.leaves_battlefield, "Aircraft boundary preview warns of withdrawal")
	MovementRules.resolve(battle, jet)
	check(not jet.alive(), "Aircraft leaving table withdraws instead of deadlocking planning")

func test_long_skirmish_setup() -> void:
	var battle := fresh()
	check(battle.bounds == Rect2(-18, -13, 36, 26), "Expanded battlefield loaded from scenario data")
	var expected := {"blue_kestrel": 60, "blue_teamster": 72, "blue_fighter": 14, "red_medved": 90, "red_tieshan": 72, "red_fighter": 14, "red_tank": 20}
	for unit in battle.units:
		check(unit.structure == expected[unit.loadout.id] and unit.loadout.frame.structure == expected[unit.loadout.id], "Units start at their frame Structure")
		check(battle.bounds.grow(-unit.loadout.frame.size).has_point(unit.position), "Deployment inside expanded table")
		check(not TerrainRules.blocks_point(battle, unit.position, unit.loadout.frame.size, unit.altitude), "Deployment clear of blocking terrain")
	check(battle.units[0].position.distance_to(battle.units[3].position) == 22, "Opening separation increased to 22 units")
	for unit in battle.living(0):
		for weapon in unit.loadout.weapons:
			check(CombatRules.legal_targets(battle, unit, weapon).is_empty(), "Deployment requires an approach before shooting")
	var ace := battle.units[0]
	ace.position = Vector2(-8, -4.5)
	ace.altitude = 0
	ace.facing = PI * 0.5
	var destination := Vector2(-4, -4.5)
	check(not MovementRules.create_order(battle, ace, battle.catalogue.manoeuvres.ground, destination).valid, "Low ruin blocks direct ground route")
	ace.altitude = 1
	check(MovementRules.create_order(battle, ace, battle.catalogue.manoeuvres.cruise, destination).valid, "Flying mech crosses same ruin at Low altitude")

func test_terrain() -> void:
	var battle := fresh()
	isolate(battle, ["blue_teamster", "red_medved"])
	var a := battle.units[1]
	var b := battle.units[3]
	a.position = Vector2(-2, 0)
	b.position = Vector2(2, 0)
	battle.terrain = [{"position": [0, 0], "half_size": [0.5, 0.5], "height": 3.0, "cover": 2, "blocks_move": true, "blocks_los": true}]
	check(not TerrainRules.line_of_sight(battle, a, b), "Building blocks centre-to-centre LOS")
	check(not MovementRules.create_order(battle, a, battle.catalogue.manoeuvres.ground, Vector2(1, 0)).valid, "Ground movement cannot pass through building")
	a.altitude = 2
	b.altitude = 2
	check(TerrainRules.line_of_sight(battle, a, b), "High-altitude LOS clears building")
	b.altitude = 0
	a.altitude = 0
	b.position = Vector2(0.9, 0)
	check(TerrainRules.cover(battle, a, b) == 2, "Heavy cover bonus")
	b.altitude = 1
	check(TerrainRules.cover(battle, a, b) == 2, "Tall cover protects Low altitude")
	b.altitude = 2
	check(TerrainRules.cover(battle, a, b) == 0, "High altitude ignores cover")
	b.altitude = 0
	battle.terrain[0].height = 0.6
	battle.terrain[0].cover = 1
	check(TerrainRules.cover(battle, a, b) == 1, "Low cover bonus")
	b.altitude = 1
	check(TerrainRules.cover(battle, a, b) == 0, "Low barrier cannot cover a flying mech")

func test_wreckage() -> void:
	var battle := fresh()
	isolate(battle, ["blue_teamster", "blue_fighter", "red_medved", "red_tieshan"])
	var attacker := battle.units[1]
	var fighter := battle.units[2]
	var heavy := battle.units[3]
	var defender := battle.units[4]
	attacker.position = Vector2(-3, 0)
	heavy.position = Vector2.ZERO
	defender.position = Vector2(0.8, 0)
	defender.altitude = 0
	check(not battle.add_wreck(heavy), "Living mech leaves no wreck")
	check(TerrainRules.cover(battle, attacker, defender) == 0, "No cover before wreckage")
	heavy.structure = 0
	check(battle.add_wreck(heavy), "Destroyed mech leaves wreckage")
	check(not battle.add_wreck(heavy), "Wreckage is added once")
	check(TerrainRules.cover(battle, attacker, defender) == 1, "Mech wreckage gives +1 cover")
	defender.altitude = 1
	check(TerrainRules.cover(battle, attacker, defender) == 0, "Wreckage cannot cover Low altitude")
	defender.altitude = 0
	check(TerrainRules.line_of_sight(battle, attacker, defender), "Wreckage does not block LOS")
	check(not TerrainRules.blocks_point(battle, Vector2.ZERO, attacker.loadout.frame.size, 0), "Wreckage does not block movement")
	battle.remove_wreck(heavy)
	check(battle.wreck_index(heavy) < 0, "Wreckage removed")
	fighter.structure = 0
	check(not battle.add_wreck(fighter), "Aircraft debris is not cover")
	var flyer := battle.units[0]
	flyer.structure = 0
	flyer.withdrawn = true
	check(not battle.add_wreck(flyer), "Withdrawn unit leaves no wreck")
	flyer.withdrawn = false
	check(battle.add_wreck(flyer), "Destroyed flying mech leaves wreckage")

func test_combat() -> void:
	var battle := fresh()
	isolate(battle, ["blue_kestrel", "red_medved"])
	var ace := battle.units[0]
	var heavy := battle.units[3]
	ace.position = Vector2.ZERO
	ace.altitude = 0
	ace.facing = 0
	heavy.position = Vector2(0, -3)
	heavy.facing = PI
	var rifle: WeaponData = battle.catalogue.weapons.lr3_rifle
	check(CombatRules.target_error(battle, ace, heavy, rifle).is_empty(), "Legal target in range and arc")
	heavy.position = Vector2(3, 0)
	check("arc" in CombatRules.target_error(battle, ace, heavy, rifle), "90-degree front arc enforced")
	heavy.position = Vector2(0, -1)
	check("range" in CombatRules.target_error(battle, ace, heavy, rifle), "Minimum weapon range")
	heavy.position = Vector2(0, -3)
	# Medved: Reflex 0, Large (+10%), Armour 3 ballistic. LR-3 aims +10%. Every point moves the hit chance 10%.
	for gunnery in range(0, 5):
		ace.pilot_stats.gunnery = gunnery
		check(is_equal_approx(CombatRules.hit_chance(battle, ace, heavy, rifle), minf(90.0, 70.0 + 10.0 * gunnery)), "Gunnery %d is +%d%% to hit" % [gunnery, 10 * gunnery])
	ace.pilot_stats.gunnery = 2
	ace.pilot_stats.precision = 3
	check(is_equal_approx(CombatRules.crit_chance(ace), 30.0), "Each Precision point is +10% crit")
	ace.pilot_stats.precision = 2
	check(is_equal_approx(CombatRules.hit_chance(battle, heavy, ace, battle.catalogue.weapons.gsh6m_rotary), 30.0), "The target's Reflex lowers the attacker's hit chance")
	check(is_equal_approx(CombatRules.hit_chance(battle, heavy, ace, battle.catalogue.weapons.gsh6m_rotary) - CombatRules.hit_chance(battle, heavy, ace, battle.catalogue.weapons.grad_m), 0.0), "Weapons without an aim bonus share a hit chance")
	check(CombatRules.effective_armour(rifle, heavy) == 3, "Ballistic armour +2 vs ballistic, minus AP 2")
	check(CombatRules.effective_armour(battle.catalogue.weapons.ar40_rifle, heavy) == 5, "Matching armour type counts 2 higher")
	check(CombatRules.effective_armour(battle.catalogue.weapons.agm_stores, heavy) == 3, "Other damage types meet base armour")
	check(CombatRules.effective_armour(battle.catalogue.weapons.vb2_knife, heavy) == 2, "Armour piercing lowers armour")
	check(CombatRules.effective_armour(battle.catalogue.weapons.pb4_stake, ace) == 0, "Effective armour never drops below 0")
	check(CombatRules.shot_damage(rifle, 3, AttackResult.Shot.HIT) == 5, "Armour is subtracted from each hit")
	check(CombatRules.shot_damage(rifle, 3, AttackResult.Shot.CRIT) == 8, "A crit ignores armour")
	check(CombatRules.shot_damage(rifle, 3, AttackResult.Shot.GLANCE) == 1, "A glancing hit is half damage, then armour")
	check(CombatRules.shot_damage(battle.catalogue.weapons.type99_mg, 3, AttackResult.Shot.HIT) == 0, "Armour can stop light weapons outright")
	check(CombatRules.glance_chance(rifle, 60) == 20 and CombatRules.glance_chance(rifle, 90) == 10, "Heavy weapons glance within 20% of the hit chance")
	check(CombatRules.glance_chance(battle.catalogue.weapons.agm_stores, 60) == 0, "Only heavy weapons glance")
	var result := CombatRules.resolve(battle, ace, heavy, rifle)
	var total := 0
	for outcome in result.shots:
		total += CombatRules.shot_damage(rifle, CombatRules.effective_armour(rifle, heavy), outcome)
	check(result != null and result.shots.size() == rifle.shots and result.damage == total, "One roll per shot; damage is the sum of the shots")
	check(ace.energy == 4 and ace.attacked, "Attack consumes Energy and activation")
	check(CombatRules.resolve(battle, ace, heavy, rifle) == null, "Cannot attack twice")
	ace.attacked = false
	heavy.structure = 0
	check(CombatRules.resolve(battle, heavy, ace, battle.catalogue.weapons.grad_m) == null, "Destroyed units cannot attack")
	var counts := [0, 0, 0, 0]
	for i in 10000:
		counts[CombatRules.roll_shot(battle, 60.0, 20.0, 25.0)] += 1
	check(counts[AttackResult.Shot.MISS] > 1800 and counts[AttackResult.Shot.MISS] < 2200, "Seeded rolls miss about 20% at 60% hit / 20% glance")
	check(counts[AttackResult.Shot.GLANCE] > 1800 and counts[AttackResult.Shot.GLANCE] < 2200, "Seeded rolls glance about 20%")
	check(counts[AttackResult.Shot.CRIT] > 1300 and counts[AttackResult.Shot.CRIT] < 1700, "A quarter of hits crit at 25%")

## Size class sets base radius, model scale, how easy a frame is to hit, and what it can carry.
func test_size_and_hands() -> void:
	var battle := fresh()
	isolate(battle, ["blue_kestrel", "blue_fighter", "red_medved", "red_tank"])
	var ace := battle.units[0]
	var jet := battle.units[2]
	var medved := battle.units[3]
	var tank := battle.units[6]
	var stores: WeaponData = battle.catalogue.weapons.agm_stores
	for unit in [ace, jet, medved]:
		check(is_equal_approx(unit.loadout.frame.size, SizeClass.RADIUS[unit.loadout.frame.size_class]), "Base radius comes from the size class (%s)" % unit.loadout.id)
	check(is_equal_approx(medved.loadout.frame.model_scale(), 1.2) and is_equal_approx(jet.loadout.frame.model_scale(), 0.8), "Model scale follows size class")
	var base := 50.0 + 10.0 * (ace.stat("gunnery") - 0.0)
	check(is_equal_approx(CombatRules.hit_chance(battle, ace, medved, stores), base + 10.0), "Large targets are 10% easier to hit")
	check(is_equal_approx(CombatRules.hit_chance(battle, ace, jet, stores), clampf(base - 10.0 * jet.stat("reflex") - 10.0, 10, 90)), "Small targets are 10% harder to hit")
	check(SizeClass.HIT_MODIFIER.super_heavy == 20.0, "Super heavy targets are 20% easier to hit")
	check(SizeClass.can_carry("large", "medium") and not SizeClass.can_carry("small", "medium"), "Frames carry weapons up to their own size")
	var definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/catalogues/standard.json"))
	var scenario: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/skirmish.json"))
	for unit in scenario.units:
		if unit.frame == "fighter":
			unit.weapons = ["type09_cannon"]
			break
	check(CatalogueValidator.validate(definitions, scenario).any(func(message: String) -> bool: return message.contains("too big")), "Oversized weapons are rejected")
	var hands: WeaponData = battle.catalogue.weapons.hands_medium
	check(ace.loadout.weapons[-1] == hands and ace.loadout.weapons.count(hands) == 1, "Mech frames carry their hands after their loadout")
	check(medved.loadout.weapons[-1] == battle.catalogue.weapons.hands_large and battle.catalogue.weapons.hands_large.damage > hands.damage, "Bigger frames have harder-hitting hands")
	check(not jet.loadout.weapons.any(func(weapon: WeaponData) -> bool: return weapon.id.begins_with("hands")) and not tank.loadout.weapons.any(func(weapon: WeaponData) -> bool: return weapon.id.begins_with("hands")), "Aircraft and tanks have no hands")
	ace.energy = 0
	ace.position = Vector2.ZERO
	ace.altitude = 0
	ace.facing = 0
	medved.position = Vector2(0, -(ace.loadout.frame.size + medved.loadout.frame.size + 0.3))
	check(CombatRules.target_error(battle, ace, medved, battle.catalogue.weapons.vb2_knife).contains("Energy") and CombatRules.target_error(battle, ace, medved, hands).is_empty(), "Hands need no Energy")

## Melee range is measured from base edge to base edge, so it can actually reach a neighbouring unit.
func test_melee() -> void:
	var battle := fresh()
	isolate(battle, ["blue_kestrel", "red_tieshan"])
	var ace := battle.units[0]
	var tieshan := battle.units[4]
	var knife: WeaponData = battle.catalogue.weapons.vb2_knife
	ace.position = Vector2.ZERO
	ace.altitude = 0
	ace.facing = 0
	var contact := ace.loadout.frame.size + tieshan.loadout.frame.size
	tieshan.position = Vector2(0, -(contact + 0.5))
	check(CombatRules.target_error(battle, ace, tieshan, knife).is_empty(), "Melee reaches 0.5 beyond the bases")
	check(not MovementRules.overlaps(battle, ace, ace.position, 0), "Melee position does not overlap")
	tieshan.position.y -= 0.05
	check("range" in CombatRules.target_error(battle, ace, tieshan, knife), "Melee stops just past 0.5 from the base edge")
	tieshan.position.y += 0.05
	ace.altitude = 1
	check("range" in CombatRules.target_error(battle, ace, tieshan, knife), "Melee cannot reach another altitude band")
	ace.altitude = 0
	# Ace Melee 2 vs Tieshan Reflex 1 + WRAITH Guard 1, +10% because the Tieshan is Large.
	check(is_equal_approx(CombatRules.hit_chance(battle, ace, tieshan, knife), 60.0), "Guard and Reflex both defend against melee")
	tieshan.pilot_stats.guard = 3
	check(is_equal_approx(CombatRules.hit_chance(battle, ace, tieshan, knife), 40.0), "Each Guard point is −10% to be hit in melee")
	check(is_equal_approx(CombatRules.hit_chance(battle, ace, tieshan, battle.catalogue.weapons.lr3_rifle), 80.0), "Guard does not apply to ranged attacks")
	var radii := CombatRules.horizontal_range(knife, 0, CombatRules.reach_allowance(knife, ace, tieshan))
	check(is_equal_approx(radii.y, contact + 0.5), "Melee overlay includes the base allowance")

## The attack preview must agree with what resolve() actually rolls, including lock, Will rerolls and Push.
func test_forecast() -> void:
	var battle := fresh(7)
	isolate(battle, ["blue_kestrel", "red_medved"])
	var ace := battle.units[0]
	var heavy := battle.units[3]
	ace.position = Vector2.ZERO
	ace.altitude = 0
	ace.facing = 0
	heavy.position = Vector2(0, -3)
	for weapon: WeaponData in [battle.catalogue.weapons.lr3_rifle, battle.catalogue.weapons.agm_stores]:
		for powers in [[false, false], [true, false], [false, true], [true, true]]:
			var use_will: bool = powers[0]
			var push: bool = powers[1]
			ace.will = 4
			ace.locks.assign([heavy.loadout.id])
			heavy.structure = 10
			var odds := CombatRules.forecast(battle, ace, heavy, weapon, use_will, push)
			check(ace.will == 4 and ace.locks.size() == 1 and heavy.structure == 10, "Forecast spends nothing")
			var trials := 6000
			var total := 0.0
			var damaged := 0
			var destroyed := 0
			for i in trials:
				ace.attacked = false
				ace.energy = 5
				ace.will = 4
				ace.locks.assign([heavy.loadout.id])
				heavy.structure = 10
				var result := CombatRules.resolve(battle, ace, heavy, weapon, use_will, Callable(), push)
				total += result.damage
				damaged += int(result.damage > 0)
				destroyed += int(result.destroyed)
			var label := "%s will %s push %s" % [weapon.id, use_will, push]
			check(absf(total / trials - odds.expected) < 0.25, "Forecast expected damage matches rolls (%s: %.2f vs %.2f)" % [label, total / trials, odds.expected])
			check(absf(float(damaged) / trials - odds.p_damage) < 0.025, "Forecast damage chance matches rolls (%s)" % label)
			check(absf(float(destroyed) / trials - odds.p_destroy) < 0.025, "Forecast destroy chance matches rolls (%s)" % label)

func test_abilities_and_locks() -> void:
	var battle := fresh()
	isolate(battle, ["blue_kestrel", "red_medved", "red_tieshan"])
	var ace := battle.units[0]
	var target := battle.units[3]
	ace.position = Vector2.ZERO
	ace.altitude = 0
	ace.facing = 0
	target.position = Vector2(0, -3)
	check(CombatRules.lock_error(battle, target, ace).is_empty(), "Every unit can lock on; no stat is required")
	check(CombatRules.take_lock(battle, ace, target), "Target Lock acquired during an action")
	check(not CombatRules.take_lock(battle, ace, target), "Only one target lock action per round")
	var result := CombatRules.resolve(battle, ace, target, battle.catalogue.weapons.lr3_rifle)
	check(result.lock_used and result.rerolled_indices.size() <= CombatRules.LOCK_REROLLS and ace.locks.is_empty(), "A lock rerolls one miss and is consumed")
	var old_facing := ace.facing
	for i in range(3):
		check(AbilityRules.apply(battle, ace, "newtype", "after_movement", {"degrees": 15}).ok, "Newtype incremental rotation")
	check(ace.will == 3 and is_equal_approx(ace.facing - old_facing, PI / 4), "Newtype max rotation costs one Will total")
	check(not AbilityRules.apply(battle, ace, "newtype", "after_movement", {"degrees": 15}).ok, "Newtype rotation cap")
	check(not AbilityRules.apply(battle, ace, "newtype", "before_attack", {"degrees": 15}).ok, "Ability event gate")
	ace.facing = 0
	ace.attacked = false
	target.structure = 30
	result = CombatRules.resolve(battle, ace, target, battle.catalogue.weapons.lr3_rifle, true)
	var misses := result.initial_shots.count(AttackResult.Shot.MISS)
	var expected_cost := mini(1, misses)
	check(result.will_spent == expected_cost and result.rerolled_indices.size() == mini(2, misses) and ace.will == 3 - expected_cost, "I Can See It rerolls at most two misses; no cost without a miss")
	ace.attacked = false
	ace.will = 2
	var plain := CombatRules.hit_chance(battle, ace, target, battle.catalogue.weapons.lr3_rifle)
	result = CombatRules.resolve(battle, ace, target, battle.catalogue.weapons.lr3_rifle, false, Callable(), true)
	check(result.pushed and ace.will == 1 and is_equal_approx(result.hit_chance, minf(CombatRules.MAX_HIT, plain + 20.0)), "Push spends 1 Will for +20% to hit")
	ace.attacked = false
	ace.will = 0
	result = CombatRules.resolve(battle, ace, target, battle.catalogue.weapons.lr3_rifle, false, Callable(), true)
	check(not result.pushed and is_equal_approx(result.hit_chance, plain), "Push without Will has no effect")

func test_turns() -> void:
	var manager := TurnManager.new()
	root.add_child(manager)
	manager.paused = true
	manager.setup(19)
	check(manager.phase == TurnManager.Phase.PLANNING and not manager.can_commit(), "Start in planning; cannot commit missing orders")
	for unit in manager.battle.living(0):
		check(manager.confirm_order(unit, TacticalAI.choose_order(manager.battle, unit)), "Blue confirms legal order")
	check(manager.can_commit() and manager.commit(), "All orders enable commit")
	check(manager.phase == TurnManager.Phase.REVEAL, "Reveal phase")
	manager.advance()
	check(manager.phase == TurnManager.Phase.MOVEMENT, "Movement phase")
	for i in range(manager.battle.units.size() + 1):
		manager.advance()
	check(manager.phase == TurnManager.Phase.ACTION and manager.active.loadout.id == "blue_kestrel", "High Reflex acts first after movement")
	var energy_unit := manager.battle.units[0]
	energy_unit.energy = 0
	energy_unit.will = 1
	manager.phase = TurnManager.Phase.END
	manager.advance()
	check(energy_unit.energy == 2 and energy_unit.will == 1 and manager.battle.round_number == 2, "End phase recharges Energy, never Will")
	manager.free()

func test_attack_skipping() -> void:
	var manager := TurnManager.new()
	root.add_child(manager)
	manager.paused = true
	manager.setup(42)
	manager.queue = manager.battle.initiative(false)
	manager.cursor = 0
	manager.set_phase(TurnManager.Phase.ATTACK)
	manager.next_active()
	check(manager.phase == TurnManager.Phase.END and manager.active == null, "Entire fire stage skips when every unit lacks a target")
	for unit in manager.battle.living():
		check(unit.attacked and unit.energy == unit.loadout.frame.energy_capacity and unit.will == unit.will_max(), "Skipped fire spends neither Energy nor Will")
	isolate(manager.battle, ["blue_kestrel", "blue_teamster", "red_medved", "red_tieshan"])
	# The Kestrel's weapons all draw Energy, so the Medved (Grad-M costs Energy, GSh-6M is free) shoots here.
	var ace := manager.battle.units[0]
	var medium := manager.battle.units[1]
	var heavy := manager.battle.units[3]
	var tieshan := manager.battle.units[4]
	heavy.position = Vector2.ZERO
	heavy.facing = 0
	heavy.energy = 0
	ace.position = Vector2(0, -1)
	ace.altitude = 0
	medium.position = Vector2(-15, 10)
	tieshan.position = Vector2(15, 10)
	for unit in manager.battle.living():
		unit.attacked = false
	check(CombatRules.legal_targets(manager.battle, heavy, heavy.loadout.weapons[0]).is_empty(), "Primary weapon cannot fire in alternate-weapon test")
	check(CombatRules.has_legal_attack(manager.battle, heavy), "Free secondary weapon keeps activation eligible")
	manager.queue.assign([tieshan, heavy, ace])
	manager.cursor = 0
	manager.set_phase(TurnManager.Phase.ATTACK)
	manager.next_active()
	check(manager.active == heavy and tieshan.attacked, "Skips ineligible unit but retains unit with another usable weapon")
	ace.position = Vector2(0, -5)
	check(not CombatRules.has_legal_attack(manager.battle, heavy), "No affordable in-range weapon means no legal attack")
	heavy.energy = 4
	check(CombatRules.has_legal_attack(manager.battle, heavy), "Energy restoration makes rocket attack legal")
	manager.battle.terrain = [{"position": [0, -2.5], "half_size": [0.5, 0.4], "height": 3, "cover": 2, "blocks_move": true, "blocks_los": true}]
	check(not CombatRules.has_legal_attack(manager.battle, heavy), "Blocked LOS excludes all weapons from eligibility")
	manager.battle.terrain.clear()
	manager.queue.assign([heavy])
	manager.cursor = 0
	manager.next_active()
	ace.structure = 0
	manager.debug_changed(ace)
	check(manager.phase == TurnManager.Phase.END, "Losing final legal target skips current attack immediately")
	manager.free()

func test_horizontal_range() -> void:
	var battle := fresh()
	isolate(battle, ["blue_kestrel", "red_medved"])
	var ace := battle.units[0]
	var target := battle.units[3]
	var weapon: WeaponData = battle.catalogue.weapons.lr3_rifle
	check(CombatRules.horizontal_range(weapon, 0) == Vector2(2, 4), "Same-band range overlay matches weapon limits")
	var limits := CombatRules.horizontal_range(weapon, 1)
	check(is_equal_approx(limits.x, sqrt(1.75)) and is_equal_approx(limits.y, sqrt(13.75)), "Range overlay accounts for altitude separation")
	ace.position = Vector2.ZERO
	ace.altitude = 0
	ace.facing = 0
	target.altitude = 1
	target.position = Vector2(0, -limits.y)
	check(CombatRules.target_error(battle, ace, target, weapon).is_empty(), "Projected maximum radius agrees with actual range legality")
	target.position.y -= 0.05
	check("range" in CombatRules.target_error(battle, ace, target, weapon), "Outside projected radius is actually out of range")
	check(CombatRules.horizontal_range(battle.catalogue.weapons.vb2_knife, 1).y < 0, "Melee overlay marks another altitude unreachable")

func test_full_battle(seed_value: int) -> void:
	var manager := TurnManager.new()
	root.add_child(manager)
	manager.paused = true
	manager.auto_blue = true
	manager.setup(seed_value)
	var ticks := 0
	var planning_failed := false
	while manager.phase != TurnManager.Phase.BATTLE_OVER and ticks < 4000:
		ticks += 1
		if manager.phase == TurnManager.Phase.PLANNING:
			for unit in manager.battle.living(0).filter(manager.needs_order):
				var order := TacticalAI.choose_order(manager.battle, unit)
				if order == null or not manager.confirm_order(unit, order):
					planning_failed = true
					push_error("No legal order / seed %d / round %d / %s" % [seed_value, manager.battle.round_number, unit.loadout.callsign])
					break
			if planning_failed:
				break
		manager.advance()
		for unit in manager.battle.living():
			check(unit.energy >= 0 and unit.energy <= unit.loadout.frame.energy_capacity, "Energy invariant during battle")
			check(not MovementRules.overlaps(manager.battle, unit, unit.position, unit.altitude), "No overlap after resolution")
	check(not planning_failed and manager.phase == TurnManager.Phase.BATTLE_OVER, "Full battle seed %d reaches victory" % seed_value)
	print("BATTLE / seed %d / round %d / winner %d / %d steps" % [seed_value, manager.battle.round_number, manager.battle.winner(), ticks])
	manager.free()

func test_charge_and_engagement() -> void:
	var battle := fresh(5)
	isolate(battle, ["blue_teamster", "red_medved", "red_tank"])
	var teamster := battle.units[1]
	var medved := battle.units[3]
	var tank := battle.units[6]
	var charge: ManoeuvreData = battle.catalogue.manoeuvres.charge
	var stake: WeaponData = battle.catalogue.weapons.pb4_stake
	var ram: WeaponData = battle.catalogue.weapons.molot_ram
	teamster.position = Vector2.ZERO
	teamster.facing = 0
	medved.position = Vector2(0, -3)
	medved.facing = PI
	tank.position = Vector2(-4, 0)
	check(charge in MovementRules.available(battle, teamster), "Ground mechs can charge")
	var order := MovementRules.create_order(battle, teamster, charge, Vector2.ZERO, 0, 0, medved)
	check(order.valid and order.target_id == "red_medved", "Charge at an enemy ahead and in reach is legal")
	check(is_equal_approx(MeleeRules.edge_gap(teamster, medved, order.destination), MeleeRules.CONTACT_GAP), "Charge draft stops just short of base contact")
	check(MovementRules.create_order(battle, teamster, charge, Vector2.ZERO, 0, 0, null).reason.contains("Click an enemy"), "Charge needs a target")
	medved.position = Vector2(0, 3)
	check(MovementRules.create_order(battle, teamster, charge, Vector2.ZERO, 0, 0, medved).reason.contains("cone"), "Charge targets must start inside the forward cone")
	medved.position = Vector2(0, -8)
	check(MovementRules.create_order(battle, teamster, charge, Vector2.ZERO, 0, 0, medved).reason.contains("reach"), "Charge targets must be inside charge reach")
	check(MeleeRules.charge_targets(battle, teamster, charge).is_empty(), "No charge targets when nothing is in reach")
	medved.position = Vector2(0, -3)
	teamster.order = MovementRules.create_order(battle, teamster, charge, Vector2.ZERO, 0, 0, medved)
	# The target sidesteps before the charge resolves: the charge homes on where it is now.
	medved.position = Vector2(1.0, -3.2)
	var energy := teamster.energy
	var moved := MovementRules.resolve(battle, teamster)
	check(moved.engaged and MeleeRules.engaged_with(teamster, medved) and MeleeRules.engaged_with(medved, teamster), "Connected charge engages both units")
	check(teamster.energy == energy - charge.energy_cost and teamster.charge_target == "red_medved", "Charge spends Energy and marks its target")
	check(absf(rad_to_deg(teamster.forward().angle_to(medved.position - teamster.position))) < 1.0, "Charger ends facing its target")
	check(not MovementRules.overlaps(battle, teamster, teamster.position, 0), "Charge never overlaps the target")
	var plain := 50.0 + 10.0 * (teamster.stat("melee") - medved.stat("reflex") - medved.stat("guard")) + SizeClass.HIT_MODIFIER.large
	check(is_equal_approx(CombatRules.hit_chance(battle, teamster, medved, stake), clampf(plain + MeleeRules.CHARGE_BONUS, 10, 90)), "Charge bonus applies to melee against the charged unit")
	check(not CombatRules.charge_bonus(medved, teamster), "The charged unit gets no charge bonus")
	check(CombatRules.target_error(battle, medved, teamster, ram).is_empty(), "Engaged melee ignores the firing arc")
	check(CombatRules.target_error(battle, teamster, tank, battle.catalogue.weapons.ar40_rifle).contains("Locked in melee"), "Engaged units can only attack their foes")
	tank.position = teamster.position + Vector2(-2.5, 0)
	check(CombatRules.target_error(battle, tank, teamster, battle.catalogue.weapons.type99_mg).is_empty(), "Outsiders may still shoot into a melee")
	var step := MovementRules.create_order(battle, medved, battle.catalogue.manoeuvres.ground, medved.position + Vector2(2, 0), 0, 0)
	check(step.reason.contains("melee"), "Engaged units cannot plan movement")
	medved.order = step
	check(MovementRules.resolve(battle, medved).message.contains("locked in melee") and medved.position == Vector2(1.0, -3.2), "A unit caught by a charge loses its own move")
	check(TacticalAI.choose_order(battle, medved) == null, "AI does not plan for engaged units")
	check(CombatRules.has_action_choice(battle, teamster), "Breaking off is an Action-phase choice")
	# Break off: the Medved takes its attack early, at +20%.
	var structure := teamster.structure
	var result := MeleeRules.break_off(battle, teamster)
	check(result.ok and result.strikes.size() == 1 and result.strikes[0].parting and medved.attacked, "Breaking off provokes a parting strike that uses the foe's attack")
	check(is_equal_approx(result.strikes[0].hit_chance, clampf(50.0 + 10.0 * (medved.stat("melee") - teamster.stat("reflex") - teamster.stat("guard")) + MeleeRules.PARTING_BONUS, 10, 90)), "Parting strikes get the turning-away bonus")
	check(teamster.structure == structure - result.strikes[0].damage, "Parting strike damage is applied")
	check(teamster.engaged.is_empty() and medved.engaged.is_empty() and teamster.action_used, "Breaking off ends the engagement and uses the action")
	check(MeleeRules.edge_gap(teamster, medved) > MeleeRules.ENGAGE_REACH, "Breaking off leaves melee reach")
	check(not MeleeRules.break_off(battle, teamster).ok, "Cannot break off when not engaged")
	# A blocking wall stops the charge short.
	teamster.position = Vector2.ZERO
	teamster.facing = 0
	teamster.energy = 3
	medved.position = Vector2(0, -3.5)
	teamster.order = MovementRules.create_order(battle, teamster, charge, Vector2.ZERO, 0, 0, medved)
	battle.terrain = [{"position": [0, -1.5], "half_size": [1.0, 0.2], "height": 3, "cover": 2, "blocks_move": true, "blocks_los": true}]
	check(not MovementRules.resolve(battle, teamster).engaged and teamster.engaged.is_empty(), "Terrain stops a charge short of contact")
	battle.terrain.clear()
	# Engagements end when a foe is destroyed.
	teamster.position = Vector2(0, -3.5 + teamster.loadout.frame.size + medved.loadout.frame.size + 0.05)
	MeleeRules.engage(teamster, medved)
	medved.structure = 0
	MeleeRules.clean(battle)
	check(teamster.engaged.is_empty() and not MeleeRules.is_engaged(battle, teamster), "Destroying a foe frees the survivor")
	# Turn sequencing: an engaged Blue unit needs no order to commit.
	var manager := TurnManager.new()
	root.add_child(manager)
	manager.paused = true
	manager.setup(11)
	var blue := manager.battle.units[1]
	var red := manager.battle.units[3]
	blue.position = Vector2(0, 0)
	red.position = Vector2(0, -(blue.loadout.frame.size + red.loadout.frame.size + 0.05))
	MeleeRules.engage(blue, red)
	manager.begin_planning()
	check(MeleeRules.is_engaged(manager.battle, blue) and not manager.needs_order(blue), "Engagement persists into the next round")
	check(absf(rad_to_deg(red.forward().angle_to(blue.position - red.position))) < 1.0, "Engaged units square up at the start of the round")
	for unit in manager.battle.living(0).filter(manager.needs_order):
		manager.confirm_order(unit, TacticalAI.choose_order(manager.battle, unit))
	check(manager.can_commit(), "Engaged units do not block commit")
	check(not manager.confirm_order(blue, MovementRules.create_order(manager.battle, blue, manager.battle.catalogue.manoeuvres.ground, Vector2(0, 2))), "Engaged units cannot confirm a move")
	manager.free()
