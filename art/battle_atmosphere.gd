class_name BattleAtmosphere
extends Node
## Presentation listener only: does not edit the camera or battle state.
const FOG_DENSITY := 0.03
const TRANSITION := 0.5
var camera: TacticalCamera
var environment: Environment
var rain: GPUParticles3D
var rain_material: ShaderMaterial
var amount := 0.0
var goal := -1.0
var sensor := 0.0
var transition: Tween
var forward_plus := false

func setup(view: TacticalCamera, settings: Environment) -> void:
	camera = view
	environment = settings
	forward_plus = RenderingServer.get_current_rendering_method() == "forward_plus"
	environment.fog_light_color = Color("111323")
	environment.fog_sky_affect = 0.0
	environment.fog_sun_scatter = 0.0
	environment.fog_density = 0.0
	if forward_plus: environment.ssr_max_steps = 48
	build_rain()
	camera.mode_changed.connect(func(_mode: TacticalCamera.Mode) -> void: refresh())
	refresh()

func build_rain() -> void:
	rain = GPUParticles3D.new()
	rain.name = "CloseRain"
	rain.emitting = false
	rain.amount = 1500
	rain.lifetime = 1.2
	rain.local_coords = false
	rain.top_level = true
	rain.fixed_fps = 24
	rain.visibility_aabb = AABB(Vector3(-12, -12, -12), Vector3(24, 24, 24))
	var particles := ParticleProcessMaterial.new()
	particles.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(5, 3, 5)
	particles.direction = Vector3(0.12, -1, 0.08)
	particles.spread = 4.0
	particles.initial_velocity_min = 4.0
	particles.initial_velocity_max = 6.0
	particles.gravity = Vector3(0.1, -7.0, 0.1)
	rain.process_material = particles
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.009, 0.22)
	rain_material = ShaderMaterial.new()
	rain_material.shader = preload("res://art/rain.gdshader")
	mesh.material = rain_material
	rain.draw_pass_1 = mesh
	camera.add_child(rain)
	_process(0.0)

func _process(_delta: float) -> void:
	if rain != null and is_instance_valid(camera):
		rain.global_position = camera.global_position - camera.global_basis.z * 5.0 + Vector3.UP * 2.5

func set_sensor_mix(value: float) -> void:
	sensor = value
	refresh()
	apply_amount(amount)

func refresh() -> void:
	var enabled := camera.mode != TacticalCamera.Mode.OVERVIEW and sensor <= 0.5
	environment.ssr_enabled = forward_plus and enabled
	rain.emitting = enabled
	rain.visible = sensor <= 0.5
	var target := 1.0 if enabled else 0.0
	if target == goal: return
	goal = target
	if transition != null: transition.kill()
	transition = create_tween()
	transition.tween_method(apply_amount, amount, target, TRANSITION)

func apply_amount(value: float) -> void:
	amount = value
	var visible_amount := value * (1.0 - sensor) if sensor <= 0.5 else 0.0
	environment.fog_density = FOG_DENSITY * visible_amount
	environment.fog_enabled = visible_amount > 0.0001
	rain_material.set_shader_parameter("visibility", visible_amount)
