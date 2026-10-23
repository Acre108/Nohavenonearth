@tool
extends EditorPlugin
var started := false
func _enter_tree() -> void:
	if FileAccess.file_exists("res://artifacts/bake-dock.request"): run.call_deferred()

func run() -> void:
	DirAccess.remove_absolute("res://artifacts/bake-dock.request")
	await get_tree().create_timer(3).timeout
	EditorInterface.open_scene_from_path("res://art/dock/StaticDock.tscn")
	await get_tree().create_timer(2).timeout
	var scene := EditorInterface.get_edited_scene_root()
	scene.get_node("DockLightmap").light_data.take_over_path("res://art/dock/dock.lmbake")
	EditorInterface.save_scene()
	EditorInterface.edit_node(scene.get_node("DockLightmap"))
	await get_tree().create_timer(1).timeout
	var pending: Array[Node] = [EditorInterface.get_base_control()]
	while not pending.is_empty():
		var node := pending.pop_back() as Node
		if node is Button and "Bake Lightmaps" in node.text:
			print("DOCK BAKE: activating editor bake")
			node.pressed.emit()
			await get_tree().create_timer(5).timeout
			EditorInterface.save_scene()
			print("DOCK BAKE: scene saved")
			get_tree().quit()
			return
		pending.append_array(node.get_children())
	push_error("DOCK BAKE: editor bake control not found")
	get_tree().quit(1)
