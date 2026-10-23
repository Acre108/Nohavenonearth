class_name ArmourTrims
extends RefCounted
## Deterministic planar UV authoring for the rigid armour kit. Cached per source mesh.
const SHEET := preload("res://art/armour_trim.svg")
static var meshes: Dictionary = {}

static func apply(instance: MeshInstance3D) -> void:
	var source := instance.mesh
	if source == null or not source is ArrayMesh: return
	if meshes.has(source):
		instance.mesh = meshes[source]
		return
	var result := ArrayMesh.new()
	var changed := false
	var bounds := source.get_aabb()
	for surface in source.get_surface_count():
		var material := source.surface_get_material(surface) as StandardMaterial3D
		var armour := material != null and "armour" in material.resource_name.to_lower() and bounds.size.length() > 0.12
		var arrays := source.surface_get_arrays(surface)
		if armour:
			var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var uv := PackedVector2Array()
			for i in positions.size():
				var point := (positions[i] - bounds.position) / bounds.size.max(Vector3.ONE * 0.0001)
				var n := normals[i].abs()
				var projected := Vector2(point.x, point.y)
				if n.x > maxf(n.y, n.z): projected = Vector2(point.z, point.y)
				elif n.y > n.z: projected = Vector2(point.x, point.z)
				# First panel tile, inset half a texel to keep adjacent trims out.
				uv.append(Vector2((8.5 + projected.x * 239.0) / 1024.0, (4.5 + projected.y * 55.0) / 256.0))
			arrays[Mesh.ARRAY_TEX_UV] = uv
			material = material.duplicate()
			material.albedo_texture = SHEET
			changed = true
		result.add_surface_from_arrays(source.surface_get_primitive_type(surface), arrays)
		result.surface_set_material(surface, material if material != null else source.surface_get_material(surface))
	meshes[source] = result if changed else source
	instance.mesh = meshes[source]
	meshes[instance.mesh] = instance.mesh
