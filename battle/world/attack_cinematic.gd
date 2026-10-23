class_name AttackCinematic
extends RefCounted

## Plans the camera for one attack: over the attacker's shoulder as it fires, then a cut to the target.
## Pure geometry over battle terrain, so it can be tested without rendering.
## Each step is {start, end, duration, blend}: the camera drifts start→end; blend 0 is a hard cut.
const LEAD := 0.45
const FIRE_HOLD := 0.7
const REACTION := {"miss": 0.7, "hit": 1.0, "destroyed": 1.6}
const LENS := 38.0
const WIDE_LENS := 46.0

## Seconds from the cinematic's start until the shot is fired; attack visuals wait this long.
static func lead() -> float:
	return LEAD

## Seconds until the target's reaction shot begins; hit and death visuals land there.
static func reaction_start() -> float:
	return LEAD + FIRE_HOLD

## Points are each unit's chest; scales are the frames' model scales, so large frames are framed further out.
static func plan(battle: BattleState, attacker_point: Vector3, target_point: Vector3, result: AttackResult, attacker_scale: float = 1.0, target_scale: float = 1.0) -> Array:
	var a := attacker_point
	var b := target_point
	var flat := Vector3(b.x - a.x, 0, b.z - a.z)
	var forward := flat.normalized() if flat.length() > 0.05 else Vector3.FORWARD
	var right := forward.cross(Vector3.UP).normalized()
	var reaction: float = REACTION.destroyed if result.destroyed else (REACTION.hit if result.damage > 0 else REACTION.miss)
	var opening: Array = []
	var answer: Array = []
	for side in [1.0, -1.0]:
		# Over the shoulder: behind and beside the attacker, looking past it toward the target.
		var shoulder: Vector3 = a + (-forward * 2.4 + right * side * 1.05 + Vector3.UP * 0.75) * attacker_scale
		var aim := a.lerp(b, 0.62) + Vector3.UP * 0.1
		opening.append([CameraShot.looking(shoulder, aim, LENS), CameraShot.looking(shoulder + forward * 0.35 * attacker_scale, aim, LENS - 3.0)])
		# Reaction: low, beyond and beside the target, looking back along the line of fire at its front.
		var low: Vector3 = b + (forward * 2.0 + right * side * 3.5 + Vector3.UP * 0.1) * target_scale
		var subject := b + Vector3.UP * 0.15 * target_scale
		answer.append([CameraShot.looking(low, subject, LENS), CameraShot.looking(low - right * side * 0.5 * target_scale, subject, LENS - 4.0)])
	# Fallback: a high three-quarter two-shot clears almost any cover.
	var middle := a.lerp(b, 0.5)
	var span := flat.length()
	for side in [1.0, -1.0]:
		var high: Vector3 = middle + right * side * (span * 0.55 + 3.0) - forward * 1.5 + Vector3.UP * (span * 0.35 + 3.2)
		var wide := [CameraShot.looking(high, middle, WIDE_LENS), CameraShot.looking(high * 0.94 + middle * 0.06, middle, WIDE_LENS - 3.0)]
		opening.append(wide)
		answer.append(wide)
	var first: Array = pick(battle, opening, a, b)
	var second: Array = pick(battle, answer, a, b)
	if first.is_empty() or second.is_empty():
		return []
	return [
		{"start": first[0], "end": first[1], "duration": LEAD + FIRE_HOLD, "blend": LEAD},
		{"start": second[0], "end": second[1], "duration": reaction, "blend": 0.0},
	]

static func total(steps: Array) -> float:
	var seconds := 0.0
	for step in steps:
		seconds += float(step.duration)
	return seconds

static func pick(battle: BattleState, candidates: Array, a: Vector3, b: Vector3) -> Array:
	for pair in candidates:
		var eye: Vector3 = pair[0].eye()
		if clear_view(battle, eye, a, [a, b]) and clear_view(battle, eye, b, [a, b]):
			return pair
	return []

## Any terrain box hides a subject from the camera, not only sight-blocking terrain.
## Boxes holding a subject are ignored: a destroyed target already stands in its own wreck.
static func clear_view(battle: BattleState, eye: Vector3, subject: Vector3, subjects: Array) -> bool:
	if eye.y < 0.25:
		return false
	for terrain in battle.terrain:
		var rect := TerrainRules.footprint(terrain)
		if subjects.any(func(point: Vector3) -> bool: return rect.has_point(Vector2(point.x, point.z))):
			continue
		var box := AABB(Vector3(rect.position.x, 0, rect.position.y), Vector3(rect.size.x, float(terrain.height), rect.size.y))
		if box.has_point(eye) or box.intersects_segment(eye, subject) != null:
			return false
	return true
