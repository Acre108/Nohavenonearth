class_name WeaponData
extends Resource

const DAMAGE_TYPES: Array[String] = ["ballistic", "energy", "explosive"]

@export var id: String = ""
@export var display_name: String = ""
## One roll per shot; every hit deals damage minus the target's effective Armour.
@export var shots: int = 1
@export var damage: int = 1
## Subtracted from the target's Armour, never below 0.
@export var armour_piercing: int = 0
## Added to hit chance; rare, for precision weapons.
@export var aim_bonus: float = 0.0
@export var damage_type: String = "ballistic"
## Size class; a frame can only carry weapons of its own size or smaller.
@export var size: String = "medium"
## Heavy weapons turn a near miss into a glancing hit.
@export var heavy: bool = false
## Melee uses Melee and Guard, and measures range from base edge to base edge.
@export var melee: bool = false
@export var range_min: float = 0.0
@export var range_max: float = 4.0
@export var arc: float = 90.0
@export var energy_cost: int = 0
