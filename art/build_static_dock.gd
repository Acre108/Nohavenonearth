@tool
extends SceneTree
## Run with the editor binary: --headless --path . --script res://art/build_static_dock.gd
func _initialize() -> void:
	run.call_deferred()

func own_nodes(node: Node, scene: Node) -> void:
	for child in node.get_children():
		child.owner = scene
		own_nodes(child, scene)

func run() -> void:
	var dock := Node3D.new()
	dock.name = "StaticDock"
	root.add_child(dock)
	BattlefieldBuilder.build_procedural(dock, Rect2(-18, -13, 36, 26))
	var index := 0
	for node in dock.find_children("*", "MeshInstance3D", true, false):
		node.name = "DockMesh_%03d" % index
		index += 1
		var material: Material = node.material_override
		if material is ShaderMaterial and material.shader == ArtPalette.ENVIRONMENT_SHADER:
			var mesh := ArrayMesh.new()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, node.mesh.surface_get_arrays(0))
			var error := mesh.lightmap_unwrap(node.global_transform, 0.3)
			assert(error == OK, "UV2 unwrap failed")
			node.mesh = mesh
			node.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	# Small baked-only dock lights illuminate the wet perimeter; no runtime cost.
	for side in [-1.0, 1.0]:
		for i in 4:
			var lamp := OmniLight3D.new()
			lamp.position = Vector3(side * 17.7, 0.55, -11 + i * 22.0 / 3.0)
			lamp.light_color = Color("ffcc8b")
			lamp.light_energy = 1.0
			lamp.omni_range = 3.0
			lamp.light_bake_mode = Light3D.BAKE_STATIC
			lamp.editor_only = true
			dock.add_child(lamp)
	var gi := LightmapGI.new()
	gi.name = "DockLightmap"
	gi.quality = LightmapGI.BAKE_QUALITY_MEDIUM
	gi.generate_probes_subdiv = LightmapGI.GENERATE_PROBES_SUBDIV_4
	gi.environment_mode = LightmapGI.ENVIRONMENT_MODE_CUSTOM_COLOR
	gi.environment_custom_color = Color("8c85b3")
	gi.environment_custom_energy = 0.35
	gi.light_data = LightmapGIData.new()
	DirAccess.make_dir_recursive_absolute("res://art/dock")
	assert(ResourceSaver.save(gi.light_data, "res://art/dock/dock.lmbake") == OK)
	gi.light_data.take_over_path("res://art/dock/dock.lmbake")
	dock.add_child(gi)
	own_nodes(dock, dock)
	var scene := PackedScene.new()
	assert(scene.pack(dock) == OK)
	assert(ResourceSaver.save(scene, "res://art/dock/StaticDock.tscn") == OK)
	print("STATIC DOCK: saved with %d meshes" % index)
	quit()
