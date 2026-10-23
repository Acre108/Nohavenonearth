extends SceneTree
## GPU checks: actual rendered mask/occlusion, finish ordering, held-pose timing.
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("OVA FAIL / " + message)

func draw_frames() -> void:
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw

func sample(image: Image, camera: Camera3D, at: Vector3) -> Color:
	var pixel := camera.unproject_position(at)
	# Root stretch keeps a logical canvas size even when the output window changes.
	pixel *= Vector2(image.get_size()) / camera.get_viewport().get_visible_rect().size
	return image.get_pixelv(Vector2i(pixel))

func run() -> void:
	root.size = Vector2i(960, 640)
	RenderingServer.global_shader_parameter_set("sensor_mix", 0.0)
	var world := Node3D.new()
	root.add_child(world)
	var environment := WorldEnvironment.new()
	environment.environment = OvaRendering.environment()
	world.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, 0, 0)
	world.add_child(key)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	camera.position = Vector3(0, 0.8, 5)
	camera.look_at(Vector3(0, 0.8, 0))
	camera.current = true
	var rendering := OvaRendering.install(world, camera)
	var mech := Primitives.box(world, Vector3(1, 1, 1), Vector3(-1, 0.7, 0), Color("b9b2a1"))
	mech.material_override = ArtPalette.unit_paint(Color("b9b2a1"), ArtPalette.FRIEND)
	var wall := Primitives.box(world, Vector3(1, 1, 1), Vector3(1, 0.7, 0), Color("686277"))
	wall.material_override = ArtPalette.paint(Color("686277"), true)
	var occluder := Primitives.box(world, Vector3(0.3, 1, 0.2), Vector3(-1.3, 0.7, 0.8), Color("686277"))
	occluder.material_override = wall.material_override
	check(rendering.composite != null, "Forward+ supplies the normal/depth composite")
	if rendering.composite == null:
		quit(1)
		return
	rendering.finish_layer.visible = false
	rendering.composite.set_shader_parameter("show_mask", true)
	await draw_frames()
	var mask := root.get_texture().get_image()
	mask.save_png("res://artifacts/ova-mask.png")
	check(sample(mask, camera, Vector3(-0.8, 0.7, 0.5)).r > 0.9, "Visible mech writes the white mask")
	check(sample(mask, camera, Vector3(1, 0.7, 0.5)).r < 0.01, "Environment stays outside the mech mask")
	check(sample(mask, camera, Vector3(-1.3, 0.7, 0.9)).r < 0.01, "Foreground terrain occludes the mech mask")
	rendering.composite.set_shader_parameter("show_mask", false)
	await draw_frames()
	var lit := sample(root.get_texture().get_image(), camera, Vector3(-0.8, 0.7, 0.5))
	key.visible = false
	await draw_frames()
	var shadow := sample(root.get_texture().get_image(), camera, Vector3(-0.8, 0.7, 0.5))
	check(lit.get_luminance() > shadow.get_luminance() + 0.08, "Scene lighting changes the mech's cel band")
	check(shadow.b > 0.05 and shadow.get_luminance() > 0.1, "Unlit mech retains a visible coloured shadow fill")
	key.visible = true
	# An emissive 3D card blooms; CanvasLayer HUD remains outside the film finish.
	var hud := CanvasLayer.new()
	hud.layer = 1
	world.add_child(hud)
	var patch := ColorRect.new()
	patch.position = Vector2(24, 24)
	patch.size = Vector2(48, 48)
	patch.color = Color(0.2, 0.8, 0.5)
	hud.add_child(patch)
	await draw_frames()
	var clean := root.get_texture().get_image()
	rendering.finish_layer.visible = true
	await draw_frames()
	var finished := root.get_texture().get_image()
	check(clean.get_pixel(40, 40).is_equal_approx(finished.get_pixel(40, 40)), "Film finish leaves HUD pixels unchanged")
	check(not clean.get_pixel(15, 320).is_equal_approx(finished.get_pixel(15, 320)), "Film finish reaches the world background")
	rendering.set_laserdisc(true)
	check(is_equal_approx(root.scaling_3d_scale, 0.75), "LaserDisc mode scales only the 3D render")
	await draw_frames()
	check(root.get_texture().get_image().get_pixel(40, 40).is_equal_approx(clean.get_pixel(40, 40)), "HUD remains native resolution in LaserDisc mode")
	rendering.set_laserdisc(false)
	var model := Node3D.new()
	world.add_child(model)
	UnitModelFactory.build_model(model, "ground", ArtPalette.FRIEND, "m9_teamster")
	var animator := TeamsterAnimator.new()
	model.add_child(animator)
	animator.setup(model)
	animator.flashes_enabled = false
	animator.set_process(false)
	animator.play("walk", 0)
	var knee := model.find_child("Joint_left_knee_drive", true, false) as Node3D
	var start := knee.transform
	animator._process(1.0 / 24.0)
	check(start.is_equal_approx(knee.transform), "Pose holds between 12 Hz cel frames")
	animator._process(1.0 / 24.0)
	check(not start.is_equal_approx(knee.transform), "Pose changes on the next cel frame")
	check(is_equal_approx(animator.player.current_animation_position, 1.0 / 12.0), "Animation retains the correct wall-clock duration")
	animator.set_paused(true)
	var position := animator.player.current_animation_position
	animator._process(0.5)
	check(is_equal_approx(position, animator.player.current_animation_position), "Pause holds the cel pose")
	animator.set_paused(false)
	animator._process(1.0 / 12.0)
	check(animator.player.current_animation_position > position, "Resume advances the held animation")
	animator.play("walk", 0.0, 2.0)
	var speed_start := animator.player.current_animation_position
	animator._process(1.0 / 12.0)
	animator.set_paused(true)
	animator.set_paused(false)
	animator._process(1.0 / 12.0)
	check(is_equal_approx(animator.player.current_animation_position - speed_start, 1.0 / 3.0), "Pause/resume preserves custom clip speed")
	# Save a readable close view in addition to the mask diagnostic.
	animator.rest(true)
	hud.queue_free()
	mech.queue_free()
	wall.queue_free()
	occluder.queue_free()
	root.size = Vector2i(1440, 900)
	camera.position = Vector3(1.6, 1.4, -2.8)
	camera.look_at(Vector3(0, 0.65, 0))
	camera.size = 2.1
	key.rotation_degrees = Vector3(-35, 150, 0)
	var floor_mesh := Primitives.box(world, Vector3(12, 0.08, 12), Vector3(0, -0.05, 0), Color("454454"))
	var floor_material := ArtPalette.paint(Color("454454"), true).duplicate() as ShaderMaterial
	floor_material.set_shader_parameter("wet_ground", true)
	floor_mesh.material_override = floor_material
	await draw_frames()
	root.get_texture().get_image().save_png("res://artifacts/ova-mech-closeup.png")
	world.queue_free()
	await process_frame
	print("OVA: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
