class_name MovementRules
extends RefCounted

static func available(battle: BattleState, unit: UnitState) -> Array[ManoeuvreData]:
	var result: Array[ManoeuvreData] = []
	for id in unit.loadout.frame.manoeuvres:
		var manoeuvre: ManoeuvreData = battle.catalogue.manoeuvres[id]
		if manoeuvre.kind not in ["ground", "charge"] or unit.altitude == 0:
			result.append(manoeuvre)
	return result

## Speed comes from the frame only; fixed-distance manoeuvres and flight paths keep their listed length.
static func maximum_distance(unit: UnitState, manoeuvre: ManoeuvreData) -> float:
	if manoeuvre.distance > 0:
		return manoeuvre.distance
	return maxf(1, unit.loadout.frame.base_move + manoeuvre.move_modifier)

## target: the enemy a Charge homes on; other manoeuvres ignore it.
static func create_order(battle: BattleState, unit: UnitState, manoeuvre: ManoeuvreData, destination: Vector2, rotation_degrees: float = 0.0, altitude: int = -1, target: UnitState = null) -> MovementOrder:
	if manoeuvre.kind == "charge":
		return MeleeRules.create_charge(battle, unit, manoeuvre, target)
	var order := MovementOrder.new()
	order.unit_id = unit.loadout.id
	order.manoeuvre_id = manoeuvre.id
	order.altitude = unit.altitude if altitude < 0 else altitude
	order.energy_cost = manoeuvre.energy_cost
	order.destination = destination
	order.facing = unit.facing + deg_to_rad(rotation_degrees)
	order.path.append(unit.position)
	if manoeuvre.kind == "aircraft":
		var point := unit.position
		var length := maximum_distance(unit, manoeuvre)
		for i in range(1, 65):
			var heading := unit.facing + deg_to_rad(manoeuvre.turn_degrees) * (i - 0.5) / 64.0
			point += Vector2(sin(heading), -cos(heading)) * length / 64.0
			order.path.append(point)
		order.destination = point
		order.facing = unit.facing + deg_to_rad(manoeuvre.turn_degrees)
		for path_point in order.path:
			if not battle.bounds.grow(-unit.loadout.frame.size).has_point(path_point):
				order.leaves_battlefield = true
	else:
		for i in range(1, 65):
			order.path.append(unit.position.lerp(destination, i / 64.0))
	order.reason = validation_error(battle, unit, order)
	order.valid = order.reason.is_empty()
	return order

static func validation_error(battle: BattleState, unit: UnitState, order: MovementOrder, check_units: bool = true) -> String:
	if not unit.alive():
		return "Unit destroyed."
	if MeleeRules.is_engaged(battle, unit):
		return "Locked in melee: break off in the Action phase."
	if order.unit_id != unit.loadout.id or not battle.catalogue.manoeuvres.has(order.manoeuvre_id):
		return "Unknown movement order."
	var move: ManoeuvreData = battle.catalogue.manoeuvres[order.manoeuvre_id]
	if move.id not in unit.loadout.frame.manoeuvres:
		return "Frame does not support this manoeuvre."
	if unit.energy < move.energy_cost:
		return "Insufficient Energy."
	if order.altitude not in unit.loadout.frame.altitude_access or absi(order.altitude - unit.altitude) > 1:
		return "Altitude not accessible."
	if move.kind in ["ground", "charge"] and (unit.altitude != 0 or order.altitude != 0):
		return "%s requires Ground altitude." % move.display_name + (" Choose Cruise to take off." if move.kind == "ground" else "")
	if order.path.is_empty() or order.path[0].distance_to(unit.position) > 0.05:
		return "Order has a stale starting position."
	var displacement := order.destination - unit.position
	var distance := displacement.length()
	if move.kind == "charge":
		var charge := MeleeRules.charge_error(battle, unit, order, move)
		if not charge.is_empty():
			return charge
	elif move.kind != "aircraft":
		if distance < move.minimum_move - 0.025 or distance > maximum_distance(unit, move) + 0.025:
			return "Move %.1f–%.1f units (currently %.1f)." % [move.minimum_move, maximum_distance(unit, move), distance]
		var turn := absf(rad_to_deg(wrapf(order.facing - unit.facing, -PI, PI)))
		if turn > absf(move.turn_degrees) + 0.1:
			return "Final facing exceeds the turn limit."
		if distance > 0.01:
			var angle := absf(rad_to_deg(unit.forward().angle_to(displacement)))
			if move.kind == "vector" and angle > move.turn_degrees + 0.5:
				return "Destination must be inside the forward movement cone."
			if move.kind == "lateral" and absf(angle - 90.0) > 3:
				return "Lateral Thrust moves directly sideways."
			if move.kind == "reverse" and angle < 177:
				return "Reverse Vector moves directly backwards."
	for point in order.path:
		if move.kind != "aircraft" and not battle.bounds.grow(-unit.loadout.frame.size).has_point(point):
			return "Path leaves the battlefield. Choose a turn."
		if TerrainRules.blocks_point(battle, point, unit.loadout.frame.size, order.altitude):
			return "Path crosses terrain at this altitude."
		if check_units and order.altitude == 0:
			for other in battle.living(1 - unit.loadout.faction):
				if other.altitude == 0 and point.distance_to(other.position) < unit.loadout.frame.size + other.loadout.frame.size - 0.01:
					return "Ground paths cannot pass through an enemy."
	if check_units and overlaps(battle, unit, order.destination, order.altitude):
		return "Destination overlaps a unit at the same altitude."
	return ""

static func overlaps(battle: BattleState, unit: UnitState, point: Vector2, altitude: int) -> bool:
	for other in battle.living():
		if other != unit and other.altitude == altitude and point.distance_to(other.position) < unit.loadout.frame.size + other.loadout.frame.size - 0.005:
			return true
	return false

static func resolve(battle: BattleState, unit: UnitState) -> Dictionary:
	var order := unit.order
	# Includes units caught by a faster unit's charge earlier this phase: their own order is lost.
	if MeleeRules.is_engaged(battle, unit):
		return {"moved": false, "message": "%s is locked in melee and cannot move." % unit.loadout.callsign}
	if order == null:
		return {"moved": false, "message": "%s has no order." % unit.loadout.callsign}
	if battle.catalogue.manoeuvres[order.manoeuvre_id].kind == "charge":
		return MeleeRules.resolve_charge(battle, unit)
	var error := validation_error(battle, unit, order, false)
	if not error.is_empty():
		return {"moved": false, "message": "%s holds: %s" % [unit.loadout.callsign, error]}
	var stop_for_overlap := overlaps(battle, unit, order.destination, order.altitude)
	var endpoint := unit.position
	var travelled := PackedVector2Array([unit.position])
	var collided := false
	for i in range(1, order.path.size()):
		var point := order.path[i]
		var blocked := false
		for other in battle.living():
			if other == unit or other.altitude != order.altitude:
				continue
			if (stop_for_overlap or (order.altitude == 0 and other.loadout.faction != unit.loadout.faction)) and point.distance_to(other.position) < unit.loadout.frame.size + other.loadout.frame.size:
				blocked = true
				break
		if blocked:
			collided = true
			break
		endpoint = point
		travelled.append(point)
	# An altitude change into an occupied start cannot place two units together.
	if overlaps(battle, unit, endpoint, order.altitude):
		return {"moved": false, "message": "%s: altitude change blocked; holds safely." % unit.loadout.callsign}
	unit.position = endpoint
	unit.altitude = order.altitude
	unit.facing = order.facing
	if collided and travelled.size() > 1 and unit.loadout.frame.movement_type == "aircraft":
		var direction := travelled[-1] - travelled[-2]
		unit.facing = atan2(direction.x, -direction.y)
	unit.energy -= order.energy_cost
	if order.leaves_battlefield and not collided:
		unit.structure = 0
		unit.withdrawn = true
		return {"moved": true, "path": travelled, "message": "%s leaves the battlefield and WITHDRAWS (removed from battle)." % unit.loadout.callsign}
	var detail := " — collision avoided, stopped short of contact" if collided else " at %s altitude%s" % [UnitState.ALTITUDES[unit.altitude].capitalize(), (", %d Energy" % order.energy_cost) if order.energy_cost > 0 else ""]
	return {"moved": true, "path": travelled, "message": "%s: %s%s." % [unit.loadout.callsign, battle.catalogue.manoeuvres[order.manoeuvre_id].display_name, detail]}
