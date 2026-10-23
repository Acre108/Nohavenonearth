class_name MovementPreview
extends Node3D

func show_order(unit: UnitState, order: MovementOrder, draft: bool = false) -> void:
	var color := ArtPalette.faction(unit.loadout.faction)
	if draft:
		color = ArtPalette.DRAFT if order.valid else ArtPalette.INVALID
	var path := PackedVector3Array()
	for point in order.path:
		path.append(Vector3(point.x, 0.15 + order.altitude * 1.7, point.y))
	if path.size() >= 2:
		Primitives.line(self, path, Color(color, 0.6), 0.07 if draft else 0.045)
	var endpoint := Vector3(order.destination.x, 0.15 + order.altitude * 1.7, order.destination.y)
	# Aircraft drafts are paths only: the line and end chevron say where it goes without a ghost model.
	if not (draft and unit.loadout.frame.movement_type == "aircraft"):
		var ghost := Node3D.new()
		add_child(ghost)
		ghost.position = endpoint
		ghost.rotation.y = -order.facing
		var ghost_model := Node3D.new()
		ghost.add_child(ghost_model)
		ghost_model.scale = Vector3.ONE * unit.loadout.frame.model_scale()
		UnitModelFactory.build_model(ghost_model, unit.loadout.frame.movement_type, Color(color, 0.25), unit.loadout.frame.id)
		ArtPalette.override_model(ghost_model, Primitives.material(Color(color, 0.2), true, true))
		Primitives.ring(ghost, unit.loadout.frame.size + 0.15, Color(color, 0.75))
	Primitives.arrow(self, endpoint, order.facing, 1.0, color)
	if not order.valid:
		Primitives.label(self, "× INVALID", endpoint + Vector3.UP, color, 24)

## An unselected aircraft flight path: a faint line and end chevron, stronger while hovered in the radial menu.
func show_option(_unit: UnitState, order: MovementOrder, hovered: bool) -> void:
	var color := ArtPalette.DRAFT if order.valid else ArtPalette.INVALID
	var path := PackedVector3Array()
	for point in order.path:
		path.append(Vector3(point.x, 0.15 + order.altitude * 1.7, point.y))
	if path.size() >= 2:
		Primitives.line(self, path, Color(color, 0.7 if hovered else 0.35), 0.055 if hovered else 0.03)
	var endpoint := Vector3(order.destination.x, 0.15 + order.altitude * 1.7, order.destination.y)
	Primitives.arrow(self, endpoint, order.facing, 0.6 if hovered else 0.4, Color(color, 0.95 if hovered else 0.5))

func show_facing_guide(unit: UnitState, order: MovementOrder, turn_degrees: float) -> void:
	var origin := Vector3(order.destination.x, 0.2 + order.altitude * 1.7, order.destination.y)
	var points := PackedVector3Array()
	for i in range(49):
		var angle := unit.facing + deg_to_rad(-turn_degrees + turn_degrees * 2 * i / 48.0)
		points.append(origin + Vector3(sin(angle), 0, -cos(angle)) * 1.5)
	Primitives.line(self, points, Color("f0c27c"), 0.05)
	Primitives.arrow(self, origin, order.facing, 1.5, Color("f0c27c"))
	# Below the ghost (toward the camera), clear of the unit's own caption above it.
	var caption := Primitives.label(self, "CLICK TO LOCK", origin + Vector3(0, -0.1, 1.1), Color("f0c27c"), 18)
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		caption.pixel_size *= maxf(1.0, TacticalCamera.view_height(camera, caption.global_position) / 17.5)
