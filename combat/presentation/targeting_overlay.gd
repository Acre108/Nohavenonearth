class_name TargetingOverlay
extends Node3D

var displayed_radii := Vector2.ZERO
var displayed_altitude: int = 0

const SIGHT_RAYS := 48
const SIGHT_STEP := 0.2

func show_arc(unit: UnitState, weapon: WeaponData, target: UnitState = null, _projected: bool = false, battle: BattleState = null) -> void:
	# Ground projection aligns range with the units' base markers and terrain footprints.
	position = Vector3(unit.position.x, 0.08, unit.position.y)
	displayed_altitude = target.altitude if target != null else unit.altitude
	displayed_radii = CombatRules.horizontal_range(weapon, displayed_altitude - unit.altitude, CombatRules.reach_allowance(weapon, unit, target))
	var color := ArtPalette.ARC
	var camera := get_viewport().get_camera_3d()
	var zoom := maxf(1.0, TacticalCamera.view_height(camera, global_position) / 17.5)
	var screen_up := camera.global_basis.y if camera != null else Vector3.UP
	# The sector's shape carries range and arc; weapon name and numbers live in the inspector and dropdown.
	# The only words drawn here are the target distance, and this one case where there is no shape to show.
	if displayed_radii.y < 0:
		caption("Can't reach this altitude", Vector3(0, 0.35, 0), ArtPalette.INVALID, zoom)
		return
	var inner := displayed_radii.x
	var outer := displayed_radii.y
	if battle != null:
		sight_sector(battle, unit, weapon.arc, inner, outer, color)
	else:
		sector(unit.facing, weapon.arc, inner, outer, Color(color, 0.08))
	Primitives.line(self, arc_points(unit.facing, weapon.arc, outer), Color(color, 0.95), 0.055)
	if inner > 0:
		sector(unit.facing, weapon.arc, 0, inner, Color(color, 0.035))
		Primitives.line(self, arc_points(unit.facing, weapon.arc, inner), Color(color, 0.55), 0.035)
	if weapon.arc < 360:
		var left := direction(unit.facing - deg_to_rad(weapon.arc * 0.5))
		var right := direction(unit.facing + deg_to_rad(weapon.arc * 0.5))
		Primitives.line(self, PackedVector3Array([left * inner, left * outer]), color, 0.04)
		Primitives.line(self, PackedVector3Array([right * inner, right * outer]), color, 0.04)
		# A faint dashed circle distinguishes raw range from the solid firing arc.
		for i in range(36):
			var a := TAU * i / 36.0
			Primitives.line(self, PackedVector3Array([direction(a) * outer, direction(a + TAU / 72.0) * outer]), Color(color, 0.23), 0.025)
	# One-unit range contours, clipped to the usable sector.
	for radius in range(int(ceil(inner)), int(ceil(outer))):
		if radius > inner + 0.1:
			Primitives.line(self, arc_points(unit.facing, weapon.arc, radius), Color(color, 0.25), 0.018)
	if target != null:
		var offset := target.position - unit.position
		var end := Vector3(offset.x, 0.015, offset.y)
		var distance := CombatRules.range_distance(unit, target, weapon)
		var in_range := distance >= weapon.range_min - 0.01 and distance <= weapon.range_max + 0.01
		distance = maxf(0.0, distance)
		var ruler_color := color if in_range else ArtPalette.INVALID
		Primitives.line(self, PackedVector3Array([Vector3(0, 0.015, 0), end]), Color(ruler_color, 0.8), 0.04)
		caption("%.1f" % distance, end * 0.5 - screen_up * 0.6, ruler_color, zoom)

func direction(angle: float) -> Vector3:
	return Vector3(sin(angle), 0, -cos(angle))

func arc_points(facing: float, arc: float, radius: float) -> PackedVector3Array:
	var points := PackedVector3Array()
	for i in range(81):
		points.append(direction(facing + deg_to_rad(-arc * 0.5 + arc * i / 80.0)) * radius)
	return points

func sector(facing: float, arc: float, inner: float, outer: float, color: Color) -> void:
	if outer <= inner:
		return
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(80):
		var a := direction(facing + deg_to_rad(-arc * 0.5 + arc * i / 80.0))
		var b := direction(facing + deg_to_rad(-arc * 0.5 + arc * (i + 1) / 80.0))
		for point in [a * inner, a * outer, b * outer, a * inner, b * outer, b * inner]:
			surface.add_vertex(point)
	var node := MeshInstance3D.new()
	node.mesh = surface.commit()
	node.material_override = Primitives.material(color, true, true)
	add_child(node)

## How far each ray through the arc can see before sight-blocking terrain cuts it off (same test as the rules).
func sight_limits(battle: BattleState, unit: UnitState, arc: float, outer: float) -> PackedFloat32Array:
	var limits := PackedFloat32Array()
	var from := TerrainRules.eye(unit.position, unit.altitude)
	for i in SIGHT_RAYS + 1:
		var angle := unit.facing + deg_to_rad(-arc * 0.5 + arc * i / float(SIGHT_RAYS))
		var ray := Vector2(sin(angle), -cos(angle))
		var limit := outer
		var distance := SIGHT_STEP
		while distance <= outer:
			if not TerrainRules.sight_clear(battle, from, TerrainRules.eye(unit.position + ray * distance, displayed_altitude)):
				limit = maxf(0.0, distance - SIGHT_STEP * 0.5)
				break
			distance += SIGHT_STEP
		limits.append(limit)
	return limits

## The firing sector split into what the unit can see (normal fill) and what terrain hides (magenta shadow).
func sight_sector(battle: BattleState, unit: UnitState, arc: float, inner: float, outer: float, color: Color) -> void:
	var limits := sight_limits(battle, unit, arc, outer)
	var visible := SurfaceTool.new()
	visible.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hidden := SurfaceTool.new()
	hidden.begin(Mesh.PRIMITIVE_TRIANGLES)
	var any_hidden := false
	for i in SIGHT_RAYS:
		var a := direction(unit.facing + deg_to_rad(-arc * 0.5 + arc * i / float(SIGHT_RAYS)))
		var b := direction(unit.facing + deg_to_rad(-arc * 0.5 + arc * (i + 1) / float(SIGHT_RAYS)))
		var limit := clampf(minf(limits[i], limits[i + 1]), inner, outer)
		for point in [a * inner, a * limit, b * limit, a * inner, b * limit, b * inner]:
			visible.add_vertex(point)
		if limit < outer - 0.01:
			any_hidden = true
			for point in [a * limit, a * outer, b * outer, a * limit, b * outer, b * limit]:
				hidden.add_vertex(point)
	for pair in [[visible, Color(color, 0.08)], [hidden, Color(ArtPalette.INVALID, 0.26)]]:
		if pair[0] == hidden and not any_hidden:
			continue
		var node := MeshInstance3D.new()
		node.mesh = pair[0].commit()
		node.material_override = Primitives.material(pair[1], true, true)
		add_child(node)

func caption(text: String, point: Vector3, color: Color, zoom: float) -> void:
	var label := Primitives.label(self, text, point, color, 14)
	label.pixel_size *= zoom
