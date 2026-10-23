class_name CameraShot
extends RefCounted

## One camera framing, described so orthographic and perspective views interpolate smoothly.
## height is the visible world height at the target; fov 0 means orthographic.
## A perspective fov narrows toward ORTHO_FOV at the orthographic end of a blend, so the
## projection switch happens where the two views are almost indistinguishable.
const ORTHO_FOV := 1.0
const ORTHO_DISTANCE := 26.0

var target := Vector3.ZERO
var azimuth: float = 0.0
var elevation: float = 0.84
var height: float = 17.5
var fov: float = 0.0

static func ortho(at: Vector3, view_azimuth: float, view_elevation: float, size: float) -> CameraShot:
	var shot := CameraShot.new()
	shot.target = at
	shot.azimuth = view_azimuth
	shot.elevation = view_elevation
	shot.height = size
	return shot

static func orbit(at: Vector3, view_azimuth: float, view_elevation: float, distance: float, degrees: float) -> CameraShot:
	var shot := CameraShot.new()
	shot.target = at
	shot.azimuth = view_azimuth
	shot.elevation = view_elevation
	shot.fov = degrees
	shot.height = 2.0 * distance * tan(deg_to_rad(degrees) * 0.5)
	return shot

static func looking(eye: Vector3, at: Vector3, degrees: float) -> CameraShot:
	var offset := eye - at
	var distance := maxf(0.1, offset.length())
	return orbit(at, atan2(offset.x, offset.z), asin(clampf(offset.y / distance, -1.0, 1.0)), distance, degrees)

func direction() -> Vector3:
	return Vector3(sin(azimuth) * cos(elevation), sin(elevation), cos(azimuth) * cos(elevation))

func distance() -> float:
	return ORTHO_DISTANCE if fov <= 0.0 else height / (2.0 * tan(deg_to_rad(fov) * 0.5))

func eye() -> Vector3:
	return target + direction() * distance()

## Dolly zoom between any two shots: the subject's framing changes smoothly while the lens widens or narrows.
func blended(to: CameraShot, t: float) -> CameraShot:
	if t <= 0.0:
		return self
	if t >= 1.0:
		return to
	var shot := CameraShot.new()
	shot.target = target.lerp(to.target, t)
	shot.azimuth = lerp_angle(azimuth, to.azimuth, t)
	shot.elevation = lerpf(elevation, to.elevation, t)
	shot.height = exp(lerpf(log(height), log(to.height), t))
	# Square-root easing leaves the near-orthographic end quickly, where the eye is very far away.
	var from_fov := ORTHO_FOV if fov <= 0.0 else fov
	var to_fov := ORTHO_FOV if to.fov <= 0.0 else to.fov
	var lens := sqrt(t) if fov <= 0.0 else (1.0 - sqrt(1.0 - t) if to.fov <= 0.0 else t)
	shot.fov = lerpf(from_fov, to_fov, lens)
	return shot

func apply(camera: Camera3D) -> void:
	var view_distance := distance()
	if fov <= 0.0:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = height
		camera.near = 0.05
		camera.far = 4000.0
	else:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		camera.fov = fov
		# A narrow lens sits far away; keep the depth range tight around the table for precision.
		camera.near = maxf(0.05, view_distance - 80.0)
		camera.far = view_distance + 160.0
	camera.position = target + direction() * view_distance
	camera.look_at(target, Vector3.UP)
