class_name ManoeuvreData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var kind: String = "vector"
@export var minimum_move: float = 1.0
## Fixed distance; 0 means the frame's move plus the pilot's Reflex bonus.
@export var distance: float = 0.0
@export var move_modifier: float = 0.0
@export var turn_degrees: float = 45.0
@export var energy_cost: int = 0
