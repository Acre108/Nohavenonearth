extends SceneTree
## Exports test vectors for the tabletop rules bot: inputs plus the exact results the Godot rules give.
## Run: Godot --headless --path . --script res://tests/export_vectors.gd
## Writes tabletop/vectors/legacy/attacks.json and tabletop/vectors/legacy/stats.json (old stat scale; kept for history). Every case is one line, so a
## rules change shows up as a readable diff. Range, arc and line of sight are not exported: the tabletop
## measures them on hexes, so a case gives cover directly and assumes the attack is legal.

const OUT_DIR := "res://tabletop/vectors/legacy/"
const SITUATIONS: Array[String] = ["base", "cover", "locked", "push", "reroll", "all_powers", "charged", "wounded"]
const WOUNDED_STRUCTURE := 10

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var attacks := attack_cases()
	write(OUT_DIR + "attacks.json", "Attack forecasts from CombatRules.forecast. Targets are d10 targets (roll equal or under); a crit target of 0 never crits; glance_target is null for weapons that are not heavy (a roll above hit_target and within glance_target is a glancing hit).", attacks)
	var stats := stat_cases()
	write(OUT_DIR + "stats.json", "Stat resolution from UnitState.resolve: whole pilot rating, plus whole hardware bonus, plus hardware fractions once they add up to a whole point (toward zero), limited to 0..cap.", stats)
	print("Exported %d attack cases and %d stat cases." % [attacks.size(), stats.size()])
	quit(0)

func write(path: String, about: String, cases: Array) -> void:
	var lines := PackedStringArray()
	for entry in cases:
		lines.append("    " + JSON.stringify(entry, "", false))
	var text := "{\n  \"about\": %s,\n  \"source\": \"tests/export_vectors.gd\",\n  \"cases\": [\n%s\n  ]\n}\n" % [JSON.stringify(about), ",\n".join(lines)]
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func attack_cases() -> Array:
	var cases := []
	var ids: Array[String] = []
	for loadout in Catalogue.new().loadouts:
		ids.append(loadout.id)
	for attacker_id in ids:
		for defender_id in ids:
			if attacker_id == defender_id:
				continue
			var probe := battle_with(attacker_id, defender_id)
			if probe.attacker.loadout.faction == probe.defender.loadout.faction:
				continue
			for weapon: WeaponData in probe.attacker.loadout.weapons:
				for situation in SITUATIONS:
					var entry := attack_case(attacker_id, defender_id, weapon.id, situation)
					if not entry.is_empty():
						cases.append(entry)
	cases.append_array(rating_sweep())
	return cases

## Gunnery 0–4 against Reflex 0–2, to cover both hit-chance limits.
func rating_sweep() -> Array:
	var cases := []
	for gunnery in range(0, 5):
		for reflex in range(0, 3):
			var entry := attack_case("blue_kestrel", "red_tieshan", "lr3_rifle", "base", {"gunnery": gunnery}, {"reflex": reflex})
			entry.id += "/gunnery%d_reflex%d" % [gunnery, reflex]
			cases.append(entry)
	return cases

## A fresh two-unit battle: attacker at the origin facing north, defender 5 units north on the ground
## (aircraft keep their starting altitude). Terrain is cleared; a cover case adds one barrier.
func battle_with(attacker_id: String, defender_id: String) -> Dictionary:
	var battle := BattleState.new(Catalogue.new(), 1)
	battle.terrain.clear()
	var attacker: UnitState
	var defender: UnitState
	for unit in battle.units:
		if unit.loadout.id == attacker_id:
			attacker = unit
		elif unit.loadout.id == defender_id:
			defender = unit
		else:
			unit.structure = 0
	attacker.position = Vector2.ZERO
	attacker.facing = 0
	defender.position = Vector2(0, -5)
	defender.facing = PI
	for unit in [attacker, defender]:
		if unit.loadout.frame.movement_type != "aircraft":
			unit.altitude = 0
	return {"battle": battle, "attacker": attacker, "defender": defender}

func attack_case(attacker_id: String, defender_id: String, weapon_id: String, situation: String, attacker_pilot := {}, defender_pilot := {}) -> Dictionary:
	var setup := battle_with(attacker_id, defender_id)
	var battle: BattleState = setup.battle
	var attacker: UnitState = setup.attacker
	var defender: UnitState = setup.defender
	var weapon: WeaponData = battle.catalogue.weapons[weapon_id]
	attacker.pilot_stats.merge(attacker_pilot, true)
	defender.pilot_stats.merge(defender_pilot, true)
	attacker.will = attacker.will_max()
	var push := situation in ["push", "all_powers"]
	var use_will := situation in ["reroll", "all_powers"]
	var abilities: Array[String] = attacker.loadout.pilot.abilities
	match situation:
		"cover":
			# A low barrier between the two, just in front of the defender.
			battle.terrain.append({"id": "barrier", "position": [0.0, -4.4], "half_size": [0.6, 0.1], "height": 4.0, "cover": 1, "blocks_move": false, "blocks_los": false})
			if TerrainRules.cover(battle, attacker, defender) == 0:
				return {}
		"locked", "all_powers":
			attacker.locks.assign([defender.loadout.id])
		"push":
			if CombatRules.push_option(battle, attacker).is_empty():
				return {}
		"reroll":
			if "see_it" not in abilities:
				return {}
		"charged":
			if not weapon.melee:
				return {}
			attacker.charge_target = defender.loadout.id
		"wounded":
			defender.structure = WOUNDED_STRUCTURE
	var odds := CombatRules.forecast(battle, attacker, defender, weapon, use_will, push)
	var stat := CombatRules.attack_stat(weapon)
	return {
		"id": "%s>%s/%s/%s" % [attacker_id, defender_id, weapon_id, situation],
		"attacker": {"unit": attacker_id, "pilot": attacker.loadout.pilot.id, "frame": attacker.loadout.frame.id,
			"attack_stat": stat, "attack_rating": int(attacker.stat(stat)), "precision": int(attacker.stat("precision")),
			"will": attacker.will, "abilities": abilities},
		"weapon": weapon_id,
		"defender": {"unit": defender_id, "frame": defender.loadout.frame.id, "size_class": defender.loadout.frame.size_class,
			"reflex": int(defender.stat("reflex")), "armour": defender.loadout.frame.armour, "armour_type": defender.loadout.frame.armour_type,
			"altitude": defender.altitude, "structure": defender.structure},
		"situation": {"cover": TerrainRules.cover(battle, attacker, defender), "locked": defender.loadout.id in attacker.locks,
			"charged": weapon.melee and CombatRules.charge_bonus(attacker, defender), "push": push, "use_will": use_will},
		"expected": {"hit_target": int(round(odds.hit_chance / 10.0)), "crit_target": int(round(odds.crit_chance / 10.0)),
			"glance_target": int(round((odds.hit_chance + odds.glance_chance) / 10.0)) if weapon.heavy else null,
			"armour": odds.armour, "hit_damage": odds.hit_damage, "crit_damage": odds.crit_damage, "glance_damage": odds.glance_damage,
			"rerolls": odds.rerolls, "pushed": odds.pushed, "expected_damage": snappedf(odds.expected, 0.000001),
			"p_damage": snappedf(odds.p_damage, 0.000001), "p_destroy": snappedf(odds.p_destroy, 0.000001)},
	}

func stat_cases() -> Array:
	var cases := []
	for pilot in [0, 1, 2, 4]:
		for bonus in [0.0, 1.0, -1.0, 2.0, 0.5, -0.25, 1.25]:
			for fractions in [0.0, 0.25, 0.75, 1.0, -0.25, -0.75, 1.5]:
				for cap in [2, 4]:
					cases.append({"pilot": pilot, "bonus": bonus, "fractions": fractions, "cap": cap,
						"total": int(UnitState.resolve(pilot, bonus, fractions, cap))})
	return cases
