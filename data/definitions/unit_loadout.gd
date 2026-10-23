class_name UnitLoadout
extends Resource

@export var id: String = ""
@export var callsign: String = ""
@export var faction: int = 0
@export var pilot: PilotData
@export var frame: FrameData
@export var weapons: Array[WeaponData] = []
@export var start_position: Vector2
@export var start_facing: float = 0.0
@export var start_altitude: int = 0
## Workshop deployments use detached definitions; standalone scenarios keep full hull.
@export var starting_structure: int = -1
@export var workshop_finish: String = ""
@export var workshop_parts: Dictionary = {}
@export var workshop_part_finishes: Dictionary = {}
