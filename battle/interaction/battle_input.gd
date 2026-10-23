class_name BattleInput
extends Node

## Translates viewport input into selection and planning commands.
var controller: BattleController

func handle_input(event: InputEvent) -> void:
	if controller.ui == null:
		return
	# Cinematics take no commands; any key or click skips to the end.
	if controller.camera.mode == TacticalCamera.Mode.CINEMATIC:
		if (event is InputEventKey and event.pressed and not event.echo) or (event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]):
			controller.skip_cinematic()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_T and controller.manager.phase == TurnManager.Phase.PLANNING:
		controller.toggle_threats()
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_F3:
		controller.ui.toggle_debug()
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F8:
		controller.presentation.set_sensor_view(not controller.presentation.sensor_enabled)
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE and controller.manager.phase == TurnManager.Phase.PLANNING:
		controller.cancel_facing()
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_SPACE, KEY_ENTER] and controller.manager.phase == TurnManager.Phase.REVEAL:
		controller.manager.advance()
	if event is InputEventMouseMotion and not controller.camera.panning and not controller.camera.rotating:
		if controller.planning.choosing_facing:
			var point := facing_point(event.position)
			if point != Vector2.INF:
				controller.aim_plan_at(point)
			return
		if controller.manager.phase == TurnManager.Phase.PLANNING and controller.selected != null and controller.selected.loadout.faction == 0 and not controller.planning.destination_fixed and not controller.planning_aircraft() and not planning_charge():
			var point := field_point(event.position)
			if point != Vector2.INF and (controller.planning.hover_last == Vector2.INF or point.distance_to(controller.planning.hover_last) > 0.07):
				controller.planning.hover_last = point
				controller.set_plan_point(point)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if controller.planning.choosing_facing:
			# Clicking another unit means "switch to it", never "confirm this half-aimed order".
			var picked := raycast(event.position, 2)
			if not picked.is_empty():
				var other := controller.manager.battle.unit_by_id(picked.collider.get_meta("unit_id"))
				if other != controller.selected:
					controller.select_unit(other)
					return
			var point := facing_point(event.position)
			if point != Vector2.INF:
				controller.aim_plan_at(point)
				controller.confirm_move()
			return
		var hit := raycast(event.position, 2)
		if not hit.is_empty():
			var unit := controller.manager.battle.unit_by_id(hit.collider.get_meta("unit_id"))
			if controller.blue_attacking() and unit.loadout.faction == 1:
				controller.choose_target(unit)
			elif planning_charge() and unit.loadout.faction == 1:
				controller.planning.choose_charge_target(unit)
			else:
				controller.select_unit(unit)
			return
		# Mechs: click a destination, then aim and click again. Aircraft pick paths from the radial menu instead.
		# Charges aim at enemies, not ground points.
		if controller.manager.phase == TurnManager.Phase.PLANNING and controller.selected != null and controller.selected.alive() and controller.selected.loadout.faction == 0 and not controller.planning_aircraft() and not planning_charge():
			var point := field_point(event.position)
			if point != Vector2.INF:
				controller.set_plan_point(point)
				controller.begin_facing()
				if not controller.planning.choosing_facing:
					# Invalid destination: keep following the mouse; the command panel names the reason.
					controller.planning.destination_fixed = false
					controller.ui.update_preview()

func facing_point(screen_point: Vector2) -> Vector2:
	if controller.planning.draft == null:
		return Vector2.INF
	# Aim on the ghost's visual plane, so airborne previews point directly at the cursor.
	var plane := Plane(Vector3.UP, 0.15 + controller.planning.draft.altitude * 1.7)
	var point: Variant = plane.intersects_ray(controller.camera.project_ray_origin(screen_point), controller.camera.project_ray_normal(screen_point))
	return Vector2(point.x, point.z) if point != null else Vector2.INF

func raycast(screen_point: Vector2, mask: int) -> Dictionary:
	var origin := controller.camera.project_ray_origin(screen_point)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + controller.camera.project_ray_normal(screen_point) * 100, mask)
	query.collide_with_areas = true
	return controller.get_world_3d().direct_space_state.intersect_ray(query)

func field_point(screen_point: Vector2) -> Vector2:
	var hit := raycast(screen_point, 1)
	if hit.is_empty():
		return Vector2.INF
	return Vector2(hit.position.x, hit.position.z)

func planning_charge() -> bool:
	return controller.manager.phase == TurnManager.Phase.PLANNING and controller.selected != null and controller.selected.loadout.faction == 0 and controller.planning.charging()
