class_name TacticalAI
extends RefCounted

static func choose_order(battle: BattleState, unit: UnitState) -> MovementOrder:
	var enemies := battle.living(1 - unit.loadout.faction)
	if enemies.is_empty() or MeleeRules.is_engaged(battle, unit):
		return null
	var best: MovementOrder
	var score_best := -INF
	for manoeuvre in MovementRules.available(battle, unit):
		for altitude in unit.loadout.frame.altitude_access:
			if absi(altitude - unit.altitude) > 1:
				continue
			var candidates: Array[MovementOrder] = []
			if manoeuvre.kind == "charge":
				if altitude == 0:
					for enemy in MeleeRules.charge_targets(battle, unit, manoeuvre):
						candidates.append(MovementRules.create_order(battle, unit, manoeuvre, enemy.position, 0, 0, enemy))
			elif manoeuvre.kind == "aircraft":
				candidates.append(MovementRules.create_order(battle, unit, manoeuvre, unit.position, 0, altitude))
			else:
				var maximum := MovementRules.maximum_distance(unit, manoeuvre)
				var angles: Array = [-180.0, -135.0, -90.0, -45.0, 0.0, 45.0, 90.0, 135.0, 180.0] if manoeuvre.kind == "ground" else [-manoeuvre.turn_degrees, 0.0, manoeuvre.turn_degrees]
				if manoeuvre.kind == "lateral":
					angles = [-90.0, 90.0]
				if manoeuvre.kind == "reverse":
					angles = [180.0]
				for angle in angles:
					for distance in [manoeuvre.minimum_move, maximum * 0.6, maximum]:
						var heading := unit.facing + deg_to_rad(angle)
						var destination: Vector2 = unit.position + Vector2(sin(heading), -cos(heading)) * float(distance)
						var target := nearest(enemies, destination)
						var delta := rad_to_deg(wrapf(atan2(target.position.x - destination.x, destination.y - target.position.y) - unit.facing, -PI, PI))
						delta = clampf(delta, -manoeuvre.turn_degrees, manoeuvre.turn_degrees)
						candidates.append(MovementRules.create_order(battle, unit, manoeuvre, destination, delta, altitude))
			for order in candidates:
				if not order.valid:
					continue
				var score := score_order(battle, unit, order, enemies)
				if score > score_best:
					score_best = score
					best = order
	if best != null:
		best.confirmed = true
	return best

static func nearest(enemies: Array[UnitState], position: Vector2) -> UnitState:
	var best := enemies[0]
	for enemy in enemies:
		if enemy.position.distance_squared_to(position) < best.position.distance_squared_to(position):
			best = enemy
	return best

static func score_order(battle: BattleState, unit: UnitState, order: MovementOrder, enemies: Array[UnitState]) -> float:
	# Evaluate a detached state: AI never moves authoritative units while planning.
	var projected := UnitState.new(unit.loadout)
	unit.copy_stats_to(projected)
	projected.position = order.destination
	projected.facing = order.facing
	projected.altitude = order.altitude
	projected.energy = unit.energy - order.energy_cost
	projected.charge_target = order.target_id
	var target := nearest(enemies, order.destination)
	var distance := projected.range_position().distance_to(target.range_position())
	var score := -distance * 0.8 - order.energy_cost * 0.3
	if order.leaves_battlefield:
		score -= 1000.0
	var offset := target.position - projected.position
	score += projected.forward().dot(offset.normalized()) * 2.0
	var best_attack := 0.0
	for weapon in unit.loadout.weapons:
		for enemy in enemies:
			if CombatRules.target_error(battle, projected, enemy, weapon).is_empty():
				best_attack = maxf(best_attack, CombatRules.expected_damage(battle, projected, enemy, weapon))
	score += best_attack * 4.0
	# A charge locks the charger in: weigh what the target can swing back each round.
	var charged := battle.unit_by_id(order.target_id)
	if charged != null:
		var retaliation := 0.0
		for weapon in charged.loadout.weapons:
			if weapon.melee and weapon.energy_cost <= charged.energy:
				retaliation = maxf(retaliation, CombatRules.expected_damage(battle, charged, projected, weapon))
		score -= retaliation * 2.0
	if order.altitude == 0:
		score += TerrainRules.cover(battle, target, projected) * 0.6
	# Keep fast units away from the table edge, with room for next round's turn.
	if unit.loadout.frame.movement_type == "aircraft":
		var future := order.destination + projected.forward() * 3.0
		if not battle.bounds.grow(-1).has_point(future):
			score -= 7.0
	return score

static func choose_attack(battle: BattleState, unit: UnitState) -> Dictionary:
	var best := {}
	var best_score := -INF
	for weapon in unit.loadout.weapons:
		for target in CombatRules.legal_targets(battle, unit, weapon):
			var score := CombatRules.expected_damage(battle, unit, target, weapon) - weapon.energy_cost * 0.1 + 0.5 / target.structure
			if score > best_score:
				best_score = score
				best = {"weapon": weapon, "target": target, "push": false}
	if not best.is_empty():
		best.push = should_push(battle, unit, best.target, best.weapon)
	return best

## Will never refills, so Push is saved for shots where it meaningfully raises the damage or the chance to destroy.
static func should_push(battle: BattleState, unit: UnitState, target: UnitState, weapon: WeaponData) -> bool:
	if CombatRules.push_option(battle, unit).is_empty():
		return false
	var plain := CombatRules.forecast(battle, unit, target, weapon)
	var pushed := CombatRules.forecast(battle, unit, target, weapon, false, true)
	return pushed.p_destroy - plain.p_destroy >= 0.1 or pushed.expected - plain.expected >= target.structure * 0.25

## Break off when the foes out-hit this unit in melee, unless it is close to finishing one of them.
## Units with no way to hurt their foes always try to leave.
static func should_break_off(battle: BattleState, unit: UnitState) -> bool:
	if not MeleeRules.break_off_error(battle, unit).is_empty():
		return false
	var outgoing := 0.0
	for foe in MeleeRules.foes(battle, unit):
		for weapon in unit.loadout.weapons:
			if CombatRules.target_error(battle, unit, foe, weapon).is_empty():
				var expected := CombatRules.expected_damage(battle, unit, foe, weapon)
				if expected >= foe.structure * 0.6:
					return false
				outgoing = maxf(outgoing, expected)
	var incoming := 0.0
	for foe in MeleeRules.foes(battle, unit):
		var weapon := MeleeRules.parting_weapon(battle, foe, unit)
		if weapon != null:
			incoming += CombatRules.expected_damage(battle, foe, unit, weapon)
	# Leaving costs one parting strike; staying costs a strike every round.
	return outgoing <= 0.0 or (incoming > outgoing * 1.5 and MeleeRules.parting_damage(battle, unit) < unit.structure * 0.5)
