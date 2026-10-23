class_name MeleeRules
extends RefCounted

## Charges, engagements and breaking off. A Charge order homes on an enemy; if it reaches base
## contact, both units are engaged. Engaged units cannot move and can only attack the units they are
## engaged with, so the pair trades blows each Attack phase. Breaking off is an Action-phase choice:
## the unit backs away, and every foe it leaves takes its attack for the round early, at +20%.
const CHARGE_BONUS: float = 20.0
## Edge-to-edge gap a charge stops at; well inside the 0.5 melee reach.
const CONTACT_GAP: float = 0.05
## An engagement holds while the bases stay within melee reach of each other.
const ENGAGE_REACH: float = 0.5
const BREAK_OFF_DISTANCE: float = 1.5
## A unit turning away is easier to hit. Does not stack with the charge bonus.
const PARTING_BONUS: float = 20.0
const PATH_STEPS: int = 64

## Living enemies locked in melee with this unit.
static func foes(battle: BattleState, unit: UnitState) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for id in unit.engaged:
		var other := battle.unit_by_id(id)
		if other != null and other.alive():
			result.append(other)
	return result

static func is_engaged(battle: BattleState, unit: UnitState) -> bool:
	return unit.alive() and not foes(battle, unit).is_empty()

static func engaged_with(unit: UnitState, other: UnitState) -> bool:
	return other.loadout.id in unit.engaged

static func engage(a: UnitState, b: UnitState) -> void:
	if b.loadout.id not in a.engaged:
		a.engaged.append(b.loadout.id)
	if a.loadout.id not in b.engaged:
		b.engaged.append(a.loadout.id)

static func separate(a: UnitState, b: UnitState) -> void:
	a.engaged.erase(b.loadout.id)
	b.engaged.erase(a.loadout.id)

static func edge_gap(a: UnitState, b: UnitState, a_position: Vector2 = Vector2.INF) -> float:
	var from := a.position if a_position == Vector2.INF else a_position
	return from.distance_to(b.position) - a.loadout.frame.size - b.loadout.frame.size

## Drops engagements with destroyed units, or units no longer in reach (debug moves, altitude edits).
static func clean(battle: BattleState) -> void:
	for unit in battle.units:
		var kept: Array[String] = []
		for id in unit.engaged:
			var other := battle.unit_by_id(id)
			if unit.alive() and other != null and other.alive() and other.altitude == unit.altitude and edge_gap(unit, other) <= ENGAGE_REACH + 0.05:
				kept.append(id)
		unit.engaged = kept

static func facing_toward(from: Vector2, to: Vector2) -> float:
	return atan2(to.x - from.x, from.y - to.y)

## Engaged units square up to their first foe at the start of each round.
static func face_foes(battle: BattleState) -> void:
	for unit in battle.living():
		var enemies := foes(battle, unit)
		if not enemies.is_empty():
			unit.facing = facing_toward(unit.position, enemies[0].position)

static func can_be_charged(unit: UnitState, target: UnitState) -> bool:
	return target != null and target.alive() and target.loadout.faction != unit.loadout.faction and target.altitude == 0 and target.loadout.frame.movement_type != "aircraft"

## Where a charger stops: just short of base contact, on the line from the target back toward from.
static func contact_point(unit: UnitState, target: UnitState, from: Vector2) -> Vector2:
	var away := from - target.position
	if away.length() < 0.01:
		away = -unit.forward()
	return target.position + away.normalized() * (unit.loadout.frame.size + target.loadout.frame.size + CONTACT_GAP)

static func create_charge(battle: BattleState, unit: UnitState, manoeuvre: ManoeuvreData, target: UnitState) -> MovementOrder:
	var order := MovementOrder.new()
	order.unit_id = unit.loadout.id
	order.manoeuvre_id = manoeuvre.id
	order.altitude = 0
	order.energy_cost = manoeuvre.energy_cost
	order.target_id = target.loadout.id if target != null else ""
	order.path.append(unit.position)
	order.destination = unit.position
	order.facing = unit.facing
	if target != null:
		var offset := contact_point(unit, target, unit.position) - unit.position
		# Out-of-reach drafts still draw toward the target so the player sees how far short they fall.
		var travel := minf(offset.length(), MovementRules.maximum_distance(unit, manoeuvre) + 0.5)
		if offset.length() > 0.01:
			order.destination = unit.position + offset.normalized() * travel
		order.facing = facing_toward(order.destination, target.position)
		for i in range(1, PATH_STEPS + 1):
			order.path.append(unit.position.lerp(order.destination, float(i) / PATH_STEPS))
	order.reason = MovementRules.validation_error(battle, unit, order)
	order.valid = order.reason.is_empty()
	return order

## Charge-specific planning checks; MovementRules.validation_error checks the path afterwards.
static func charge_error(battle: BattleState, unit: UnitState, order: MovementOrder, move: ManoeuvreData) -> String:
	var target := battle.unit_by_id(order.target_id)
	if target == null or not target.alive():
		return "Click an enemy to charge."
	if target.loadout.faction == unit.loadout.faction:
		return "Charge an enemy, not a friendly unit."
	if not can_be_charged(unit, target):
		return "Only Ground units can be charged."
	var offset := target.position - unit.position
	if absf(rad_to_deg(unit.forward().angle_to(offset))) > move.turn_degrees + 0.5:
		return "Target must be inside the ±%d° charge cone ahead." % int(move.turn_degrees)
	var needed := unit.position.distance_to(contact_point(unit, target, unit.position))
	var reach := MovementRules.maximum_distance(unit, move)
	if needed > reach + 0.025:
		return "Out of charge reach (%.1f needed, %.1f available)." % [needed, reach]
	return ""

## Enemies this unit could legally charge this round with the given manoeuvre.
static func charge_targets(battle: BattleState, unit: UnitState, manoeuvre: ManoeuvreData) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for enemy in battle.living(1 - unit.loadout.faction):
		if can_be_charged(unit, enemy) and create_charge(battle, unit, manoeuvre, enemy).valid:
			result.append(enemy)
	return result

## Movement-phase resolution. The charge homes on where the target is now (it may already have moved),
## stops at anything in the way, and engages if it ends in reach.
static func resolve_charge(battle: BattleState, unit: UnitState) -> Dictionary:
	var order := unit.order
	var name := unit.loadout.callsign
	var move: ManoeuvreData = battle.catalogue.manoeuvres[order.manoeuvre_id]
	var target := battle.unit_by_id(order.target_id)
	if target == null or not target.alive():
		return {"moved": false, "message": "%s: charge target is gone; holds." % name}
	if unit.altitude != 0 or unit.energy < order.energy_cost:
		return {"moved": false, "message": "%s cannot charge; holds." % name}
	var size := unit.loadout.frame.size
	var offset := contact_point(unit, target, unit.position) - unit.position
	var travel := minf(offset.length(), MovementRules.maximum_distance(unit, move))
	var direction := offset.normalized() if offset.length() > 0.01 else Vector2.ZERO
	var travelled := PackedVector2Array([unit.position])
	var endpoint := unit.position
	var stopped := ""
	for i in range(1, PATH_STEPS + 1):
		var point := unit.position + direction * travel * i / PATH_STEPS
		if not battle.bounds.grow(-size).has_point(point):
			stopped = "the table edge"
		elif TerrainRules.blocks_point(battle, point, size, 0):
			stopped = "terrain"
		else:
			for other in battle.living():
				if other != unit and other.altitude == 0 and point.distance_to(other.position) < size + other.loadout.frame.size:
					stopped = other.loadout.callsign
					break
		if not stopped.is_empty():
			break
		endpoint = point
		travelled.append(point)
	unit.position = endpoint
	if endpoint.distance_to(target.position) > 0.01:
		unit.facing = facing_toward(endpoint, target.position)
	unit.energy -= order.energy_cost
	var connected := target.altitude == unit.altitude and edge_gap(unit, target) <= ENGAGE_REACH
	var message: String
	if connected:
		engage(unit, target)
		unit.charge_target = target.loadout.id
		message = "%s CHARGES into %s · locked in melee (+%d%% melee to hit this round)." % [name, target.loadout.callsign, int(CHARGE_BONUS)]
	elif target.altitude != 0:
		message = "%s charges, but %s is airborne and out of reach." % [name, target.loadout.callsign]
	elif not stopped.is_empty():
		message = "%s charges but is stopped by %s, short of %s." % [name, stopped, target.loadout.callsign]
	else:
		message = "%s charges but falls %.1f short of %s." % [name, edge_gap(unit, target), target.loadout.callsign]
	return {"moved": travelled.size() > 1, "path": travelled, "message": message, "engaged": connected}

## Extra to-hit for a parting strike, after any charge bonus the foe already has against this unit.
static func parting_bonus(foe: UnitState, unit: UnitState) -> float:
	return maxf(0.0, PARTING_BONUS - (CHARGE_BONUS if CombatRules.charge_bonus(foe, unit) else 0.0))

## The strongest melee weapon a foe can legally swing at this unit right now, or null. A foe that
## has already attacked this round has no parting strike left.
static func parting_weapon(battle: BattleState, foe: UnitState, unit: UnitState) -> WeaponData:
	var best: WeaponData
	var best_damage := -1.0
	for weapon in foe.loadout.weapons:
		if weapon.melee and not foe.attacked and CombatRules.target_error(battle, foe, unit, weapon).is_empty():
			var expected := CombatRules.expected_damage(battle, foe, unit, weapon, parting_bonus(foe, unit))
			if expected > best_damage:
				best_damage = expected
				best = weapon
	return best

## Expected damage of every parting strike, for previews and AI.
static func parting_damage(battle: BattleState, unit: UnitState) -> float:
	var total := 0.0
	for foe in foes(battle, unit):
		var weapon := parting_weapon(battle, foe, unit)
		if weapon != null:
			total += CombatRules.expected_damage(battle, foe, unit, weapon, parting_bonus(foe, unit))
	return total

## Backs straight away from the foes if possible, otherwise angles off; shorter steps if room is tight.
static func break_off_destination(battle: BattleState, unit: UnitState) -> Vector2:
	var enemies := foes(battle, unit)
	if enemies.is_empty():
		return Vector2.INF
	var centre := Vector2.ZERO
	for foe in enemies:
		centre += foe.position
	centre /= enemies.size()
	var away := unit.position - centre
	var base := atan2(away.x, -away.y) if away.length() > 0.01 else unit.facing + PI
	for spread in [0.0, 30.0, -30.0, 60.0, -60.0, 90.0, -90.0]:
		var heading := base + deg_to_rad(spread)
		var direction := Vector2(sin(heading), -cos(heading))
		for distance in [BREAK_OFF_DISTANCE, 1.0, 0.75]:
			var point: Vector2 = unit.position + direction * float(distance)
			if step_clear(battle, unit, point, enemies):
				return point
	return Vector2.INF

static func step_clear(battle: BattleState, unit: UnitState, point: Vector2, enemies: Array[UnitState]) -> bool:
	var size := unit.loadout.frame.size
	for foe in enemies:
		if edge_gap(unit, foe, point) <= ENGAGE_REACH + 0.05:
			return false
	for i in range(1, 17):
		var sample := unit.position.lerp(point, i / 16.0)
		if not battle.bounds.grow(-size).has_point(sample) or TerrainRules.blocks_point(battle, sample, size, unit.altitude):
			return false
		for other in battle.living(1 - unit.loadout.faction):
			if other.altitude == unit.altitude and sample.distance_to(other.position) < size + other.loadout.frame.size - 0.01:
				return false
	return not MovementRules.overlaps(battle, unit, point, unit.altitude)

static func break_off_error(battle: BattleState, unit: UnitState) -> String:
	if not is_engaged(battle, unit):
		return "Not locked in melee."
	if unit.action_used:
		return "This unit has already used its action."
	if break_off_destination(battle, unit) == Vector2.INF:
		return "No room to break off."
	return ""

## Every foe with a melee weapon takes its attack for this round now, at +20%; then the unit backs away,
## keeping its facing. Uses the unit's action.
static func break_off(battle: BattleState, unit: UnitState) -> Dictionary:
	var error := break_off_error(battle, unit)
	if not error.is_empty():
		return {"ok": false, "reason": error}
	var destination := break_off_destination(battle, unit)
	var strikes: Array[AttackResult] = []
	for foe in foes(battle, unit):
		var weapon := parting_weapon(battle, foe, unit)
		if weapon != null:
			var result := CombatRules.resolve(battle, foe, unit, weapon, false, Callable(), false, parting_bonus(foe, unit))
			if result != null:
				result.parting = true
				strikes.append(result)
		if not unit.alive():
			break
	for id in unit.engaged.duplicate():
		var other := battle.unit_by_id(id)
		if other != null:
			separate(unit, other)
	unit.engaged.clear()
	unit.action_used = true
	var name := unit.loadout.callsign
	if not unit.alive():
		return {"ok": true, "strikes": strikes, "moved": false, "path": PackedVector2Array(), "message": "%s is cut down trying to break off." % name}
	var path := PackedVector2Array()
	for i in range(PATH_STEPS + 1):
		path.append(unit.position.lerp(destination, float(i) / PATH_STEPS))
	unit.position = destination
	return {"ok": true, "strikes": strikes, "moved": true, "path": path, "message": "%s breaks off from melee and backs away %.1f." % [name, path[0].distance_to(destination)]}
