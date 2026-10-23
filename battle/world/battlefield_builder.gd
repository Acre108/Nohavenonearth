class_name BattlefieldBuilder
extends RefCounted

static func build(parent: Node3D, bounds: Rect2) -> WorldEnvironment:
	var environment := build_lighting(parent)
	if bounds == Rect2(-18, -13, 36, 26) and ResourceLoader.exists("res://art/dock/StaticDock.tscn"):
		parent.add_child(load("res://art/dock/StaticDock.tscn").instantiate())
		return environment
	build_procedural(parent, bounds)
	return environment

static func build_lighting(parent: Node3D) -> WorldEnvironment:
	var environment := WorldEnvironment.new()
	var settings := OvaRendering.environment()
	environment.environment = settings
	parent.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_color = Color("d8cbe7")
	light.light_energy = 1.25
	light.shadow_enabled = true
	light.shadow_opacity = 1.0
	parent.add_child(light)
	return environment

static func build_procedural(parent: Node3D, bounds: Rect2) -> void:
	var center := bounds.get_center()
	Primitives.box(parent, Vector3(bounds.size.x + 0.6, 0.4, bounds.size.y + 0.6), Vector3(center.x, -0.28, center.y), Color("111e2a"))
	var surface := Primitives.box(parent, Vector3(bounds.size.x, 0.1, bounds.size.y), Vector3(center.x, -0.05, center.y), Color("35414a"))
	var dock := ArtPalette.paint(Color("35414a"), true).duplicate() as ShaderMaterial
	dock.set_shader_parameter("wet_ground", true)
	surface.material_override = dock
	build_dock_lamps(parent, bounds)
	# Muted painted deployment aprons, with no additional collision geometry.
	for side in [-1.0, 1.0]:
		Primitives.box(parent, Vector3(5.2, 0.012, bounds.size.y - 2.0), Vector3(center.x + side * bounds.size.x * 0.317, 0.008, center.y), Color("3e4850")).material_override = ArtPalette.paint(Color("3e4850"), true)
		for z in range(int(bounds.position.y) + 2, int(bounds.end.y), 3):
			Primitives.line(parent, PackedVector3Array([Vector3(center.x + side * bounds.size.x * 0.25, 0.025, z), Vector3(center.x + side * bounds.size.x * 0.375, 0.025, z)]), Color("46515a"), 0.025)
	Primitives.line(parent, PackedVector3Array([Vector3(bounds.position.x, 0.01, bounds.position.y), Vector3(bounds.end.x, 0.01, bounds.position.y), Vector3(bounds.end.x, 0.01, bounds.end.y), Vector3(bounds.position.x, 0.01, bounds.end.y), Vector3(bounds.position.x, 0.01, bounds.position.y)]), Color("77939b"), 0.05)
	# Sparse scale ticks, no square or hex movement grid.
	for x in range(int(bounds.position.x) + 1, int(bounds.end.x)):
		for z in [bounds.position.y + 0.15, bounds.end.y - 0.15]:
			Primitives.line(parent, PackedVector3Array([Vector3(x, 0.02, z), Vector3(x, 0.02, z + signf(center.y - z) * 0.18)]), Color("60737c"), 0.025)
	for x in [bounds.position.x + 3.3, bounds.end.x - 3.3]:
		for z in [bounds.position.y + 2.5, center.y, bounds.end.y - 2.5]:
			Primitives.line(parent, PackedVector3Array([Vector3(x - 0.2, 0.012, z), Vector3(x + 0.2, 0.012, z)]), Color("40565f"), 0.025)
			Primitives.line(parent, PackedVector3Array([Vector3(x, 0.012, z - 0.2), Vector3(x, 0.012, z + 0.2)]), Color("40565f"), 0.025)
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = 1
	parent.add_child(floor_body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(bounds.size.x, 0.1, bounds.size.y)
	collision.shape = shape
	collision.position = Vector3(center.x, -0.05, center.y)
	floor_body.add_child(collision)

static func build_dock_lamps(parent: Node3D, bounds: Rect2) -> void:
	# Decorative fixtures stay outside the playable envelope. Emissive paint and
	# broken albedo streaks suggest wet reflections without extra lights or SSR.
	for side in [-1.0, 1.0]:
		var x: float = bounds.get_center().x + side * (bounds.size.x * 0.5 + 0.22)
		for i in 4:
			var z := bounds.position.y + 2.0 + i * (bounds.size.y - 4.0) / 3.0
			var housing := Primitives.box(parent, Vector3(0.25, 0.32, 0.38), Vector3(x, 0.10, z), Color("303448"))
			housing.material_override = ArtPalette.paint(Color("303448"), true)
			var lamp := Primitives.box(parent, Vector3(0.08, 0.08, 0.22), Vector3(x - side * 0.14, 0.22, z), Color("ffcc8b"))
			var material := ArtPalette.paint(Color("ffcc8b"), true).duplicate() as ShaderMaterial
			material.set_shader_parameter("emission_strength", 3.5)
			lamp.material_override = material
			for segment in 5:
				var streak := Primitives.box(parent, Vector3(0.10, 0.003, 0.28 + segment * 0.07), Vector3(x - side * (0.32 + segment * 0.17), 0.012, z + segment * 0.25), Color("a18a8c"))
				var reflected := ArtPalette.paint(Color("a18a8c"), true).duplicate() as ShaderMaterial
				reflected.set_shader_parameter("emission_strength", 0.22 * (1.0 - segment / 5.0))
				streak.material_override = reflected
