class_name CinematicSettings
extends RefCounted

## Which attacks play a camera cinematic. Presentation only; saved per player, separate from workshop saves.
const PATH := "user://battle_settings.cfg"
static var loaded: bool = false
static var blue_attacks: bool = true
static var red_attacks: bool = true

static func ensure_loaded() -> void:
	if loaded:
		return
	loaded = true
	var file := ConfigFile.new()
	if file.load(PATH) == OK:
		blue_attacks = bool(file.get_value("cinematics", "blue_attacks", true))
		red_attacks = bool(file.get_value("cinematics", "red_attacks", true))

static func plays_for(faction: int) -> bool:
	ensure_loaded()
	return blue_attacks if faction == 0 else red_attacks

static func set_for(faction: int, enabled: bool) -> void:
	ensure_loaded()
	if faction == 0:
		blue_attacks = enabled
	else:
		red_attacks = enabled
	var file := ConfigFile.new()
	file.set_value("cinematics", "blue_attacks", blue_attacks)
	file.set_value("cinematics", "red_attacks", red_attacks)
	file.save(PATH)
