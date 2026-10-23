class_name Catalogue
extends RefCounted

var pilots: Dictionary = {}
var frames: Dictionary = {}
var weapons: Dictionary = {}
var manoeuvres: Dictionary = {}
var abilities: Dictionary = {}
var loadouts: Array[UnitLoadout] = []
var terrain: Array = []
var errors: Array[String] = []
var battlefield_bounds := Rect2(-11, -8, 22, 16)

func _init(path: String = "res://data/scenarios/skirmish.json") -> void:
	var scenario := _read_json(path)
	if not errors.is_empty():
		return
	var definitions_path: String = scenario.get("catalogue", "")
	if definitions_path.is_empty():
		errors.append("Scenario must reference a catalogue.")
		push_error(errors[-1])
		return
	var definitions := _read_json(definitions_path)
	if not errors.is_empty():
		return
	errors = CatalogueValidator.validate(definitions, scenario)
	if not errors.is_empty():
		for message in errors:
			push_error(message)
		return
	var source := definitions.duplicate(true)
	source.merge(scenario)
	if source.has("battlefield"):
		var field: Dictionary = source.battlefield
		battlefield_bounds = Rect2(float(field.origin[0]), float(field.origin[1]), float(field.size[0]), float(field.size[1]))
	for entry in source.weapons:
		var data := WeaponData.new()
		_assign(data, entry)
		weapons[data.id] = data
	for entry in source.manoeuvres:
		var data := ManoeuvreData.new()
		_assign(data, entry)
		manoeuvres[data.id] = data
	for entry in source.abilities:
		var data := AbilityData.new()
		_assign(data, entry)
		abilities[data.id] = data
	for entry in source.pilots:
		var data := PilotData.new()
		_assign(data, entry, ["abilities"])
		data.abilities.assign(entry.get("abilities", []))
		pilots[data.id] = data
	for entry in source.frames:
		var data := FrameData.new()
		_assign(data, entry, ["altitude_access", "manoeuvres", "compatible_manufacturers"])
		data.compatible_manufacturers.assign(entry.get("compatible_manufacturers", []))
		data.altitude_access.assign(entry.altitude_access)
		data.manoeuvres.assign(entry.manoeuvres)
		data.size = SizeClass.RADIUS.get(data.size_class, data.size)
		frames[data.id] = data
	for entry in source.units:
		var data := UnitLoadout.new()
		_assign(data, entry, ["pilot", "frame", "weapons", "start_position"])
		data.pilot = pilots[entry.pilot]
		data.frame = frames[entry.frame]
		data.start_position = Vector2(entry.start_position[0], entry.start_position[1])
		for weapon_id in entry.weapons:
			data.weapons.append(weapons[weapon_id])
		# Every frame with hands can fight with them; they are listed after the loadout's own weapons.
		if not data.frame.default_melee.is_empty() and weapons[data.frame.default_melee] not in data.weapons:
			data.weapons.append(weapons[data.frame.default_melee])
		loadouts.append(data)
	terrain = source.terrain

func _assign(resource: Resource, values: Dictionary, skip: Array = []) -> void:
	for key in values:
		if key not in skip:
			resource.set(key, values[key])

func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("Cannot open data file: %s" % path)
		push_error(errors[-1])
		return {}
	var parser := JSON.new()
	var status := parser.parse(file.get_as_text())
	if status != OK or not parser.data is Dictionary:
		errors.append("Invalid JSON object in %s (line %d): %s" % [path, parser.get_error_line(), parser.get_error_message()])
		push_error(errors[-1])
		return {}
	return parser.data
