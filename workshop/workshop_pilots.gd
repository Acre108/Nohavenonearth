class_name WorkshopPilots
extends RefCounted
## Workshop roster stays separate from the standalone battle catalogue.
const CONTENT := "res://data/catalogues/workshop_pilots.json"
var entries: Dictionary = {}

func _init() -> void:
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CONTENT))
	for entry in source.pilots:
		assert(not entries.has(entry.id), "Duplicate workshop pilot")
		for key in UnitState.STAT_NAMES:
			var value: float = entry.stats.get(key, 0)
			assert(value >= 0 and value <= UnitState.STAT_CAPS[key] and is_equal_approx(value * 4, roundf(value * 4)), "Invalid pilot stat")
		entries[entry.id] = entry

func pilot(id: String) -> PilotData:
	var entry: Dictionary = entries[id]
	var result := PilotData.new()
	result.id = entry.id
	result.display_name = entry.display_name
	result.stats = entry.stats.duplicate(true)
	result.abilities.assign(entry.abilities)
	return result
