class_name SizeClass
extends RefCounted

## One table drives base radius, model scale, how easy a frame is to hit, and which weapons it can carry.
const ORDER: Array[String] = ["small", "medium", "large", "super_heavy"]
const RADIUS := {"small": 0.25, "medium": 0.32, "large": 0.40, "super_heavy": 0.55}
const MODEL_SCALE := {"small": 0.8, "medium": 1.0, "large": 1.2, "super_heavy": 1.5}
## Added to the hit chance of attacks against a target of this size.
const HIT_MODIFIER := {"small": -10.0, "medium": 0.0, "large": 10.0, "super_heavy": 20.0}
const NAMES := {"small": "Small", "medium": "Medium", "large": "Large", "super_heavy": "Super heavy"}

static func valid(size: String) -> bool:
	return size in ORDER

## A frame mounts weapons of its own class or smaller.
static func can_carry(frame_size: String, weapon_size: String) -> bool:
	return ORDER.find(weapon_size) <= ORDER.find(frame_size)
