class_name UnitState
extends RefCounted

const STAT_NAMES: Array[String] = ["gunnery", "melee", "precision", "reflex", "guard", "systems", "countermeasures", "spirit"]
## Absolute ceilings on pilot + frame + parts; each frame's stat_max can set a lower one.
const STAT_CAPS := {"gunnery": 4, "melee": 4, "precision": 5, "reflex": 4, "guard": 4, "systems": 4, "countermeasures": 4, "spirit": 6}
## Stored and shown, but no rule uses them yet.
const RESERVED_STATS: Array[String] = ["systems", "countermeasures"]
const ALTITUDES: Array[String] = ["GROUND", "LOW", "HIGH"]
const RANGE_ALTITUDE_SPACING: float = 1.5
const LOCK_CAPACITY: int = 1
var loadout: UnitLoadout
var position: Vector2
var facing: float = 0.0
var altitude: int = 0
var structure: int = 0
var energy: float = 0.0
var will: int = 0
var pilot_stats: Dictionary
## Frame bonuses now; workshop parts add to the same dictionary.
var bonus_stats: Dictionary
var locks: Array[String] = []
var order: MovementOrder
var action_used: bool = false
var attacked: bool = false
var ability_rotation: float = 0.0
var ability_paid: bool = false
var withdrawn: bool = false
## IDs of enemies locked in melee with this unit. Engaged units cannot move or attack anyone else.
var engaged: Array[String] = []
## Set when this round's charge connected: melee against that unit gets the charge bonus.
var charge_target: String = ""

func _init(definition: UnitLoadout = null) -> void:
	if definition == null:
		return
	loadout = definition
	position = definition.start_position
	facing = deg_to_rad(definition.start_facing)
	altitude = definition.start_altitude
	structure = definition.frame.structure
	if definition.starting_structure >= 0:
		structure = mini(structure, definition.starting_structure)
	energy = definition.frame.energy_available()
	pilot_stats = definition.pilot.stats.duplicate(true)
	bonus_stats = definition.frame.stat_bonuses.duplicate(true)
	will = will_max()

## Pilot + bonuses, kept to quarter points so fractional parts never lose a step to float error,
## then capped at the frame's maximum for that stat.
func stat(name: String) -> float:
	return quarter_capped(float(pilot_stats.get(name, 0)) + float(bonus_stats.get(name, 0)), stat_max(name))

func stat_max(name: String) -> float:
	return stat_cap(name, loadout.frame)

## Shared with the workshop so its stat table resolves exactly as battle does.
static func quarter_capped(total: float, cap: float) -> float:
	return clampf(roundf(total * 4.0) / 4.0, 0.0, cap)

static func stat_cap(name: String, frame: FrameData) -> float:
	return minf(STAT_CAPS[name], float(frame.stat_max.get(name, STAT_CAPS[name])))

## Whole points only, for stats that count things (Spirit → Will).
func whole_stat(name: String) -> int:
	return floori(stat(name))

func will_max() -> int:
	return whole_stat("spirit")

## Copies the live stats onto a detached projection used for previews and AI scoring.
func copy_stats_to(other: UnitState) -> void:
	other.pilot_stats = pilot_stats.duplicate()
	other.bonus_stats = bonus_stats.duplicate()

func alive() -> bool:
	return structure > 0

func forward() -> Vector2:
	return Vector2(sin(facing), -cos(facing))

func world_position() -> Vector3:
	return Vector3(position.x, 0.08 + altitude * 1.7, position.y)

func range_position() -> Vector3:
	return Vector3(position.x, altitude * RANGE_ALTITUDE_SPACING, position.y)

func to_dict() -> Dictionary:
	return {"loadout": loadout.id, "position": [position.x, position.y], "facing": facing,
		"altitude": altitude, "structure": structure, "energy": energy, "will": will,
		"pilot_stats": pilot_stats.duplicate(), "bonus_stats": bonus_stats.duplicate(), "locks": locks.duplicate(), "withdrawn": withdrawn, "engaged": engaged.duplicate()}
