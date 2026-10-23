extends SceneTree
var failures := 0
func _initialize() -> void: run.call_deferred()
func capture() -> Image:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func run() -> void:
	root.size = Vector2i(1440, 900)
	CinematicSettings.loaded = true
	var game: BattleController = load("res://battle/world/Battlefield.tscn").instantiate()
	root.add_child(game)
	game.manager.paused = true
	game.ui.visible = false
	for actor in game.actors.values():
		if actor.animation != null: actor.animation.rest(true)
		actor.selection.visible = false
		actor.active_ring.visible = false
	var rendering := game.find_child("OvaRendering", true, false) as OvaRendering
	rendering.finish.set_shader_parameter("grain_strength", 0.0)
	var wet: Array[ShaderMaterial] = []
	for mesh in game.find_children("*", "MeshInstance3D", true, false):
		var material := mesh.material_override as ShaderMaterial
		if material != null and material.shader == ArtPalette.ENVIRONMENT_SHADER and material.get_shader_parameter("wet_ground"):
			wet.append(material)
	if wet.is_empty():
		push_error("WET FAIL / no wet dock material found")
		quit(1)
		return
	for angle in [0.0, 1.1, 2.2, 3.3]:
		game.camera.azimuth = angle
		game.camera.update_camera()
		for material in wet: material.set_shader_parameter("wet_ground", true)
		var a := await capture()
		a.save_png("res://artifacts/wet-check-%.1f.png" % angle)
		for material in wet: material.set_shader_parameter("wet_ground", false)
		var b := await capture()
		b.save_png("res://artifacts/dry-check-%.1f.png" % angle)
		var bright := 0
		for y in a.get_height():
			for x in a.get_width():
				if a.get_pixel(x,y).get_luminance() - b.get_pixel(x,y).get_luminance() > 0.35: bright += 1
		var ratio := float(bright) / (a.get_width() * a.get_height())
		print("WET azimuth=%.1f bright_fraction=%.6f" % [angle, ratio])
		if ratio >= 0.001:
			failures += 1
			push_error("WET FAIL / angle %.1f produces a ground flare" % angle)
	print("WET LIGHTING / 4 checks / %d failures" % failures)
	quit(1 if failures else 0)
