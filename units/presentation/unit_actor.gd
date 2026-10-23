class_name UnitActor
extends Node3D


var unit: UnitState
var body: Node3D
var model: Node3D
var selection: Node3D
var target_ring: Node3D
var health_fill: MeshInstance3D
var caption: Label3D
var tether: MeshInstance3D
var tween: Tween
var faction_color: Color
var pick_area: Area3D
var base_disc: MeshInstance3D
var wreck: Node3D
var active_ring: Node3D
var health_tween: Tween
var shown_structure: int = -1
var was_alive: bool = true
var dying: bool = false
var pulse_time: float = 0.0
var base_marks: Node3D
var tether_ticks: Node3D
var caption_height: float = 0.0
var animation: TeamsterAnimator
var move_duration: float = 0.55
## Seconds to hold the next damage drain and death, so they land in an attack cinematic's reaction shot.
var presentation_delay: float = 0.0

func setup(state: UnitState) -> void:
	unit = state
	faction_color = ArtPalette.faction(unit.loadout.faction)
	body = Node3D.new()
	add_child(body)
	body.position = unit.world_position()
	model = Node3D.new()
	body.add_child(model)
	model.rotation.y = -unit.facing
	UnitModelFactory.build_model(model, unit.loadout.frame.movement_type, faction_color, unit.loadout.frame.id)
	# Size class scales the model; captions, health bar and picking follow it.
	var model_scale := unit.loadout.frame.model_scale()
	model.scale = Vector3.ONE * model_scale
	if not unit.loadout.workshop_parts.is_empty():
		TeamsterParts.apply(model, unit.loadout.workshop_parts)
	if unit.loadout.frame.id == "m9_teamster":
		animation = TeamsterAnimator.new()
		model.add_child(animation)
		animation.two_handed = TeamsterParts.two_handed(unit.loadout.workshop_parts)
		animation.setup(model)
	if not unit.loadout.workshop_finish.is_empty():
		var has_hornet := unit.loadout.weapons.any(func(weapon: WeaponData) -> bool: return weapon.id == "hornet_pod")
		WorkshopAppearance.apply(model, WorkshopAppearance.finish_by_id(unit.loadout.workshop_finish), "", not has_hornet, unit.loadout.workshop_part_finishes)
	base_disc = Primitives.cylinder(self, unit.loadout.frame.size + 0.22, 0.018, Vector3(0, 0.012, 0), Color("172633"))
	base_marks = Node3D.new()
	add_child(base_marks)
	Primitives.ring(base_marks, unit.loadout.frame.size + 0.1, faction_color, 0.045, 0.035)
	# A wide, open chevron stays on the ground independently of the model.
	var nose := unit.loadout.frame.size + 0.4
	Primitives.line(base_marks, PackedVector3Array([Vector3(-0.23, 0.07, -nose + 0.22), Vector3(0, 0.07, -nose), Vector3(0.23, 0.07, -nose + 0.22)]), ArtPalette.MARK, 0.075)
	wreck = Node3D.new()
	add_child(wreck)
	UnitModelFactory.build_wreck(wreck, unit.loadout.frame.movement_type, faction_color, unit.loadout.frame.size)
	wreck.visible = false
	selection = Node3D.new()
	add_child(selection)
	var extent := unit.loadout.frame.size + 0.34
	for x in [-1.0, 1.0]:
		for z in [-1.0, 1.0]:
			Primitives.line(selection, PackedVector3Array([Vector3(x * (extent - 0.2), 0.08, z * extent), Vector3(x * extent, 0.08, z * extent), Vector3(x * extent, 0.08, z * (extent - 0.2))]), ArtPalette.MARK, 0.065)
	# Crosshair rather than a ring so it differs from selection/active by shape, not just colour.
	target_ring = Node3D.new()
	add_child(target_ring)
	var reticle := unit.loadout.frame.size + 0.32
	Primitives.ring(target_ring, reticle, BattleUI.TARGET, 0.1, 0.06)
	for i in 4:
		var spoke := Vector3(sin(i * PI * 0.5), 0, cos(i * PI * 0.5))
		Primitives.line(target_ring, PackedVector3Array([spoke * (reticle - 0.14) + Vector3.UP * 0.1, spoke * (reticle + 0.24) + Vector3.UP * 0.1]), BattleUI.TARGET, 0.07)
	target_ring.visible = false
	active_ring = Primitives.ring(self, unit.loadout.frame.size + 0.54, Color(ArtPalette.MARK, 0.65), 0.07, 0.035)
	active_ring.visible = false
	caption = Primitives.label(body, "", Vector3(0, (1.85 if unit.loadout.frame.id == "hx7_kestrel" else 1.62) * model_scale, 0), faction_color, 17)
	caption.render_priority = 1
	caption_height = caption.position.y
	# Ties a floating body to its base disc; scaled to the body height in update_tether().
	tether = Primitives.box(body, Vector3(0.035, 1.0, 0.035), Vector3.ZERO, faction_color)
	tether.material_override = Primitives.material(Color(faction_color, 0.55), true, true)
	tether_ticks = Node3D.new()
	body.add_child(tether_ticks)
	for i in 2:
		Primitives.box(tether_ticks, Vector3(0.28, 0.055, 0.055), Vector3.ZERO, faction_color).material_override = Primitives.material(faction_color, false, true)
	var health := Node3D.new()
	body.add_child(health)
	health.position = Vector3(0, (1.57 if unit.loadout.frame.id == "hx7_kestrel" else 1.34) * model_scale, 0)
	Primitives.box(health, Vector3(0.8, 0.055, 0.06), Vector3.ZERO, Color("182838"))
	health_fill = Primitives.box(health, Vector3(0.78, 0.06, 0.065), Vector3.ZERO, faction_color)
	health_fill.material_override = Primitives.material(faction_color, false, true)
	pick_area = Area3D.new()
	pick_area.collision_layer = 2
	pick_area.collision_mask = 0
	pick_area.set_meta("unit_id", unit.loadout.id)
	body.add_child(pick_area)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 1.6, 1.0) * model_scale
	shape.shape = box
	shape.position.y = 0.5 * model_scale
	pick_area.add_child(shape)
	sync(true)

## Mech wrecks match the WRECK cover terrain added by BattleState.add_wreck(); aircraft debris is flat scenery.
func sync(immediate: bool = false) -> void:
	var ground_position := Vector3(unit.position.x, 0, unit.position.y)
	# Base nodes are in world coordinates; the floating body is independent.
	for child in get_children():
		if child != body and child is Node3D:
			child.position.x = ground_position.x
			child.position.z = ground_position.z
	if immediate or tween == null or not tween.is_running():
		body.position = unit.world_position()
		model.rotation.y = -unit.facing
	base_marks.rotation.y = -unit.facing
	if immediate or shown_structure < 0:
		set_health_ratio(health_ratio())
	elif unit.structure != shown_structure:
		# Drain after the shot lands rather than snapping.
		if health_tween != null:
			health_tween.kill()
		health_tween = create_tween()
		health_tween.tween_method(set_health_ratio, health_fill.scale.x, health_ratio(), 0.45).set_delay(0.2 + presentation_delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	shown_structure = unit.structure
	if was_alive and not unit.alive() and not immediate and not unit.withdrawn:
		play_death(presentation_delay)
	presentation_delay = 0.0
	was_alive = unit.alive()
	# The health bar carries HP. Airborne bands are named; Ground is implied by having no tether.
	caption.text = unit.loadout.callsign.replace(" / ", " ")
	if unit.altitude > 0:
		caption.text += " · " + UnitState.ALTITUDES[unit.altitude]
	if unit.alive() and not unit.engaged.is_empty():
		caption.text += " · MELEE"
	# Engaged units stand base to base; lift the Red caption so the pair stays readable.
	caption.position.y = caption_height + (0.8 if unit.loadout.faction == 1 and unit.alive() and not unit.engaged.is_empty() else 0.0)
	body.visible = unit.alive() or dying
	base_disc.visible = unit.alive() or dying
	base_marks.visible = unit.alive() or dying
	wreck.visible = not unit.alive() and not unit.withdrawn and not dying
	wreck.rotation.y = -unit.facing
	update_tether()
	pick_area.monitorable = unit.alive()
	pick_area.collision_layer = 2 if unit.alive() else 0
	if not unit.alive():
		selection.visible = false
		target_ring.visible = false
		active_ring.visible = false

func health_ratio() -> float:
	return float(unit.structure) / unit.loadout.frame.structure

func set_health_ratio(ratio: float) -> void:
	health_fill.scale.x = maxf(0.001, ratio)
	health_fill.position.x = -0.39 * (1 - health_fill.scale.x)

## Short shudder when a shot lands; delay matches the beam's travel time.
func hit_react(delay: float) -> void:
	var shake := create_tween().set_parallel(false)
	shake.tween_interval(delay)
	for offset in [0.09, -0.07, 0.05, -0.03, 0.0]:
		shake.tween_property(model, "position:x", offset, 0.04)

func play_death(delay: float = 0.0) -> void:
	dying = true
	var sequence := create_tween()
	if delay > 0.0:
		sequence.tween_interval(delay)
	if animation != null: sequence.tween_callback(animation.rest)
	sequence.tween_interval(0.3)
	sequence.tween_callback(func() -> void: CelEffects.burst(self, body.position + Vector3.UP * 0.5, 2.2))
	sequence.tween_property(body, "scale", Vector3(1.15, 0.2, 1.15), 0.18)
	sequence.tween_callback(func() -> void:
		dying = false
		body.scale = Vector3.ONE
		sync())

func set_active(value: bool) -> void:
	active_ring.visible = value and unit.alive()

func _process(delta: float) -> void:
	if active_ring.visible:
		pulse_time += delta
		var pulse := 1.0 + 0.1 * sin(pulse_time * 6.0)
		active_ring.scale = Vector3(pulse, 1, pulse)
	if target_ring.visible:
		target_ring.rotation.y += delta * 0.9
	update_tether()
	# Ground cues follow the rendered body during movement, without changing state.
	for cue in [base_disc, base_marks, selection, target_ring, active_ring]:
		cue.position.x = body.position.x
		cue.position.z = body.position.z
	base_marks.rotation.y = model.rotation.y

func update_tether() -> void:
	var height := body.position.y
	tether.visible = height > 0.2
	tether.scale.y = maxf(0.001, height)
	tether.position.y = -height * 0.5
	for i in tether_ticks.get_child_count():
		var tick: MeshInstance3D = tether_ticks.get_child(i)
		tick.visible = height > 0.2 and i < unit.altitude
		tick.position.y = -height + height * (i + 1.0) / (unit.altitude + 1.0)
	var shadow_size := 1.0 - unit.altitude * 0.23
	base_disc.scale = Vector3(shadow_size, 1.0, shadow_size)

func animate(path: PackedVector2Array) -> void:
	if tween != null:
		tween.kill()
	tween = create_tween()
	var count := path.size()
	var distance := 0.0
	for i in range(1, count): distance += path[i - 1].distance_to(path[i])
	move_duration = clampf(distance / 0.9, 0.7, 2.6) if animation != null and distance > 0.02 else 0.55
	if animation != null:
		if distance > 0.02:
			animation.walk(clampf(distance / move_duration / 0.58, 0.65, 2.5))
		elif absf(angle_difference(model.rotation.y, -unit.facing)) > 0.03:
			animation.turn(angle_difference(model.rotation.y, -unit.facing))
	# Preserve curved aircraft paths while keeping interpolation lightweight.
	var previous := 0
	for i in range(4, count + 4, 4):
		var index := mini(i, count - 1)
		if index <= previous:
			continue
		var point := path[index]
		tween.tween_property(body, "position", Vector3(point.x, unit.world_position().y, point.y), move_duration * (index - previous) / maxf(1, count - 1))
		previous = index
	tween.parallel().tween_property(model, "rotation:y", -unit.facing, 0.15)
	if animation != null and distance > 0.02:
		tween.tween_callback(animation.idle)
	sync()

func fire_animation(weapon_id: String) -> void:
	if animation != null and unit.alive(): animation.fire(weapon_id)

func muzzle_position(weapon_id: String) -> Vector3:
	if animation != null:
		var muzzle := animation.socket(weapon_id)
		if muzzle != null: return muzzle.global_position
	return body.global_position + Vector3.UP * 0.6

func highlight(selected: bool, target: bool) -> void:
	selection.visible = selected and unit.alive()
	target_ring.visible = target and unit.alive()
