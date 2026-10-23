class_name PilotData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
## Missing stats count as 0. Spirit sets maximum Will.
@export var stats: Dictionary = {}
@export var abilities: Array[String] = []
