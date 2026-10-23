class_name ArtPalette
extends RefCounted

## Saturated hues are reserved for information: friendly, hostile, draft, invalid.
const FRIEND := Color("63d8ed")
const HOSTILE := Color("f48478")
const DRAFT := Color("f0c27c")
const INVALID := Color("ff5cd6")
const MARK := Color("edf2e4")
const ARC := Color("bac7cd")
const INK := Color("263342")
const PAINT_SHADER := preload("res://art/paint.gdshader")
const ENVIRONMENT_SHADER := preload("res://art/environment.gdshader")
const OUTLINE_SHADER := preload("res://art/outline.gdshader")
static var paint_materials: Dictionary = {}

static func paint(color: Color, terrain: bool = false) -> ShaderMaterial:
	# Keep the small paint palette alive across same-frame preview rebuilds.
	# Shared materials also avoid hundreds of identical shaders per GLB instance.
	var key := color.to_html() + ("/terrain" if terrain else "/unit")
	if paint_materials.has(key):
		return paint_materials[key]
	var material := ShaderMaterial.new()
	material.shader = ENVIRONMENT_SHADER if terrain else PAINT_SHADER
	material.set_shader_parameter("paint", color)
	paint_materials[key] = material
	return material

static func faction(faction_id: int) -> Color:
	return FRIEND if faction_id == 0 else HOSTILE

static func unit_paint(color: Color, faction_color: Color, texture: Texture2D = null, emission: float = 0.0, trim_rect: Vector4 = Vector4(0,0,1,1)) -> ShaderMaterial:
	var key := color.to_html() + "/outline/" + faction_color.to_html() + "/%s/%.2f/%s" % [texture.get_instance_id() if texture != null else 0, emission, trim_rect]
	if paint_materials.has(key):
		return paint_materials[key]
	var material := ShaderMaterial.new()
	material.shader = PAINT_SHADER
	material.set_shader_parameter("paint", color)
	material.set_shader_parameter("sensor_unit", true)
	material.set_shader_parameter("use_albedo_texture", texture != null)
	if texture != null: material.set_shader_parameter("albedo_texture", texture)
	material.set_shader_parameter("emission_strength", emission)
	material.set_shader_parameter("trim_rect", trim_rect)
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	outline.set_shader_parameter("faction", faction_color)
	outline.set_shader_parameter("ink", color.darkened(0.75).lerp(INK, 0.5))
	if not (trim_rect.y > 0.25 and trim_rect.y < 0.5): material.next_pass = outline
	paint_materials[key] = material
	return material

static func paint_model(root: Node, faction_color: Color = FRIEND) -> void:
	if root is MeshInstance3D:
		ArmourTrims.apply(root, faction_color)
		for surface in root.mesh.get_surface_count():
			var original: Material = root.get_active_material(surface)
			if original is StandardMaterial3D:
				var glow := 2.4 if original.emission_enabled or "sensor" in original.resource_name.to_lower() else 0.0
				root.set_surface_override_material(surface, unit_paint(original.albedo_color, faction_color, original.albedo_texture, glow, original.get_meta("trim_rect", Vector4(0,0,1,1))))
			elif original is ShaderMaterial and original.shader == PAINT_SHADER:
				var emission: Variant = original.get_shader_parameter("emission_strength")
				var trim: Variant = original.get_shader_parameter("trim_rect")
				root.material_override = unit_paint(original.get_shader_parameter("paint"), faction_color,
					original.get_shader_parameter("albedo_texture"), float(emission) if emission != null else 0.0, trim if trim != null else Vector4(0,0,1,1))
	for child in root.get_children():
		paint_model(child, faction_color)

static func override_model(root: Node, material: Material) -> void:
	if root is MeshInstance3D:
		root.material_override = material
	for child in root.get_children():
		override_model(child, material)
