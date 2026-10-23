extends Label3D

## Keep labels at their authored pixel size through zoom, resize, and the perspective close view.
func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		pixel_size = TacticalCamera.view_height(camera, global_position) / maxf(1.0, get_viewport().get_visible_rect().size.y)
