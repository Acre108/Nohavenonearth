class_name MovementOrder
extends RefCounted

var unit_id: String = ""
var manoeuvre_id: String = ""
var path: PackedVector2Array = []
var destination: Vector2
var facing: float = 0.0
var altitude: int = 0
var energy_cost: int = 0
var valid: bool = false
var reason: String = "Choose a destination."
var confirmed: bool = false
var leaves_battlefield: bool = false
## Charge orders home on this unit instead of a fixed point.
var target_id: String = ""

func to_dict() -> Dictionary:
	var points: Array = []
	for point in path:
		points.append([point.x, point.y])
	return {"unit": unit_id, "manoeuvre": manoeuvre_id, "path": points,
		"destination": [destination.x, destination.y], "facing": facing,
		"altitude": altitude, "energy_cost": energy_cost, "confirmed": confirmed, "target": target_id}
