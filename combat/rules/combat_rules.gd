class_name CombatRules
extends RefCounted

## Every shot rolls a d10 against one hit chance, kept in percent for forecasts: 60% hits on 1–6.
## Each point of the attacker's stat adds 10, and each point of the target's Reflex or cover subtracts
## it, for ranged and melee alike. The weapon's aim bonus and the target's size class shift it further. Every
## modifier is a multiple of 10, and the limits mean a 1 always hits and a 10 always misses.
const BASE_HIT: float = 50.0
const PER_POINT: float = 10.0
const MIN_HIT: float = 10.0
const MAX_HIT: float = 90.0
## Heavy weapons: a miss within this many points of the hit chance is a glancing hit.
const GLANCE_WINDOW: float = 20.0
const CRIT_PER_PRECISION: float = 10.0
const LOCK_REROLLS: int = 1
const LOCK_RANGE: float = 8.0
const TYPE_MATCH_BONUS: int = 2

static func attack_stat(weapon: WeaponData) -> String:
	return "melee" if weapon.melee else "gunnery"

## Extra centre-to-centre distance melee gains because its range is measured base edge to base edge.
static func reach_allowance(weapon: WeaponData, attacker: UnitState, defender: UnitState = null) -> float:
	if not weapon.melee:
		return 0.0
	return attacker.loadout.frame.size + (defender.loadout.frame.size if defender != null else 0.0)

## The distance compared against a weapon's range limits.
static func range_distance(attacker: UnitState, defender: UnitState, weapon: WeaponData) -> float:
	return attacker.range_position().distance_to(defender.range_position()) - reach_allowance(weapon, attacker, defender)

## Percentage chance for one shot to hit, before any reroll.
static func hit_chance(battle: BattleState, attacker: UnitState, defender: UnitState, weapon: WeaponData, bonus: float = 0.0) -> float:
	var defence := defender.stat("reflex") + TerrainRules.cover(battle, attacker, defender)
	bonus += weapon.aim_bonus + SizeClass.HIT_MODIFIER.get(defender.loadout.frame.size_class, 0.0)
	if weapon.melee and charge_bonus(attacker, defender):
		bonus += MeleeRules.CHARGE_BONUS
	return clampf(BASE_HIT + PER_POINT * (attacker.stat(attack_stat(weapon)) - defence) + bonus, MIN_HIT, MAX_HIT)

## A charge that connected this round adds to melee against the unit it hit.
static func charge_bonus(attacker: UnitState, defender: UnitState) -> bool:
	return attacker.charge_target == defender.loadout.id

static func crit_chance(attacker: UnitState) -> float:
	return attacker.stat("precision") * CRIT_PER_PRECISION

static func glance_chance(weapon: WeaponData, hit: float) -> float:
	return minf(GLANCE_WINDOW, 100.0 - hit) if weapon.heavy else 0.0

## Damage one shot deals. Armour comes off every hit; a crit ignores it; a glancing hit is half damage.
static func shot_damage(weapon: WeaponData, armour: int, outcome: int) -> int:
	match outcome:
		AttackResult.Shot.CRIT:
			return weapon.damage
		AttackResult.Shot.HIT:
			return maxi(0, weapon.damage - armour)
		AttackResult.Shot.GLANCE:
			return maxi(0, floori(weapon.damage / 2.0) - armour)
	return 0

## Armour after type and piercing: +2 when the armour is built against this damage type, minus the
## weapon's armour piercing, never below 0.
static func effective_armour(weapon: WeaponData, defender: UnitState) -> int:
	var frame := defender.loadout.frame
	var matched := TYPE_MATCH_BONUS if frame.armour_type == weapon.damage_type else 0
	return maxi(0, frame.armour + matched - weapon.armour_piercing)

static func target_error(battle: BattleState, attacker: UnitState, defender: UnitState, weapon: WeaponData) -> String:
	if not attacker.alive() or not defender.alive():
		return "Unit destroyed."
	if attacker.loadout.faction == defender.loadout.faction:
		return "Friendly unit."
	if weapon not in attacker.loadout.weapons:
		return "Weapon not equipped."
	var locked := MeleeRules.foes(battle, attacker)
	if not locked.is_empty() and defender not in locked:
		return "Locked in melee with %s." % ", ".join(PackedStringArray(locked.map(func(unit: UnitState) -> String: return unit.loadout.callsign)))
	if attacker.energy < weapon.energy_cost:
		return "Insufficient Energy."
	var distance := range_distance(attacker, defender, weapon)
	if distance < weapon.range_min - 0.01 or distance > weapon.range_max + 0.01:
		return "Out of range (%.1f / %.1f–%.1f)." % [maxf(0.0, distance), weapon.range_min, weapon.range_max]
	var offset := defender.position - attacker.position
	# Units locked in melee fight all round: melee ignores the arc against an engaged foe.
	var brawling := weapon.melee and MeleeRules.engaged_with(attacker, defender)
	if not brawling and offset.length() > 0.01 and absf(rad_to_deg(attacker.forward().angle_to(offset))) > weapon.arc * 0.5 + 0.01:
		return "Outside firing arc."
	if not TerrainRules.line_of_sight(battle, attacker, defender):
		return "Line of sight blocked."
	return ""

static func legal_targets(battle: BattleState, unit: UnitState, weapon: WeaponData) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for target in battle.living(1 - unit.loadout.faction):
		if target_error(battle, unit, target, weapon).is_empty():
			result.append(target)
	return result

static func has_legal_attack(battle: BattleState, unit: UnitState) -> bool:
	if not unit.alive() or unit.attacked:
		return false
	for weapon in unit.loadout.weapons:
		if not legal_targets(battle, unit, weapon).is_empty():
			return true
	return false

## Horizontal radii for the given altitude difference; a negative maximum means unreachable.
## reach widens the limits for melee, whose range is measured from base edges.
static func horizontal_range(weapon: WeaponData, altitude_difference: int, reach: float = 0.0) -> Vector2:
	var height := altitude_difference * UnitState.RANGE_ALTITUDE_SPACING
	var outer := weapon.range_max + reach
	var inner := weapon.range_min + reach if weapon.range_min > 0 else 0.0
	if absf(height) > outer:
		return Vector2(0, -1)
	return Vector2(sqrt(maxf(0, inner * inner - height * height)), sqrt(maxf(0, outer * outer - height * height)))

static func lock_error(battle: BattleState, unit: UnitState, target: UnitState) -> String:
	if not unit.alive() or not target.alive() or target.loadout.faction == unit.loadout.faction:
		return "Choose a living enemy."
	if unit.range_position().distance_to(target.range_position()) > LOCK_RANGE:
		return "Target Lock range is %d." % int(LOCK_RANGE)
	if not TerrainRules.line_of_sight(battle, unit, target):
		return "Target Lock needs line of sight."
	return ""

static func lockable_targets(battle: BattleState, unit: UnitState) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for target in battle.living(1 - unit.loadout.faction):
		if lock_error(battle, unit, target).is_empty():
			result.append(target)
	return result

## Whether an Action-phase activation offers any real choice: a lock to take, or a facing power to spend.
static func has_action_choice(battle: BattleState, unit: UnitState) -> bool:
	if not unit.alive():
		return false
	if not unit.action_used and not lockable_targets(battle, unit).is_empty():
		return true
	if MeleeRules.break_off_error(battle, unit).is_empty():
		return true
	for ability in AbilityRules.for_event(battle, unit, "after_movement"):
		if ability.effect == "rotate" and (unit.ability_paid or unit.will >= ability.will_cost):
			return true
	return false

## Upper bound on how far away a unit could hit a target at target_altitude this round:
## its longest available move plus its longest affordable weapon, at its best altitude band. −1 = cannot reach.
static func threat_reach(battle: BattleState, unit: UnitState, target_altitude: int) -> float:
	var move := 0.0
	for manoeuvre in MovementRules.available(battle, unit):
		move = maxf(move, MovementRules.maximum_distance(unit, manoeuvre))
	var reach := -1.0
	for weapon in unit.loadout.weapons:
		if weapon.energy_cost > unit.energy:
			continue
		for band in unit.loadout.frame.altitude_access:
			reach = maxf(reach, horizontal_range(weapon, target_altitude - band, reach_allowance(weapon, unit)).y)
	return move + reach if reach >= 0 else -1.0

static func take_lock(battle: BattleState, unit: UnitState, target: UnitState) -> bool:
	if not lock_error(battle, unit, target).is_empty() or unit.action_used:
		return false
	if target.loadout.id not in unit.locks:
		while unit.locks.size() >= UnitState.LOCK_CAPACITY:
			unit.locks.pop_front()
		unit.locks.append(target.loadout.id)
	unit.action_used = true
	return true

static func roll_shot(battle: BattleState, hit: float, glance: float, crit: float) -> int:
	var roll := d10(battle)
	if roll <= hit:
		return AttackResult.Shot.CRIT if d10(battle) <= crit else AttackResult.Shot.HIT
	return AttackResult.Shot.GLANCE if roll <= hit + glance else AttackResult.Shot.MISS

## One d10 in percent (10–100), so it compares directly with the chances above.
static func d10(battle: BattleState) -> float:
	return battle.rng.randi_range(1, 10) * 10.0

## extra_bonus: situational to-hit bonus, such as a parting strike at a unit breaking off.
static func resolve(battle: BattleState, attacker: UnitState, defender: UnitState, weapon: WeaponData, use_will: bool = false, after_roll: Callable = Callable(), push: bool = false, extra_bonus: float = 0.0) -> AttackResult:
	if attacker.attacked or not target_error(battle, attacker, defender, weapon).is_empty():
		return null
	var result := AttackResult.new()
	result.attacker_id = attacker.loadout.id
	result.defender_id = defender.loadout.id
	result.weapon_name = weapon.display_name
	result.weapon_damage = weapon.damage
	result.armour = effective_armour(weapon, defender)
	result.cover = TerrainRules.cover(battle, attacker, defender)
	var bonus := extra_bonus
	if push:
		for ability in AbilityRules.for_event(battle, attacker, "before_attack"):
			var effect := AbilityRules.apply(battle, attacker, ability.id, "before_attack", {})
			if effect.ok:
				bonus += effect.amount
				result.will_spent += int(effect.cost)
				result.pushed = true
	result.hit_chance = hit_chance(battle, attacker, defender, weapon, bonus)
	result.charged = weapon.melee and charge_bonus(attacker, defender)
	result.crit_chance = crit_chance(attacker)
	result.glance_chance = glance_chance(weapon, result.hit_chance)
	for i in weapon.shots:
		result.shots.append(roll_shot(battle, result.hit_chance, result.glance_chance, result.crit_chance))
	result.initial_shots.assign(result.shots)
	if after_roll.is_valid():
		after_roll.call(result)
	var rerolls := 0
	if defender.loadout.id in attacker.locks:
		rerolls = LOCK_REROLLS
		result.lock_used = true
		attacker.locks.erase(defender.loadout.id)
	if use_will and result.count(AttackResult.Shot.MISS) > rerolls:
		for ability in AbilityRules.for_event(battle, attacker, "after_attack_roll"):
			var effect := AbilityRules.apply(battle, attacker, ability.id, "after_attack_roll", {})
			if effect.ok:
				rerolls += int(effect.amount)
				result.will_spent += int(effect.cost)
	for i in result.shots.size():
		if rerolls > 0 and result.shots[i] == AttackResult.Shot.MISS:
			result.shots[i] = roll_shot(battle, result.hit_chance, result.glance_chance, result.crit_chance)
			result.rerolled_indices.append(i)
			rerolls -= 1
	for outcome in result.shots:
		result.damage += shot_damage(weapon, result.armour, outcome)
	attacker.energy -= weapon.energy_cost
	attacker.attacked = true
	defender.structure = maxi(0, defender.structure - result.damage)
	result.destroyed = not defender.alive()
	return result

## Hit-chance bonus Push would add, and its Will cost, if the pilot has it and can pay.
static func push_option(battle: BattleState, unit: UnitState) -> Dictionary:
	for ability in AbilityRules.for_event(battle, unit, "before_attack"):
		if ability.effect == "accuracy" and unit.will >= ability.will_cost:
			return {"amount": ability.amount, "cost": ability.will_cost}
	return {}

## Exact outcome odds for the player-facing preview; mirrors resolve() without rolling or spending.
static func forecast(battle: BattleState, attacker: UnitState, defender: UnitState, weapon: WeaponData, use_will: bool = false, push: bool = false) -> Dictionary:
	var will_left := attacker.will
	var bonus := 0.0
	var pushed := false
	if push:
		var option := push_option(battle, attacker)
		if not option.is_empty():
			bonus = option.amount
			will_left -= option.cost
			pushed = true
	var hit := hit_chance(battle, attacker, defender, weapon, bonus)
	var crit := crit_chance(attacker)
	var glance := glance_chance(weapon, hit)
	var armour := effective_armour(weapon, defender)
	var rerolls := LOCK_REROLLS if defender.loadout.id in attacker.locks else 0
	if use_will:
		for ability in AbilityRules.for_event(battle, attacker, "after_attack_roll"):
			if ability.effect == "reroll" and will_left >= ability.will_cost:
				rerolls += int(ability.amount)
				will_left -= ability.will_cost
	# Each landed outcome as [chance, damage]; a miss is handled separately because it can be rerolled.
	var landed := [
		[hit / 100.0 * (1.0 - crit / 100.0), shot_damage(weapon, armour, AttackResult.Shot.HIT)],
		[hit / 100.0 * crit / 100.0, shot_damage(weapon, armour, AttackResult.Shot.CRIT)],
		[glance / 100.0, shot_damage(weapon, armour, AttackResult.Shot.GLANCE)],
	]
	var miss := 1.0 - (hit + glance) / 100.0
	# Rerolls go to the earliest misses, so a shot-by-shot walk with a reroll budget is exact.
	var states := {Vector2i(rerolls, 0): 1.0}
	for i in weapon.shots:
		var next := {}
		for state: Vector2i in states:
			var chance: float = states[state]
			for outcome in landed:
				var key := Vector2i(state.x, state.y + outcome[1])
				next[key] = next.get(key, 0.0) + chance * outcome[0]
			if state.x == 0:
				next[state] = next.get(state, 0.0) + chance * miss
				continue
			# A miss spends one reroll and rolls again; a second miss stands.
			var spent := Vector2i(state.x - 1, state.y)
			for outcome in landed:
				var key := Vector2i(spent.x, state.y + outcome[1])
				next[key] = next.get(key, 0.0) + chance * miss * outcome[0]
			next[spent] = next.get(spent, 0.0) + chance * miss * miss
		states = next
	var expected := 0.0
	var damaged := 0.0
	var destroyed := 0.0
	for state: Vector2i in states:
		var chance: float = states[state]
		expected += chance * state.y
		if state.y > 0:
			damaged += chance
		if state.y >= defender.structure:
			destroyed += chance
	return {"shots": weapon.shots, "armour": armour, "hit_chance": hit, "crit_chance": crit, "glance_chance": glance, "cover": TerrainRules.cover(battle, attacker, defender),
		"hit_damage": landed[0][1], "crit_damage": landed[1][1], "glance_damage": landed[2][1], "rerolls": rerolls, "pushed": pushed, "charged": weapon.melee and charge_bonus(attacker, defender),
		"expected": expected, "p_damage": damaged, "p_destroy": destroyed}

## Fast estimate for AI scoring: average damage per shot times shots, plus a lock's reroll.
static func expected_damage(battle: BattleState, unit: UnitState, target: UnitState, weapon: WeaponData, bonus: float = 0.0) -> float:
	var hit := hit_chance(battle, unit, target, weapon, bonus) / 100.0
	var crit := crit_chance(unit) / 100.0
	var glance := glance_chance(weapon, hit * 100.0) / 100.0
	var armour := effective_armour(weapon, target)
	var per_shot := hit * ((1.0 - crit) * shot_damage(weapon, armour, AttackResult.Shot.HIT) + crit * shot_damage(weapon, armour, AttackResult.Shot.CRIT)) + glance * shot_damage(weapon, armour, AttackResult.Shot.GLANCE)
	var total := per_shot * weapon.shots
	if target.loadout.id in unit.locks:
		total += (1.0 - pow(hit + glance, weapon.shots)) * per_shot
	return total
