extends SceneTree

var checks: int = 0
var failures: int = 0
var game: BattleController

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("ART FAIL / " + message)

func frames(count: int = 3) -> void:
	for i in count:
		await process_frame

func capture(name: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/" + name + ".png")

func run() -> void:
	root.size = Vector2i(1920, 1080)
	# Exercise imported assets through the same factory used by the demo.
	for frame_id in UnitModelFactory.MODEL_SCENES:
		var holder := Node3D.new()
		root.add_child(holder)
		UnitModelFactory.build_model(holder, "ground", ArtPalette.FRIEND, frame_id)
		var meshes := holder.find_children("*", "MeshInstance3D", true, false)
		check(meshes.size() > 50, frame_id + " uses the authored rigid-part model")
		var trimmed := 0
		for mesh in meshes:
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.get_active_material(surface) as ShaderMaterial
				if material != null and material.get_shader_parameter("albedo_texture") == ArmourTrims.SHEET:
					trimmed += 1
		check(trimmed > 0, frame_id + " uses UV-mapped armour trims")
		var triangles := 0
		var vertex_colors := true
		var ground := INF
		for mesh_node in meshes:
			var mesh: MeshInstance3D = mesh_node
			for surface in mesh.mesh.get_surface_count():
				var arrays := mesh.mesh.surface_get_arrays(surface)
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
				triangles += indices.size() / 3
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
				vertex_colors = vertex_colors and colors.size() == vertices.size()
				for vertex in vertices:
					ground = minf(ground, (mesh.global_transform * vertex).y)
		var triangle_budget := 20000 if frame_id == "m9_teamster" else 8000
		check(triangles >= 3000 and triangles <= triangle_budget, frame_id + " stays in its authored triangle budget after import")
		check(vertex_colors, frame_id + " preserves baked vertex tones through glTF import")
		check(absf(ground) < 0.002, frame_id + " stands on the ground after coordinate conversion")
		if frame_id == "m9_teamster":
			var regions := holder.find_children("Region_*", "Node3D", true, false)
			check(regions.size() == 8, "Teamster has eight explicit region roots")
			var components := 0
			for region in regions:
				var children := region.get_children().filter(func(n: Node) -> bool: return String(n.name).begins_with("Component_"))
				components += children.size()
				check(children.size() > 0 and children.size() <= 2, String(region.name) + " has at most two component roots")
				var key := String(region.name).trim_prefix("Region_")
				var separate: Node3D = load("res://art/models/teamster_regions/" + key + ".glb").instantiate()
				check(separate.find_children("*", "MeshInstance3D", true, false).size() > 0, key + " has an independent region export")
				separate.free()
			check(components == 14, "Teamster region contract maps all fourteen workshop slots")
		holder.free()
	game = load("res://battle/world/Battlefield.tscn").instantiate()
	root.add_child(game)
	var lightmap := game.find_child("DockLightmap", true, false) as LightmapGI
	check(lightmap != null and lightmap.light_data != null and lightmap.light_data.get_user_count() > 0, "Dock loads a populated baked LightmapGI resource")
	game.manager.paused = true
	await create_timer(0.3).timeout
	var before := JSON.stringify(game.manager.battle.to_dict())
	check(not game.presentation.is_sensor and is_zero_approx(game.presentation.sensor_mix), "Planning defaults to normal battlefield shading")
	await capture("art-battlefield-1080")
	game.presentation.set_sensor_view(true)
	await create_timer(0.3).timeout
	check(game.presentation.is_sensor and is_equal_approx(game.presentation.sensor_mix, 1.0), "Optional Sensor View still works")
	await capture("art-sensor-1080")
	var grey := root.get_texture().get_image()
	grey.convert(Image.FORMAT_L8)
	grey.save_png("res://artifacts/art-greyscale-1080.png")
	# Inspect actual rendered sizing at default and maximum zoom.
	for zoom in [game.camera.default_size, game.camera.maximum_size]:
		game.camera.size = zoom
		await frames()
		for actor in game.actors.values():
			var pixels: float = actor.caption.font_size * actor.caption.pixel_size * 1080.0 / zoom
			check(pixels >= 12.0, "Unit captions stay above 12px at both zoom limits")
	game.camera.reset_view()
	game.presentation.set_sensor_view(false)
	for actor in game.actors.values():
		var tick_count := 0
		for tick in actor.tether_ticks.get_children():
			if tick.is_visible_in_tree():
				tick_count += 1
		check(tick_count == actor.unit.altitude, "Altitude is encoded by tick count")
		check(is_equal_approx(actor.base_marks.rotation.y, actor.model.rotation.y), "Ground chevron agrees with model facing")
	game.presentation.ping()
	await create_timer(0.15).timeout
	await capture("art-ping-1080")
	game.manager.set_phase(TurnManager.Phase.MOVEMENT)
	await create_timer(0.3).timeout
	check(not game.presentation.is_sensor and game.presentation.sensor_mix < 0.01, "Automatic movement uses Cinematic shading")
	await capture("art-cel-1080")
	var presentation_phase := game.manager.phase
	var sensor_key := InputEventKey.new()
	sensor_key.physical_keycode = KEY_F8
	sensor_key.pressed = true
	game.battle_input.handle_input(sensor_key)
	await create_timer(0.3).timeout
	check(game.presentation.is_sensor and game.manager.phase == presentation_phase, "F8 enables Sensor View without advancing the turn")
	game.battle_input.handle_input(sensor_key)
	await create_timer(0.3).timeout
	check(not game.presentation.is_sensor and game.presentation.sensor_mix < 0.01, "F8 returns to normal shading")
	game.presentation.show_sensor_for(0.5)
	await create_timer(0.3).timeout
	check(game.presentation.is_sensor and game.presentation.sensor_mix > 0.99, "Ability effect temporarily enables Sensor View")
	game.manager.set_phase(TurnManager.Phase.PLANNING)
	check(game.presentation.is_sensor, "Ability effect survives phase changes")
	await create_timer(0.5).timeout
	check(not game.presentation.is_sensor and game.presentation.sensor_mix < 0.01, "Ability effect restores normal shading when it expires")
	for phase in [TurnManager.Phase.REVEAL, TurnManager.Phase.MOVEMENT, TurnManager.Phase.ACTION, TurnManager.Phase.ATTACK, TurnManager.Phase.BATTLE_OVER, TurnManager.Phase.PLANNING]:
		game.manager.set_phase(phase)
		check(not game.presentation.is_sensor, "Phase %d keeps normal battlefield shading" % phase)
	check(before == JSON.stringify(game.manager.battle.to_dict()), "Presentation toggles and ping leave battle state unchanged")
	# At default camera, inspect the models as pure black silhouettes.
	for actor in game.actors.values():
		ArtPalette.override_model(actor.model, Primitives.material(Color.BLACK, false, true))
	await capture("art-silhouettes-default-1080")
	game.queue_free()
	await frames()
	var style: Node3D = load("res://art/StyleTest.tscn").instantiate()
	root.add_child(style)
	await capture("art-style-sensor")
	RenderingServer.global_shader_parameter_set("sensor_mix", 0.0)
	await capture("art-style-cel")
	style.set_silhouette(true)
	await capture("art-style-silhouettes")
	style.queue_free()
	await frames()
	print("ART TESTS / %d checks / %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
