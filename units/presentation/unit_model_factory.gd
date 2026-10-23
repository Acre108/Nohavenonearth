class_name UnitModelFactory
extends RefCounted

const MODEL_SCENES := {
	"hx7_kestrel": preload("res://art/models/hx7_kestrel.glb"),
	"m9_teamster": preload("res://art/models/m9_teamster.glb"),
	"ob12_medved": preload("res://art/models/ob12_medved.glb"),
	"type09_tieshan": preload("res://art/models/type09_tieshan.glb"),
}

static func build_model(parent: Node3D, kind: String, color: Color, frame_id: String = "") -> void:
	if MODEL_SCENES.has(frame_id):
		var frame_model: Node3D = MODEL_SCENES[frame_id].instantiate()
		parent.add_child(frame_model)
		ArtPalette.paint_model(frame_model, color)
		ArmourTrims.add_stencils(frame_model, color)
		return
	# Paint never uses the saturated information palette. Shape carries frame identity.
	var friendly := color.b > color.r
	var armour := Color("bec7c7") if friendly else Color("b3aaa0")
	var secondary := Color("687b8a") if friendly else Color("857a74")
	var dark := ArtPalette.INK
	var mark := Color("e0e2d5")
	if kind == "aircraft":
		# Long nose, swept wings and twin rear fins read from above and in silhouette.
		Primitives.box(parent, Vector3(0.22, 0.19, 1.2), Vector3(0, 0.30, -0.05), armour)
		var nose := Primitives.box(parent, Vector3(0.13, 0.12, 0.45), Vector3(0, 0.30, -0.76), armour)
		nose.rotation.x = -0.12
		for side in [-1.0, 1.0]:
			var wing := Primitives.box(parent, Vector3(0.72, 0.07, 0.43), Vector3(side * 0.4, 0.29, 0.13), secondary)
			wing.rotation.y = side * -0.43
			var fin := Primitives.box(parent, Vector3(0.06, 0.35, 0.32), Vector3(side * 0.18, 0.48, 0.43), armour)
			fin.rotation.z = side * -0.3
			Primitives.box(parent, Vector3(0.12, 0.12, 0.24), Vector3(side * 0.18, 0.26, 0.59), dark)
			Primitives.box(parent, Vector3(0.08, 0.02, 0.27), Vector3(side * 0.61, 0.34, 0.2), mark)
		Primitives.box(parent, Vector3(0.15, 0.13, 0.32), Vector3(0, 0.43, -0.35), dark)
	elif frame_id == "type99_tank":
		# Low hull between two track runs, a flat turret and a long gun: reads as a tank, not a mech.
		for side in [-1.0, 1.0]:
			Primitives.box(parent, Vector3(0.16, 0.16, 0.86), Vector3(side * 0.24, 0.08, 0), dark)
			Primitives.box(parent, Vector3(0.17, 0.03, 0.7), Vector3(side * 0.24, 0.175, 0), secondary)
		Primitives.box(parent, Vector3(0.34, 0.14, 0.8), Vector3(0, 0.17, 0), armour)
		Primitives.cylinder(parent, 0.17, 0.1, Vector3(0, 0.29, 0.06), armour)
		Primitives.box(parent, Vector3(0.05, 0.05, 0.5), Vector3(0, 0.3, -0.3), dark)
		Primitives.box(parent, Vector3(0.1, 0.025, 0.2), Vector3(0, 0.345, 0.12), mark)
	else:
		var heavy := frame_id == "ob12_medved"
		var flying := kind == "flying"
		var stance := 0.26 if heavy else 0.19
		for side in [-1.0, 1.0]:
			Primitives.box(parent, Vector3(0.23, 0.4, 0.25), Vector3(side * stance, 0.32, 0), dark)
			Primitives.box(parent, Vector3(0.24, 0.25, 0.17), Vector3(side * stance, 0.29, -0.13), armour)
			Primitives.box(parent, Vector3(0.27, 0.13, 0.44), Vector3(side * stance, 0.09, -0.13), armour)
			Primitives.box(parent, Vector3(0.3 if heavy else 0.25, 0.22, 0.37), Vector3(side * (0.48 if heavy else 0.39), 0.86, 0), armour)
		Primitives.box(parent, Vector3(0.76 if heavy else 0.53, 0.42, 0.38), Vector3(0, 0.69, 0), armour)
		Primitives.box(parent, Vector3(0.28, 0.17, 0.04), Vector3(0, 0.78, -0.21), secondary)
		Primitives.box(parent, Vector3(0.22, 0.23, 0.25), Vector3(0, 1.02, -0.04), armour)
		Primitives.box(parent, Vector3(0.17, 0.055, 0.025), Vector3(0, 1.05, -0.18), dark)
		Primitives.box(parent, Vector3(0.17, 0.2, 0.86 if heavy else 0.65), Vector3(0.43, 0.62, -0.35), dark)
		Primitives.box(parent, Vector3(0.25, 0.47, 0.18), Vector3(-0.44, 0.63, -0.10), secondary)
		# A flat shoulder stripe, rather than roughness/noise weathering.
		Primitives.box(parent, Vector3(0.12, 0.025, 0.29), Vector3(-0.39, 0.982, 0), mark)
		if heavy:
			Primitives.box(parent, Vector3(0.2, 0.2, 0.96), Vector3(-0.39, 1.03, -0.22), dark)
		elif flying:
			for side in [-1.0, 1.0]:
				var fin := Primitives.box(parent, Vector3(0.17, 0.76, 0.17), Vector3(side * 0.39, 0.88, 0.29), secondary)
				fin.rotation.z = side * 0.32
		else:
			Primitives.box(parent, Vector3(0.04, 0.32, 0.04), Vector3(0.16, 1.13, 0.04), dark)
	ArtPalette.paint_model(parent, color)

static func build_wreck(parent: Node3D, kind: String, color: Color, size: float) -> void:
	var hull := color.darkened(0.6)
	var dark := Color("1f2a33")
	# Overlapping rotated slabs read as an irregular scorch mark rather than a base disc.
	for patch in [[Vector2(0.9, 0.55), Vector2(0, 0), 0.4], [Vector2(0.6, 0.45), Vector2(0.25, -0.2), -0.7], [Vector2(0.5, 0.35), Vector2(-0.3, 0.2), 1.2]]:
		var scorch := Primitives.box(parent, Vector3(patch[0].x * (size + 0.3) * 1.6, 0.015, patch[0].y * (size + 0.3) * 1.6), Vector3(patch[1].x, 0.008, patch[1].y), Color("1b252c"))
		scorch.rotation.y = patch[2]
	if kind == "aircraft":
		var fuselage := Primitives.box(parent, Vector3(0.18, 0.09, 0.62), Vector3(0.05, 0.05, 0.05), hull)
		fuselage.rotation = Vector3(0, 0.35, 0.25)
		var wing := Primitives.box(parent, Vector3(0.5, 0.03, 0.26), Vector3(-0.3, 0.03, 0.2), hull)
		wing.rotation.y = -0.5
		var fin := Primitives.box(parent, Vector3(0.05, 0.2, 0.22), Vector3(0.32, 0.06, -0.28), dark)
		fin.rotation = Vector3(0.2, 0.9, 1.3)
		return
	var torso := Primitives.box(parent, Vector3(0.6 if kind == "ground" else 0.46, 0.3, 0.38), Vector3(0, 0.18, 0), hull)
	torso.rotation = Vector3(0.15, 0.3, 0.55)
	Primitives.box(parent, Vector3(0.2, 0.18, 0.2), Vector3(0.38, 0.09, 0.3), Color("4b555d"))
	var leg := Primitives.box(parent, Vector3(0.18, 0.16, 0.6), Vector3(-0.32, 0.08, -0.12), dark)
	leg.rotation.y = 0.7
	var arm := Primitives.box(parent, Vector3(0.16, 0.14, 0.5), Vector3(0.12, 0.07, -0.4), hull)
	arm.rotation.y = -1.1
	Primitives.label(parent, "+1 COVER", Vector3(0, 0.95, 0), Color("9ba8ad"), 12, false)
