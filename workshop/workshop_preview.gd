class_name WorkshopPreview
extends SubViewportContainer

signal region_selected(id: String)

const FRAME_CENTRE := Vector3(0, 0.62, 0)
const DEFAULT_ZOOM := 1.9
const ZOOM_STEP := 0.1
const ZOOM_RANGE := Vector2(1.45, 2.6)
const ROTATE_SPEED := 0.009
## A press and release closer than this many pixels counts as a click, not a drag.
const CLICK_SLOP := 6.0
const DECK_LINE := Color("34464b")

var world: SubViewport
var rig: Node3D
var model: Node3D
var camera: Camera3D
var angle: float = -0.3
var zoom: float = DEFAULT_ZOOM
var press_position := Vector2.ZERO
var inspection_mode: String = "assembled"
var selected_region: String = ""
var inspection_target := FRAME_CENTRE
var inspection_size: float = 1.0
var animator: TeamsterAnimator
var preview_clip: String = "rest"
var highlight_selection: bool = true
var frame_id: String = "m9_teamster"

func _ready() -> void:
	stretch = true
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	tooltip_text = "Drag to rotate · Scroll to zoom"
	world = SubViewport.new()
	world.own_world_3d = true
	world.size = Vector2i(620, 610)
	world.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(world)
	var scene := Node3D.new()
	world.add_child(scene)
	var environment := WorldEnvironment.new()
	environment.environment = OvaRendering.environment(false)
	scene.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_color = Color("f1ddcd")
	light.light_energy = 1.4
	light.shadow_enabled = true
	scene.add_child(light)
	build_deck(scene)
	rig = Node3D.new()
	scene.add_child(rig)
	camera = Camera3D.new()
	scene.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.position = Vector3(0, 1.42, -2.8)
	camera.look_at(FRAME_CENTRE)
	camera.current = true
	OvaRendering.install(scene, camera)
	update_camera()

## Service deck: a turntable with a floor grid and a brass ring.
func build_deck(scene: Node3D) -> void:
	var deck := Primitives.cylinder(scene, 0.86, 0.055, Vector3(0,-0.035,0), Color("26373b"))
	deck.material_override = Primitives.material(Color("233237"), false, true)
	for i in range(-8, 9):
		var offset := float(i) * 0.16
		deck_line(scene, Vector3(0.003,0.002,1.8), Vector3(offset,-0.005,0))
		deck_line(scene, Vector3(1.8,0.002,0.003), Vector3(0,-0.005,offset))
	Primitives.ring(scene, 0.77, Color("b49b66"), 0.0, 0.009)

func deck_line(scene: Node3D, extent: Vector3, at: Vector3) -> void:
	var strip := Primitives.box(scene, extent, at, DECK_LINE)
	strip.material_override = Primitives.material(DECK_LINE, false, true)

func show_fit(finish: Dictionary, region: String, recovery: bool, components: Dictionary = {}, part_finishes: Dictionary = {}) -> void:
	selected_region = region
	if model != null:
		rig.remove_child(model)
		model.queue_free()
	model = Node3D.new()
	rig.add_child(model)
	UnitModelFactory.build_model(model, "ground", ArtPalette.FRIEND, frame_id)
	var visible_fit := components.duplicate()
	if recovery and not visible_fit.has("backpack.module"): visible_fit["backpack.module"] = "module_recovery"
	if frame_id == "m9_teamster": TeamsterParts.apply(model, visible_fit)
	WorkshopAppearance.apply(model, finish, region if highlight_selection else "", recovery, part_finishes)
	animator = null
	if frame_id == "m9_teamster":
		animator = TeamsterAnimator.new()
		model.add_child(animator)
		animator.two_handed = TeamsterParts.two_handed(components)
		animator.setup(model, false)
		if preview_clip == "rest": animator.rest()
		else: animator.play(preview_clip, 0)
	elif frame_id == "hx7_kestrel":
		animator = KestrelAnimator.new()
		model.add_child(animator)
		animator.setup(model, false)
		if preview_clip == "rest": animator.rest()
		else: animator.play(preview_clip, 0)
	rebuild_picking()
	set_inspection(inspection_mode)

## One click box per visible mesh, grouped in an Area3D per region.
func rebuild_picking() -> void:
	for region in model.find_children("Region_*", "Node3D", true, false):
		var area := Area3D.new()
		area.set_meta("region", String(region.name).trim_prefix("Region_"))
		for mesh in visible_meshes(region):
			var bounds := mesh_bounds(mesh, region)
			var shape := CollisionShape3D.new()
			shape.shape = BoxShape3D.new()
			shape.shape.size = bounds.size.max(Vector3.ONE * 0.005)
			shape.position = bounds.get_center()
			area.add_child(shape)
		region.add_child(area)

func visible_meshes(root: Node) -> Array:
	return root.find_children("*", "MeshInstance3D", true, false).filter(func(mesh: MeshInstance3D) -> bool: return mesh.is_visible_in_tree())

## A mesh's bounding box in the local coordinates of `space`.
func mesh_bounds(mesh: MeshInstance3D, space: Node3D) -> AABB:
	var transform := space.global_transform.affine_inverse() * mesh.global_transform
	var box := mesh.get_aabb()
	var bounds := AABB(transform * box.get_endpoint(0), Vector3.ZERO)
	for corner in range(1, 8):
		bounds = bounds.expand(transform * box.get_endpoint(corner))
	return bounds

func set_inspection(mode: String) -> void:
	inspection_mode = mode
	if mode != "assembled" and animator != null:
		preview_clip = "rest"
		animator.rest(true)
	if model != null:
		WorkshopAppearance.inspect_regions(model, mode, selected_region)
	inspection_target = FRAME_CENTRE
	inspection_size = 1.0
	if mode == "isolated" and model != null:
		frame_selected_region()
	update_camera()

## Centres and sizes the isolated view on the selected region's visible meshes.
func frame_selected_region() -> void:
	var region := model.find_child("Region_" + selected_region, true, false)
	if region == null: return
	var meshes := visible_meshes(region)
	if meshes.is_empty(): return
	var bounds := mesh_bounds(meshes[0], rig)
	for mesh in meshes.slice(1):
		bounds = bounds.merge(mesh_bounds(mesh, rig))
	inspection_target = bounds.get_center()
	inspection_size = maxf(0.45, bounds.size.length() * 1.2)

func play_preview(clip: String) -> void:
	if animator == null: return
	preview_clip = clip
	if clip == "rest":
		animator.rest()
	else:
		set_inspection("assembled")
		animator.play(clip, 0.08)

func update_camera() -> void:
	rig.rotation.y = angle
	var target := rig.transform * inspection_target if inspection_mode == "isolated" else inspection_target
	camera.position = target + Vector3(0,0.8,-2.8)
	camera.look_at(target)
	match inspection_mode:
		"isolated": camera.size = inspection_size * zoom / DEFAULT_ZOOM
		"exploded": camera.size = zoom + 0.45
		_: camera.size = zoom

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		angle += event.relative.x * ROTATE_SPEED
		update_camera()
		accept_event()
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.pressed and click.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var step := -ZOOM_STEP if click.button_index == MOUSE_BUTTON_WHEEL_UP else ZOOM_STEP
			zoom = clampf(zoom + step, ZOOM_RANGE.x, ZOOM_RANGE.y)
			update_camera()
			accept_event()
		elif click.button_index == MOUSE_BUTTON_LEFT:
			if click.pressed:
				press_position = click.position
			elif click.position.distance_to(press_position) < CLICK_SLOP:
				pick_region(click.position)
				accept_event()

## Emits region_selected for the region under the cursor, if any.
func pick_region(screen_position: Vector2) -> void:
	var origin := camera.project_ray_origin(screen_position)
	var ray := PhysicsRayQueryParameters3D.create(origin, origin + camera.project_ray_normal(screen_position) * 20)
	ray.collide_with_areas = true
	ray.collide_with_bodies = false
	var hit := rig.get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty():
		region_selected.emit(hit.collider.get_meta("region"))
