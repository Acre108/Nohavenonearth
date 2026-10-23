class_name BattleState
extends RefCounted

var catalogue: Catalogue
var units: Array[UnitState] = []
var terrain: Array = []
var round_number: int = 1
var bounds := Rect2(-11, -8, 22, 16)
var rng := RandomNumberGenerator.new()

func _init(data: Catalogue = null, random_seed: int = -1) -> void:
	if data == null:
		return
	catalogue = data
	bounds = data.battlefield_bounds
	terrain = data.terrain.duplicate(true)
	if random_seed < 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	for loadout in data.loadouts:
		units.append(UnitState.new(loadout))

func living(faction: int = -1) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for unit in units:
		if unit.alive() and (faction == -1 or unit.loadout.faction == faction):
			result.append(unit)
	return result

func unit_by_id(id: String) -> UnitState:
	for unit in units:
		if unit.loadout.id == id:
			return unit
	return null

func initiative(ascending: bool) -> Array[UnitState]:
	var result := living()
	# Fisher-Yates before a stable insertion sort provides seeded, random tie order.
	for i in range(result.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp := result[i]
		result[i] = result[j]
		result[j] = temp
	for i in range(1, result.size()):
		var item := result[i]
		var j := i - 1
		while j >= 0:
			var ahead := result[j].stat("reflex") > item.stat("reflex") if ascending else result[j].stat("reflex") < item.stat("reflex")
			if not ahead:
				break
			result[j + 1] = result[j]
			j -= 1
		result[j + 1] = item
	return result

## Destroyed mechs become low, non-blocking cover terrain; aircraft debris is visual only.
func add_wreck(unit: UnitState) -> bool:
	if unit.alive() or unit.withdrawn or unit.loadout.frame.movement_type == "aircraft" or wreck_index(unit) >= 0:
		return false
	var half := unit.loadout.frame.size + 0.15
	terrain.append({"id": "wreck_" + unit.loadout.id, "name": "WRECK / +1 COVER", "position": [unit.position.x, unit.position.y],
		"half_size": [half, half], "height": 0.65, "cover": 1, "blocks_move": false, "blocks_los": false, "wreck": true})
	return true

func remove_wreck(unit: UnitState) -> void:
	var index := wreck_index(unit)
	if index >= 0:
		terrain.remove_at(index)

func wreck_index(unit: UnitState) -> int:
	for i in terrain.size():
		if terrain[i].get("id", "") == "wreck_" + unit.loadout.id:
			return i
	return -1

func winner() -> int:
	if living(0).is_empty() and living(1).is_empty():
		return 2
	if living(1).is_empty():
		return 0
	if living(0).is_empty():
		return 1
	return -1

func to_dict() -> Dictionary:
	return {"round": round_number, "bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "units": units.map(func(unit: UnitState) -> Dictionary: return unit.to_dict()), "rng_state": rng.state}
