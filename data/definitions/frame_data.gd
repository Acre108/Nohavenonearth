class_name FrameData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var movement_type: String = "ground"
## Lore: generation (1, 2, 3) and production tier (mass, line, elite, vehicle) set its points target.
@export var generation: int = 2
@export var tier: String = "line"
@export var tonnage: float = 0.0
## Whole-point additions to pilot stats from this frame's hardware; workshop parts add here too.
@export var stat_bonuses: Dictionary = {}
## The fractional parts of hardware bonuses, summed. They count only once they add up to a whole point.
@export var stat_fractions: Dictionary = {}
## Per-stat ceiling on pilot + hardware for this frame. The validator requires all eight stats.
@export var stat_max: Dictionary = {}
@export var size_class: String = "medium"
@export var manufacturer: String = ""
## Empty means only this frame's manufacturer; adapters/licences can explicitly widen it.
@export var compatible_manufacturers: Array[String] = []
@export var structure: int = 6
@export var armour: int = 0
## Armour counts 2 higher against weapons of this damage type; "none" never matches.
@export var armour_type: String = "none"
@export var base_move: float = 3.0
@export var energy_capacity: int = 3
## Installed hardware reserves part of the rated capacity, in quarter-Energy steps.
@export var energy_reserved: float = 0.0
@export var energy_recharge: int = 1
## Base radius, set from size_class when the catalogue loads.
@export var size: float = 0.32
@export var altitude_access: Array[int] = [0]
@export var manoeuvres: Array[String] = []
## Weapon id every unit on this frame carries in addition to its loadout, such as its hands.
@export var default_melee: String = ""

func model_scale() -> float:
	return SizeClass.MODEL_SCALE.get(size_class, 1.0)

## Adds one piece of hardware's stat change: its whole points count at once, its fraction joins the
## running total of fractions.
func add_stat(stat: String, value: float) -> void:
	var whole := UnitState.toward_zero(value)
	stat_bonuses[stat] = float(stat_bonuses.get(stat, 0.0)) + whole
	stat_fractions[stat] = float(stat_fractions.get(stat, 0.0)) + value - whole

func energy_available() -> float:
	return maxf(0.0, float(energy_capacity) - energy_reserved)
