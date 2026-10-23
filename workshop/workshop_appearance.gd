class_name WorkshopAppearance
extends RefCounted

## How far each region moves out from its mount in exploded inspection.
const EXPLODED_OFFSETS := {"head":Vector3(0,0.18,0), "torso":Vector3.ZERO,
	"left_arm":Vector3(-0.27,0,0), "right_arm":Vector3(0.27,0,0),
	"left_leg":Vector3(-0.12,-0.12,0), "right_leg":Vector3(0.12,-0.12,0),
	"power":Vector3(0,0.03,0.30), "backpack":Vector3(0,0.12,0.65)}
## Node-name prefixes on the base model that belong to each limb region.
const LIMB_PREFIXES := {"l_arm":"left_arm", "r_arm":"right_arm", "l_leg":"left_leg", "r_leg":"right_leg"}
## Factory paint colours on the model, and the finish channel that replaces each.
const PAINT_CHANNELS := {"656a4a":"primary", "3e4939":"secondary", "c2bda4":"marking"}
## Surfaces with no readable colour are treated as factory primary.
const FACTORY_PRIMARY := Color("656a4a")
const HIGHLIGHT := Color("f2bc73")
static var finishes: Array = []

static func region_for(node: Node) -> String:
	var cursor := node
	while cursor != null:
		var key := String(cursor.name).to_lower()
		if key.begins_with("region_"):
			return key.trim_prefix("region_")
		if key.begins_with("head"):
			return "head"
		for prefix in LIMB_PREFIXES:
			if key.begins_with(prefix):
				return LIMB_PREFIXES[prefix]
		if "ht12" in key or "powerpack" in key:
			return "power"
		if "hornet" in key or "louvre" in key or "exhaust" in key or "recovery" in key:
			return "backpack"
		cursor = cursor.get_parent()
	return "torso"

static func inspect_regions(root: Node3D, mode: String, selected: String) -> void:
	for region in root.find_children("Region_*", "Node3D", true, false):
		var key := String(region.name).trim_prefix("Region_")
		if not region.has_meta("rest_position"):
			region.set_meta("rest_position", region.position)
		var offset: Vector3 = EXPLODED_OFFSETS.get(key, Vector3.ZERO) if mode == "exploded" else Vector3.ZERO
		region.position = region.get_meta("rest_position") + offset
		region.visible = mode != "isolated" or key == selected
		for area in region.find_children("*", "Area3D", true, false):
			area.collision_layer = 1 if region.visible else 0

## Repaints the model with a finish, recursively. Components named in part_finishes use their own finish.
static func apply(root: Node, finish: Dictionary, selected: String = "", recovery: bool = false, part_finishes: Dictionary = {}) -> void:
	if part_finishes.has(String(root.name)):
		finish = part_finishes[String(root.name)]
	if "Hornet_12_cell_pod" in String(root.name):
		root.visible = not recovery
	if root is MeshInstance3D:
		for index in root.mesh.get_surface_count():
			var colour := repainted(surface_colour(root, index), finish)
			if not selected.is_empty() and region_for(root) == selected:
				colour = colour.lerp(HIGHLIGHT, 0.36)
			var current := root.get_active_material(index) as ShaderMaterial
			var texture: Texture2D = current.get_shader_parameter("albedo_texture") if current != null else null
			var emission := float(current.get_shader_parameter("emission_strength")) if current != null else 0.0
			var trim: Vector4 = current.get_shader_parameter("trim_rect") if current != null else Vector4(0,0,1,1)
			root.set_surface_override_material(index, ArtPalette.unit_paint(colour, ArtPalette.FRIEND, texture, emission, trim))
	for child in root.get_children():
		apply(child, finish, selected, recovery, part_finishes)

static func surface_colour(mesh: MeshInstance3D, index: int) -> Color:
	var material: Material = mesh.get_active_material(index)
	if material is ShaderMaterial:
		return material.get_shader_parameter("paint")
	if material is StandardMaterial3D:
		return material.albedo_color
	return FACTORY_PRIMARY

## Swaps a factory paint colour for the finish's matching channel; other colours pass through.
static func repainted(colour: Color, finish: Dictionary) -> Color:
	for factory in PAINT_CHANNELS:
		if colour.is_equal_approx(Color(factory)):
			return Color(finish[PAINT_CHANNELS[factory]])
	return colour

static func finish_by_id(id: String) -> Dictionary:
	if finishes.is_empty():
		var content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(WorkshopState.CONTENT))
		finishes = content.finishes
	for finish in finishes:
		if finish.id == id:
			return finish
	return finishes[0]
