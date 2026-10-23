class_name OvaRendering
extends Node
## Shared battle/workshop/style-test presentation. No battle-state dependencies.
## The normal-buffer mask uses constant roughness 0.02 on units, >=0.18 elsewhere.
const FINISH := preload("res://art/ova_finish.gdshader")
static var grade_texture: ImageTexture
var composite: ShaderMaterial
var finish: ShaderMaterial
var finish_layer: CanvasLayer
var viewport: Viewport
var laserdisc: bool = false

static func environment(night: bool = true) -> Environment:
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("111323") if night else Color("191c29")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("8c85b3")
	settings.ambient_light_energy = 0.65
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	if RenderingServer.get_current_rendering_method() == "forward_plus":
		settings.glow_enabled = true
		settings.glow_intensity = 0.65
		settings.glow_bloom = 0.0
		settings.glow_hdr_threshold = 1.3
		settings.glow_hdr_scale = 1.5
		settings.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
		# Fake lamp streaks are the default. SSR can be enabled for a closer camera.
		settings.ssr_enabled = bool(ProjectSettings.get_setting("rendering/ova/ssr", false))
	return settings

static func install(parent: Node, camera: Camera3D) -> OvaRendering:
	var rendering := OvaRendering.new()
	rendering.name = "OvaRendering"
	parent.add_child(rendering)
	rendering.setup(camera)
	return rendering

func setup(camera: Camera3D) -> void:
	viewport = camera.get_viewport()
	if RenderingServer.get_current_rendering_method() == "forward_plus":
		var quad := MeshInstance3D.new()
		quad.name = "CelBackgroundComposite"
		quad.mesh = QuadMesh.new()
		quad.mesh.size = Vector2(2, 2)
		quad.extra_cull_margin = 16384.0
		quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		camera.add_child(quad)
		composite = ShaderMaterial.new()
		# Load only on Forward+: Compatibility has no normal/roughness buffer.
		composite.shader = load("res://art/cel_composite.gdshader")
		composite.render_priority = -100
		quad.material_override = composite
	finish_layer = CanvasLayer.new()
	finish_layer.name = "OvaFilmFinish"
	# The game's CanvasLayer HUD uses layer 1; the finish only sees the 3D world.
	finish_layer.layer = -10
	add_child(finish_layer)
	var screen := ColorRect.new()
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(screen)
	finish = ShaderMaterial.new()
	finish.shader = FINISH
	finish.set_shader_parameter("grade_lut", make_grade())
	screen.material = finish
	set_laserdisc(bool(ProjectSettings.get_setting("rendering/ova/laserdisc", false)))

func set_laserdisc(enabled: bool) -> void:
	laserdisc = enabled
	if viewport != null:
		# This scales only 3D. CanvasLayer HUD and workshop controls retain native pixels.
		viewport.scaling_3d_scale = 0.75 if enabled else 1.0

static func make_grade() -> ImageTexture:
	if grade_texture != null: return grade_texture
	var image := Image.create(256, 16, false, Image.FORMAT_RGB8)
	for b in 16:
		for g in 16:
			for r in 16:
				var color := Color(r / 15.0, g / 15.0, b / 15.0)
				var value := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
				color = color.lerp(Color(value, value, value), 0.13)
				var shadows := pow(1.0 - value, 2.0)
				color.r = clampf(color.r + shadows * 0.018, 0.0, 1.0)
				color.g = clampf(color.g * 0.975, 0.0, 1.0)
				color.b = clampf(color.b + shadows * 0.035, 0.0, 1.0)
				image.set_pixel(b * 16 + r, g, color)
	grade_texture = ImageTexture.create_from_image(image)
	return grade_texture
