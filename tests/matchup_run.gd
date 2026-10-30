extends SceneTree

## Equal-points testing. AI plays both sides; forces swap deployment sides every other seed.
##   Force vs force:  --script res://tests/matchup_run.gd -- --a blue_kestrel --b red_medved,red_tank --seeds 100
##   Round robin:     --script res://tests/matchup_run.gd -- --all --seeds 60
## Add --standard-pilots to give every unit the same pilot, so only frames and weapons are compared.
const MAX_ROUNDS := 40
const STANDARD_PILOT := {"gunnery": 1, "melee": 1, "precision": 1, "reflex": 0, "systems": 0, "countermeasures": 0, "spirit": 2}

var costs := PointCosts.new()
var standard_pilots := false

func _initialize() -> void:
	run.call_deferred()

func arg(name: String, fallback: String) -> String:
	var args := OS.get_cmdline_user_args()
	var index := args.find(name)
	return args[index + 1] if index >= 0 and index + 1 < args.size() else fallback

func run() -> void:
	var args := OS.get_cmdline_user_args()
	standard_pilots = "--standard-pilots" in args
	var seeds := int(arg("--seeds", "60"))
	var start := int(arg("--start", "1"))
	if "--all" in args:
		round_robin(seeds, start)
	else:
		var result := play(arg("--a", "blue_kestrel").split(","), arg("--b", "red_medved").split(","), seeds, start)
		print_result(result)
	quit()

func round_robin(seeds: int, start: int) -> void:
	var ids: Array[String] = []
	for loadout in Catalogue.new().loadouts:
		if loadout.frame.id not in ids.map(func(id: String) -> String: return frame_of(id)):
			ids.append(loadout.id)
	print("ROUND ROBIN / %d seeds per pair / %s pilots" % [seeds, "standard" if standard_pilots else "scenario"])
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			print_result(play(PackedStringArray([ids[i]]), PackedStringArray([ids[j]]), seeds, start))

func frame_of(id: String) -> String:
	for loadout in Catalogue.new().loadouts:
		if loadout.id == id:
			return loadout.frame.id
	return ""

func print_result(r: Dictionary) -> void:
	# Expected share if points were a perfect predictor is roughly points share; the gap is what to tune.
	var share: float = r.points_a / (r.points_a + r.points_b)
	print("MATCHUP / %-34s %5.1f pts  vs  %-34s %5.1f pts / A wins %3d%% / B wins %3d%% / draws %3d%% / points share %2d%% / avg %.1f rounds" % [r.a, r.points_a, r.b, r.points_b, roundi(100.0 * r.wins_a / r.games), roundi(100.0 * r.wins_b / r.games), roundi(100.0 * r.draws / r.games), roundi(100.0 * share), float(r.rounds) / r.games])

func play(a_ids: PackedStringArray, b_ids: PackedStringArray, seeds: int, start: int) -> Dictionary:
	var result := {"a": ",".join(a_ids), "b": ",".join(b_ids), "wins_a": 0, "wins_b": 0, "draws": 0, "games": 0, "rounds": 0, "points_a": 0.0, "points_b": 0.0}
	for seed_value in range(start, start + seeds):
		var a_is_blue := seed_value % 2 == 0
		var catalogue := Catalogue.new()
		var a_units := build_force(catalogue, a_ids, 0 if a_is_blue else 1, "a")
		var b_units := build_force(catalogue, b_ids, 1 if a_is_blue else 0, "b")
		catalogue.loadouts.assign(a_units + b_units)
		if seed_value == start:
			for loadout in a_units:
				result.points_a += costs.mech_cost(loadout, catalogue) + costs.pilot_cost(loadout.pilot)
			for loadout in b_units:
				result.points_b += costs.mech_cost(loadout, catalogue) + costs.pilot_cost(loadout.pilot)
		var manager := TurnManager.new()
		root.add_child(manager)
		manager.paused = true
		manager.auto_blue = true
		manager.setup(seed_value, catalogue)
		var ticks := 0
		while manager.phase != TurnManager.Phase.BATTLE_OVER and manager.battle.round_number <= MAX_ROUNDS and ticks < 8000:
			ticks += 1
			if manager.phase == TurnManager.Phase.PLANNING:
				for unit in manager.battle.living(0).filter(manager.needs_order):
					manager.confirm_order(unit, TacticalAI.choose_order(manager.battle, unit))
			manager.advance()
		var winner := manager.battle.winner() if manager.phase == TurnManager.Phase.BATTLE_OVER else 2
		if winner == 2:
			result.draws += 1
		elif (winner == 0) == a_is_blue:
			result.wins_a += 1
		else:
			result.wins_b += 1
		result.games += 1
		result.rounds += manager.battle.round_number
		manager.free()
	return result

## Copies the named scenario units onto one side, spread along that side's deployment line.
func build_force(catalogue: Catalogue, ids: PackedStringArray, faction: int, tag: String) -> Array[UnitLoadout]:
	var force: Array[UnitLoadout] = []
	for i in ids.size():
		var source: UnitLoadout
		for loadout in catalogue.loadouts:
			if loadout.id == ids[i]:
				source = loadout
		assert(source != null, "Unknown unit id: " + ids[i])
		var copy: UnitLoadout = source.duplicate()
		copy.weapons = source.weapons.duplicate()
		copy.id = "%s_%s_%d" % [ids[i], tag, i]
		copy.callsign = "%s%d / %s" % [tag.to_upper(), i + 1, source.callsign.split(" / ")[-1]]
		copy.faction = faction
		if standard_pilots:
			var pilot: PilotData = source.pilot.duplicate()
			pilot.stats = STANDARD_PILOT.duplicate()
			pilot.abilities.assign(["push"])
			copy.pilot = pilot
		var x := -11.0 if faction == 0 else 11.0
		copy.start_position = Vector2(x, (i - (ids.size() - 1) / 2.0) * 3.0)
		copy.start_facing = 90.0 if faction == 0 else 270.0
		force.append(copy)
	return force
