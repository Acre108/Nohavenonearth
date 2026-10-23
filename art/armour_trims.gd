class_name ArmourTrims
extends RefCounted
## Deterministic planar UV authoring for the rigid armour kit. Cached per source mesh.
const SHEET := preload("res://art/armour_trim.svg")
static var meshes: Dictionary = {}
static var authored: Dictionary = {}
const TRIM_TILE_SIZE := 0.5
const PANEL_RECT := Vector4(8.5 / 1024.0, 4.5 / 256.0, 239.0 / 1024.0, 55.0 / 256.0)
const HAZARD_RECT := Vector4(0.5 / 1024.0, 132.5 / 256.0, 63.0 / 1024.0, 55.0 / 256.0)

static func apply(instance: MeshInstance3D, faction: Color = ArtPalette.FRIEND) -> void:
	var source := instance.mesh
	if source == null or not source is ArrayMesh: return
	if authored.has(source): return
	var model_scale := instance.global_basis.get_scale().abs()
	var hazard := faction.r > faction.b and (String(instance.name).begins_with("L_Pauldron") or String(instance.name).begins_with("R_Knee_plate") or String(instance.name).begins_with("R_Round_kneecap"))
	var cache_key := "%s/%s/%s/%s" % [source.get_instance_id(), model_scale, instance.name, hazard]
	if meshes.has(cache_key):
		instance.mesh = meshes[cache_key]
		return
	var result := ArrayMesh.new()
	var changed := false
	var bounds := source.get_aabb()
	# Cambered aircraft shells need one continuous projection across smooth normals.
	var details: Dictionary = instance.get_meta("extras", {})
	var top_projection: bool = details.get("trim_projection", "") == "top"
	var phase := Vector2(posmod(String(instance.name).hash(), 97) / 97.0, posmod(String(instance.name).hash() >> 8, 89) / 89.0)
	for surface in source.get_surface_count():
		var material := source.surface_get_material(surface) as StandardMaterial3D
		var armour := material != null and "armour" in material.resource_name.to_lower() and bounds.size.length() > 0.12
		var arrays := source.surface_get_arrays(surface)
		if armour:
			var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var uv := PackedVector2Array()
			for i in positions.size():
				var point := positions[i] * model_scale / TRIM_TILE_SIZE
				var n := normals[i].abs()
				var projected := Vector2(point.x, point.y)
				if top_projection: projected = Vector2(point.x, point.z)
				elif n.x > maxf(n.y, n.z): projected = Vector2(point.z, point.y)
				elif n.y > n.z: projected = Vector2(point.x, point.z)
				uv.append(projected + phase)
			arrays[Mesh.ARRAY_TEX_UV] = uv
			material = material.duplicate()
			material.albedo_texture = SHEET
			material.set_meta("trim_rect", HAZARD_RECT if hazard else PANEL_RECT)
			changed = true
		result.add_surface_from_arrays(source.surface_get_primitive_type(surface), arrays)
		result.surface_set_material(surface, material if material != null else source.surface_get_material(surface))
	meshes[cache_key] = result if changed else source
	instance.mesh = meshes[cache_key]
	authored[instance.mesh] = true

static func add_stencils(root: Node3D, faction: Color) -> void:
	var marks := root.find_children("Tactical_number_*", "MeshInstance3D", true, false)
	if marks.is_empty(): return
	marks.sort_custom(func(a: Node, b: Node) -> bool: return String(a.name).naturalnocasecmp_to(String(b.name)) < 0)
	var mark := marks[0] as MeshInstance3D
	if mark.has_node("TrimStencil"): return
	var stencil := MeshInstance3D.new()
	stencil.name = "TrimStencil"
	var quad := QuadMesh.new()
	quad.size = Vector2(0.11, 0.038 if faction.b > faction.r else 0.058)
	var arrays := quad.surface_get_arrays(0)
	var colors := PackedColorArray()
	colors.resize((arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size())
	colors.fill(Color.WHITE)
	arrays[Mesh.ARRAY_COLOR] = colors
	var stencil_mesh := ArrayMesh.new()
	stencil_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	stencil.mesh = stencil_mesh
	var bounds := mark.mesh.get_aabb()
	var thin := bounds.size.min_axis_index()
	var wide := bounds.size.max_axis_index()
	var toward := mark.global_basis.inverse() * root.global_basis * Vector3.FORWARD
	var normal := Vector3.ZERO
	normal[thin] = -1.0 if toward[thin] < 0.0 else 1.0
	var right := Vector3.ZERO
	right[wide] = 1.0
	stencil.basis = Basis(right, normal.cross(right).normalized(), normal)
	stencil.position = bounds.get_center() + right * (bounds.size[wide] * 0.5 + 0.07) + normal * (bounds.size[thin] * 0.5 + 0.006)
	var rect := Vector4(26.5 / 1024.0, 68.5 / 256.0, 131.0 / 1024.0, 48.0 / 256.0) if faction.b > faction.r else Vector4(286.5 / 1024.0, 68.5 / 256.0, 91.0 / 1024.0, 48.0 / 256.0)
	stencil.material_override = ArtPalette.unit_paint(Color("e4dcc0") if faction.b > faction.r else ArtPalette.INK, faction, SHEET, 0.0, rect)
	mark.add_child(stencil)
