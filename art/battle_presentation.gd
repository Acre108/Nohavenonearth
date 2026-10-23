class_name BattlePresentation
extends Node

## Only reads turn state. Never advances, pauses, or edits the battle.
var controller: BattleController
var sensor_enabled: bool = false
var sensor_mix: float = 0.0
var is_sensor: bool = false
var blend: Tween
var sensor_goal: float = 0.0
var sensor_until: int = 0
var atmosphere: BattleAtmosphere

func setup(game: BattleController) -> void:
	controller = game
	RenderingServer.global_shader_parameter_set("sensor_mix", sensor_mix)
	atmosphere = BattleAtmosphere.new()
	add_child(atmosphere)
	atmosphere.setup(controller.camera, controller.world_environment.environment)

func set_sensor_view(value: bool) -> void:
	sensor_enabled = value
	refresh()

## Temporary visual effect for abilities; overlapping effects extend the reveal.
func show_sensor_for(seconds: float) -> void:
	if seconds <= 0.0:
		return
	sensor_until = maxi(sensor_until, Time.get_ticks_msec() + int(seconds * 1000.0))
	refresh()

func _process(_delta: float) -> void:
	if sensor_until > 0 and Time.get_ticks_msec() >= sensor_until:
		sensor_until = 0
		refresh()

func refresh() -> void:
	is_sensor = sensor_enabled or Time.get_ticks_msec() < sensor_until
	var goal := 1.0 if is_sensor else 0.0
	# State refreshes during battle must not restart an in-progress transition.
	if goal != sensor_goal:
		sensor_goal = goal
		if blend != null:
			blend.kill()
		blend = create_tween()
		blend.tween_method(set_mix, sensor_mix, goal, 0.22)
	if controller.ui != null:
		controller.ui.refresh_view()

func set_mix(value: float) -> void:
	sensor_mix = value
	RenderingServer.global_shader_parameter_set("sensor_mix", value)
	atmosphere.set_sensor_mix(value)

func ping() -> void:
	for unit in controller.manager.battle.living(0):
		var pulse := Primitives.ring(controller.fx_root, 1.0, Color(ArtPalette.MARK, 0.22), 0.18, 0.04)
		pulse.position = Vector3(unit.position.x, 0, unit.position.y)
		var material: StandardMaterial3D = pulse.get_child(0).material_override
		var reveal := create_tween().set_parallel(true)
		reveal.tween_property(pulse, "scale", Vector3(42, 1, 42), 0.75).set_trans(Tween.TRANS_QUAD)
		reveal.tween_property(material, "albedo_color:a", 0.0, 0.75)
		reveal.chain().tween_callback(pulse.queue_free)
