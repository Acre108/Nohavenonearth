class_name Primitives
extends RefCounted

static func material(color: Color, transparent: bool = false, unshaded: bool = false) -> Material:
	if not transparent and not unshaded and color.a >= 1.0:
		return ArtPalette.paint(color)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if unshaded else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	if transparent or color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

static func box(parent: Node3D, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = position
	node.material_override = material(color)
	parent.add_child(node)
	return node

static func cylinder(parent: Node3D, radius: float, height: float, position: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 40
	node.mesh = mesh
	node.position = position
	node.material_override = material(color)
	parent.add_child(node)
	return node

static func sphere(parent: Node3D, radius: float, position: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 16
	mesh.rings = 8
	node.mesh = mesh
	node.position = position
	node.material_override = material(color, true, true)
	parent.add_child(node)
	return node

static func line(parent: Node3D, points: PackedVector3Array, color: Color, thickness: float = 0.025) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	# A single triangle mesh gives readable thick lines without per-segment nodes.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]
		var direction := (b - a).normalized()
		var side := direction.cross(Vector3.UP).normalized() * thickness * 0.5
		if side.length_squared() < 0.00001:
			side = Vector3.RIGHT * thickness * 0.5
		for vertex in [a - side, a + side, b + side, a - side, b + side, b - side]:
			surface.add_vertex(vertex)
	var mesh := MeshInstance3D.new()
	mesh.mesh = surface.commit()
	var mat: StandardMaterial3D = material(color, color.a < 1.0, true)
	# Flat ribbons wind either way depending on direction; opaque ones were culled from above.
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat
	root.add_child(mesh)
	return root

static func ring(parent: Node3D, radius: float, color: Color, height: float = 0.05, thickness: float = 0.025) -> Node3D:
	var points := PackedVector3Array()
	for i in range(81):
		var angle := TAU * i / 80.0
		points.append(Vector3(sin(angle) * radius, height, cos(angle) * radius))
	return line(parent, points, color, thickness)

static func label(parent: Node3D, text: String, position: Vector3, color: Color, font_size: int = 28, always_on_top: bool = true) -> Label3D:
	var node := Label3D.new()
	node.set_script(preload("res://art/world_caption.gd"))
	node.text = text
	node.position = position
	node.font_size = maxi(12, font_size)
	node.pixel_size = 0.012
	node.modulate = color
	node.outline_modulate = Color("08101b")
	node.outline_size = 4
	node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.no_depth_test = always_on_top
	parent.add_child(node)
	return node

static func arrow(parent: Node3D, origin: Vector3, facing: float, length: float, color: Color) -> void:
	var forward := Vector3(sin(facing), 0, -cos(facing))
	var right := Vector3(cos(facing), 0, sin(facing))
	var tip := origin + forward * length
	line(parent, PackedVector3Array([origin, tip, tip - forward * 0.25 + right * 0.16, tip, tip - forward * 0.25 - right * 0.16]), color, 0.04)
