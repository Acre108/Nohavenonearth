class_name TerrainRules
extends RefCounted

static func footprint(terrain: Dictionary, expand: float = 0.0) -> Rect2:
	var center := Vector2(terrain.position[0], terrain.position[1])
	var half := Vector2(terrain.half_size[0], terrain.half_size[1]) + Vector2.ONE * expand
	return Rect2(center - half, half * 2.0)

static func blocks_point(battle: BattleState, point: Vector2, radius: float, altitude: int) -> bool:
	for terrain in battle.terrain:
		if terrain.blocks_move and float(terrain.height) >= altitude * 1.7 + 0.2 and footprint(terrain, radius).has_point(point):
			return true
	return false

static func line_of_sight(battle: BattleState, from: UnitState, to: UnitState) -> bool:
	return sight_clear(battle, from.world_position() + Vector3.UP * 0.7, to.world_position() + Vector3.UP * 0.7)

## Eye height used for a unit at an altitude band; lets previews ask about points with no unit in them.
static func eye(point: Vector2, altitude: int) -> Vector3:
	return Vector3(point.x, 0.08 + altitude * 1.7 + 0.7, point.y)

static func sight_clear(battle: BattleState, a: Vector3, b: Vector3) -> bool:
	for terrain in battle.terrain:
		if not terrain.blocks_los:
			continue
		var rect := footprint(terrain)
		var box := AABB(Vector3(rect.position.x, 0, rect.position.y), Vector3(rect.size.x, float(terrain.height), rect.size.y))
		if box.intersects_segment(a, b) != null:
			return false
	return true

static func cover(battle: BattleState, attacker: UnitState, defender: UnitState) -> int:
	if defender.altitude == 2:
		return 0
	var result := 0
	var toward := (attacker.position - defender.position).normalized()
	for terrain in battle.terrain:
		if float(terrain.height) < defender.altitude * 1.7 + 0.4:
			continue
		var area := footprint(terrain, 0.25)
		# Cover must lie toward the attacker, within 1.1 units of the defender.
		for step in range(12):
			if area.has_point(defender.position + toward * step * 0.1):
				result = maxi(result, int(terrain.cover))
	return result
