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
	DirAccess.make_dir_recursive_absolute("res://art/dock")
	own_nodes(dock, dock)
	var scene := PackedScene.new()
	assert(scene.pack(dock) == OK)
	assert(ResourceSaver.save(scene, "res://art/dock/StaticDock.tscn") == OK)
	print("STATIC DOCK: saved with %d meshes" % index)
	quit()
