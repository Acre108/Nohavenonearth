class_name UnitState
extends RefCounted

const STAT_NAMES: Array[String] = ["gunnery", "melee", "precision", "reflex", "systems", "countermeasures", "spirit"]
## Highest rating a pilot can hold alone. Mech totals are limited only by the frame's thresholds.
const PILOT_CAPS := {"gunnery": 4, "melee": 4, "precision": 5, "reflex": 4, "systems": 4, "countermeasures": 4, "spirit": 6}
## The pilot's own: no hardware adds to them and no frame limits them, only the pilot cap.
const PILOT_ONLY: Array[String] = ["spirit"]
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
## Whole points from the frame and its parts.
var bonus_stats: Dictionary
## Fractions from the frame and its parts, summed; they count once they make a whole point.
var fraction_stats: Dictionary
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
	fraction_stats = definition.frame.stat_fractions.duplicate(true)
	will = will_max()

## Whole points only: the pilot rating plus hardware, capped at the frame's threshold.
func stat(name: String) -> float:
	return resolve_stat(name, float(pilot_stats.get(name, 0)), float(bonus_stats.get(name, 0)), float(fraction_stats.get(name, 0)), loadout.frame)

func stat_max(name: String) -> float:
	return stat_cap(name, loadout.frame)

## Shared with the workshop so its stat table resolves exactly as battle does.
static func resolve_stat(name: String, pilot: float, bonus: float, fractions: float, frame: FrameData) -> float:
	if name in PILOT_ONLY:
		return resolve(pilot, 0.0, 0.0, stat_cap(name, frame))
	return resolve(pilot, bonus, fractions, stat_cap(name, frame))

## Hardware fractions count
## only once they add up to a whole point, for bonuses and penalties alike: +0.75 gives nothing and a
## lone −0.25 costs nothing, but four −0.25 parts cost a point. A frame's +1 is never eaten by a part's −0.25.
static func resolve(pilot: float, bonus: float, fractions: float, cap: float) -> float:
	var whole := toward_zero(bonus)
	var spare := quarter(bonus) - whole + quarter(fractions)
	return clampf(floorf(quarter(pilot)) + whole + toward_zero(spare), 0.0, cap)

## Quarter rounding first stops float error from losing a step.
static func quarter(value: float) -> float:
	return roundf(value * 4.0) / 4.0

static func toward_zero(value: float) -> float:
	var stepped := quarter(value)
	return signf(stepped) * floorf(absf(stepped))

## Thresholds are the only ceiling on a mech's totals; the validator requires every frame to list all of them.
static func stat_cap(name: String, frame: FrameData) -> float:
	if name in PILOT_ONLY:
		return float(PILOT_CAPS[name])
	return float(frame.stat_max.get(name, 0))

## As an int, for stats that count things (Spirit → Will).
func whole_stat(name: String) -> int:
	return floori(stat(name))

func will_max() -> int:
	return whole_stat("spirit")

## Copies the live stats onto a detached projection used for previews and AI scoring.
func copy_stats_to(other: UnitState) -> void:
	other.pilot_stats = pilot_stats.duplicate()
	other.bonus_stats = bonus_stats.duplicate()
	other.fraction_stats = fraction_stats.duplicate()

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
		"pilot_stats": pilot_stats.duplicate(), "bonus_stats": bonus_stats.duplicate(), "fraction_stats": fraction_stats.duplicate(), "locks": locks.duplicate(), "withdrawn": withdrawn, "engaged": engaged.duplicate()}
