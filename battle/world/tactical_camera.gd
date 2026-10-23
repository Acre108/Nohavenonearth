class_name TacticalCamera
extends Camera3D

## One camera, three modes. OVERVIEW is the orthographic table view; CLOSE orbits a unit in perspective;
## CINEMATIC plays scripted attack shots. Each mode keeps its own state, so leaving a mode restores it exactly.
enum Mode { OVERVIEW, CLOSE, CINEMATIC }
signal mode_changed(mode: Mode)
signal cinematic_finished

const CLOSE_FOV := 42.0
const CLOSE_DISTANCE := Vector2(3.5, 14.0)
const CLOSE_PITCH := Vector2(0.2, 0.95)
const BLEND := 0.6
const RETURN_BLEND := 0.5
const MIN_SIZE := 8.0

var mode: Mode = Mode.OVERVIEW
var pivot := Vector3(0, 0, 0)
var azimuth: float = 0.0
var elevation: float = 0.84
var rotating: bool = false
var panning: bool = false
var battlefield_bounds := Rect2(-11, -8, 22, 16)
var default_size: float = 17.5
var maximum_size: float = 30.0
## Optional: world area worth showing (e.g. the living units), and the screen rect the HUD leaves clear.
var focus_provider: Callable
var clear_rect_provider: Callable
## Optional: (screen point or Vector2.INF) -> the Node3D to orbit in close view, or null.
var close_target_provider: Callable

var close_target := Vector3.ZERO
var close_azimuth: float = 0.0
var close_pitch: float = 0.5
var close_distance: float = 7.0
## The close view glides after this node until the player pans away.
var follow: Node3D

var cinematic_steps: Array = []
var cinematic_step: int = -1
var cinematic_time: float = 0.0
var return_mode: Mode = Mode.OVERVIEW
## A focus request that arrived mid-cinematic, applied when the view returns.
var pending_focus: Node3D

var blend_from: CameraShot
var blend_time: float = 0.0
var blend_duration: float = 0.0
var applied: CameraShot

func configure(bounds: Rect2) -> void:
	battlefield_bounds = bounds
	default_size = maxf(17.5, maxf(bounds.size.x * 0.86, bounds.size.y * 1.1))
	maximum_size = default_size * 1.8
	reset_view()

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	reset_view()

## Visible world height at a point: the orthographic size, or the perspective frustum height at that depth.
## Overlays scale line widths and labels by this so they read the same in every view.
static func view_height(camera: Camera3D, point: Vector3) -> float:
	if camera == null:
		return 17.5
	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		return camera.size
	var depth := -(camera.global_transform.affine_inverse() * point).z
	return 2.0 * maxf(0.05, depth) * tan(deg_to_rad(camera.fov) * 0.5)

func reset_view() -> void:
	if mode == Mode.CLOSE:
		set_mode(Mode.OVERVIEW)
	azimuth = 0.0
	if not is_inside_tree() or not focus_provider.is_valid() or not clear_rect_provider.is_valid():
		var center := battlefield_bounds.get_center()
		pivot = Vector3(center.x, 0, center.y)
		size = default_size
		update_camera()
		return
	frame(focus_provider.call(), clear_rect_provider.call(), get_viewport().get_visible_rect().size)
	default_size = size

## Fit a ground rect into a screen rect. Orthographic: x maps 1:1, ground depth is foreshortened by sin(elevation).
func frame(focus: Rect2, clear: Rect2, view: Vector2) -> void:
	var depth_scale := sin(elevation)
	var pixels_per_unit := minf(clear.size.x / maxf(1.0, focus.size.x), clear.size.y / maxf(1.0, focus.size.y * depth_scale))
	size = clampf(view.y / pixels_per_unit, MIN_SIZE, maximum_size)
	pixels_per_unit = view.y / size
	# Shift the pivot so the focus centre lands on the clear rect's centre, not the window's.
	var offset := clear.get_center() - view * 0.5
	var center := focus.get_center()
	pivot = Vector3(center.x - offset.x / pixels_per_unit, 0, center.y - offset.y / (pixels_per_unit * depth_scale))
	update_camera()

## Brief screen-space jolt for impacts; offsets leave pan/orbit state untouched.
func nudge(strength: float) -> void:
	# Offsets are world units: scale the jolt with what is on screen, so close shots don't shake wildly.
	strength *= clampf(view_height(self, applied.target if applied != null else pivot) / 17.5, 0.2, 1.0)
	var jolt := create_tween()
	for i in 4:
		var falloff := strength * (1.0 - i * 0.25)
		jolt.tween_property(self, "h_offset", randf_range(-falloff, falloff), 0.035)
		jolt.parallel().tween_property(self, "v_offset", randf_range(-falloff, falloff), 0.035)
	jolt.tween_property(self, "h_offset", 0.0, 0.05)
	jolt.parallel().tween_property(self, "v_offset", 0.0, 0.05)

## Ease toward a point only if it sits outside the screen rect the HUD leaves clear.
func ensure_visible(point: Vector3, clear_rect: Rect2) -> void:
	if is_position_behind(point) or clear_rect.has_point(unproject_position(point)):
		return
	var glide := create_tween()
	glide.tween_property(self, "pivot", Vector3(point.x, 0, point.z), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

## Bring a unit into view in whichever mode is showing: keep it on screen, orbit it, or after the cinematic.
func focus_on(node: Node3D, clear_rect: Rect2) -> void:
	match mode:
		Mode.OVERVIEW:
			ensure_visible(node.global_position, clear_rect)
		Mode.CLOSE:
			follow = node
		Mode.CINEMATIC:
			pending_focus = node

func enter_close(node: Node3D) -> void:
	if mode == Mode.CINEMATIC:
		return
	follow = node
	close_target = node.global_position + Vector3.UP * 0.8 if node != null else Vector3(pivot.x, 0.6, pivot.z)
	close_azimuth = azimuth
	close_distance = 7.0
	close_pitch = 0.5
	set_mode(Mode.CLOSE)

func toggle_close(screen_point: Vector2 = Vector2.INF) -> void:
	if mode == Mode.CLOSE:
		set_mode(Mode.OVERVIEW)
	elif mode == Mode.OVERVIEW:
		enter_close(close_target_provider.call(screen_point) if close_target_provider.is_valid() else null)

func set_mode(value: Mode, blend: float = BLEND) -> void:
	if value == mode:
		return
	if mode == Mode.CLOSE and value == Mode.OVERVIEW:
		# Land the overview where the close view was looking, so the table doesn't jump.
		var center := applied.target if applied != null else close_target
		pivot = Vector3(center.x, 0, center.z)
		azimuth = close_azimuth
	start_blend(blend)
	mode = value
	mode_changed.emit(mode)
	update_camera()

func start_blend(duration: float) -> void:
	blend_from = applied
	blend_time = 0.0
	blend_duration = duration if applied != null else 0.0

## Steps come from AttackCinematic.plan(). Returns the seconds until the view hands back.
func play_cinematic(steps: Array) -> float:
	if steps.is_empty():
		return 0.0
	if mode != Mode.CINEMATIC:
		return_mode = mode
	cinematic_steps = steps
	cinematic_step = -1
	cinematic_time = 0.0
	rotating = false
	panning = false
	mode = Mode.CINEMATIC
	mode_changed.emit(mode)
	next_step()
	return AttackCinematic.total(steps)

func skip_cinematic() -> void:
	if mode == Mode.CINEMATIC:
		end_cinematic()

func next_step() -> void:
	cinematic_step += 1
	cinematic_time = 0.0
	if cinematic_step >= cinematic_steps.size():
		end_cinematic()
		return
	var step: Dictionary = cinematic_steps[cinematic_step]
	start_blend(float(step.blend))
	update_camera()

func end_cinematic() -> void:
	cinematic_steps = []
	cinematic_step = -1
	set_mode(return_mode, RETURN_BLEND)
	# The overview frames the whole table already; only the close view re-targets.
	if mode == Mode.CLOSE and pending_focus != null and is_instance_valid(pending_focus):
		follow = pending_focus
	pending_focus = null
	cinematic_finished.emit()

## What the active mode wants this frame, before blending.
func live_shot() -> CameraShot:
	match mode:
		Mode.CLOSE:
			return CameraShot.orbit(close_target, close_azimuth, close_pitch, close_distance, CLOSE_FOV)
		Mode.CINEMATIC:
			if cinematic_step >= 0 and cinematic_step < cinematic_steps.size():
				var step: Dictionary = cinematic_steps[cinematic_step]
				var t := clampf(cinematic_time / maxf(0.01, float(step.duration)), 0.0, 1.0)
				return (step.start as CameraShot).blended(step.end, smoothstep(0.0, 1.0, t))
	return CameraShot.ortho(pivot, azimuth, elevation, size)

func update_camera() -> void:
	var shot := live_shot()
	if blend_from != null and blend_time < blend_duration:
		var t := blend_time / blend_duration
		shot = blend_from.blended(shot, t * t * (3.0 - 2.0 * t))
	else:
		blend_from = null
	shot.apply(self)
	applied = shot

func _process(delta: float) -> void:
	# A release over the HUD is consumed before _unhandled_input.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotating = false
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		panning = false
	blend_time += delta
	if mode == Mode.CINEMATIC:
		cinematic_time += delta
		if cinematic_step >= 0 and cinematic_step < cinematic_steps.size() and cinematic_time >= float(cinematic_steps[cinematic_step].duration):
			next_step()
		update_camera()
		return
	if mode == Mode.CLOSE and follow != null and is_instance_valid(follow):
		var goal := follow.global_position + Vector3.UP * 0.8
		close_target = close_target.lerp(goal, 1.0 - exp(-delta * 6.0))
	if get_viewport().gui_get_focus_owner() is SpinBox or get_viewport().gui_get_focus_owner() is LineEdit:
		update_camera()
		return
	var movement := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		movement.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		movement.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		movement.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		movement.x += 1
	var turn := 0.0
	if Input.is_physical_key_pressed(KEY_Q):
		turn -= delta
	if Input.is_physical_key_pressed(KEY_E):
		turn += delta
	if mode == Mode.CLOSE:
		close_azimuth += turn
		if movement != Vector2.ZERO:
			# Panning detaches the view from the unit; selecting a unit reattaches it.
			follow = null
			close_target += ground_axes(close_azimuth) * Vector3(movement.x, 0, movement.y) * delta * close_distance * 0.6
			close_target = clamp_to_table(close_target)
	else:
		azimuth += turn
		var right := Vector3(cos(azimuth), 0, -sin(azimuth))
		var forward := Vector3(sin(azimuth), 0, cos(azimuth))
		pivot += (right * movement.x + forward * movement.y) * delta * size * 0.45
		pivot = clamp_to_table(pivot)
	update_camera()

## Converts (x = right, z = toward camera) into world space for a view azimuth.
func ground_axes(view_azimuth: float) -> Basis:
	return Basis(Vector3(cos(view_azimuth), 0, -sin(view_azimuth)), Vector3.UP, Vector3(sin(view_azimuth), 0, cos(view_azimuth)))

func clamp_to_table(point: Vector3) -> Vector3:
	point.x = clampf(point.x, battlefield_bounds.position.x - 2, battlefield_bounds.end.x + 2)
	point.z = clampf(point.z, battlefield_bounds.position.y - 2, battlefield_bounds.end.y + 2)
	return point

func _unhandled_input(event: InputEvent) -> void:
	if mode == Mode.CINEMATIC:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			panning = event.pressed
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if mode == Mode.CLOSE:
				close_distance = maxf(CLOSE_DISTANCE.x, close_distance * 0.9)
			elif size <= MIN_SIZE:
				# Zooming in past the table view continues into close view on the unit under the cursor.
				toggle_close(event.position)
			else:
				size = maxf(MIN_SIZE, size - 1.0)
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if mode == Mode.CLOSE:
				if close_distance >= CLOSE_DISTANCE.y:
					set_mode(Mode.OVERVIEW)
				else:
					close_distance = minf(CLOSE_DISTANCE.y, close_distance / 0.9)
			else:
				size = minf(maximum_size, size + 1.0)
	if event is InputEventMouseMotion:
		if mode == Mode.CLOSE:
			if rotating:
				close_azimuth -= event.relative.x * 0.007
				close_pitch = clampf(close_pitch + event.relative.y * 0.005, CLOSE_PITCH.x, CLOSE_PITCH.y)
			if panning:
				follow = null
				close_target = clamp_to_table(close_target - ground_axes(close_azimuth) * Vector3(event.relative.x, 0, event.relative.y) * close_distance * 0.0016)
		else:
			if rotating:
				azimuth -= event.relative.x * 0.007
			if panning:
				pivot -= (global_basis.x * event.relative.x - Vector3(sin(azimuth), 0, cos(azimuth)) * event.relative.y) * size * 0.0014
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			reset_view()
		elif event.physical_keycode == KEY_V and not (get_viewport().gui_get_focus_owner() is LineEdit):
			toggle_close()
	update_camera()
