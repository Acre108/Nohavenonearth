class_name TerrainActor
extends Node3D

func setup(data: Dictionary) -> void:
	position = Vector3(data.position[0], 0, data.position[1])
	var height := float(data.height)
	var size := Vector3(float(data.half_size[0]) * 2, height, float(data.half_size[1]) * 2)
	var color := Color("58616a") if data.blocks_los else Color("68665e")
	paint_box(size, Vector3(0, height * 0.5, 0), color)
	paint_box(Vector3(size.x, 0.06, size.z), Vector3(0, height - 0.03, 0), Color("798080"))
	# All architectural detail stays within the authoritative terrain envelope.
	if height > 1.5:
		for level in range(1, int(height / 0.55)):
			paint_box(Vector3(size.x + 0.012, 0.045, size.z + 0.012), Vector3(0, level * 0.5, 0), Color("3c4854"))
		for side in [-1.0, 1.0]:
			paint_box(Vector3(0.10, height - 0.1, 0.08), Vector3(side * (size.x * 0.5 - 0.06), height * 0.5, -size.z * 0.5 - 0.006), Color("858784"))
		paint_box(Vector3(size.x * 0.58, 0.022, size.z * 0.55), Vector3(0, height + 0.004, 0), Color("434f59"))
		for i in 4:
			paint_box(Vector3(size.x * 0.42, 0.024, 0.045), Vector3(0, height + 0.017, (i - 1.5) * size.z * 0.1), Color("717977"))
	else:
		# Broad flat chips, with no metallic or roughness texture.
		for i in 3:
			paint_box(Vector3(size.x * 0.16, 0.014, size.z * 0.6), Vector3(size.x * (i - 1) * 0.26, height + 0.003, 0), Color("85857a"))
	# A footprint remains visible even when model details are hidden by the camera.
	var x := size.x * 0.5
	var z := size.z * 0.5
	Primitives.line(self, PackedVector3Array([Vector3(-x, 0.035, -z), Vector3(x, 0.035, -z), Vector3(x, 0.035, z), Vector3(-x, 0.035, z), Vector3(-x, 0.035, -z)]), Color("67747c"), 0.025)
	# Players only need the cover value here; sight blocking shows as gaps in the firing-arc preview.
	if int(data.get("cover", 0)) > 0:
		Primitives.label(self, "+%d COVER" % int(data.cover), Vector3(0, height + 0.5, 0), Color("9ba8ad"), 12, false)

func paint_box(size: Vector3, point: Vector3, color: Color) -> void:
	Primitives.box(self, size, point, color).material_override = ArtPalette.paint(color, true)
