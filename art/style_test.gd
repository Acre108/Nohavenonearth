extends Node3D

var models: Array[Node3D] = []
var silhouette: bool = false
var materials: Dictionary = {}

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("sensor_mix", 1.0)
	var environment := WorldEnvironment.new()
	var settings := OvaRendering.environment()
	environment.environment = settings
	add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-55, -35, 0)
	key.light_energy = 1.3
	key.shadow_enabled = true
	add_child(key)
	var camera := Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 11.8
	camera.position = Vector3(0, 11, 12)
	camera.look_at(Vector3(0, 1.3, 0))
	camera.current = true
	var rendering := OvaRendering.install(self, camera)
	Primitives.box(self, Vector3(14, 0.1, 7), Vector3(0, -0.08, 0), Color("35414a")).material_override = ArtPalette.paint(Color("35414a"), true)
	var battle := BattleState.new(Catalogue.new(), 17)
	var indexes := [0, 1, 3, 4, 2]
	for i in indexes.size():
		var unit: UnitState = battle.units[indexes[i]]
		unit.position = Vector2((i - 2) * 2.5, 1.3)
		unit.altitude = 0
		unit.facing = PI
		var actor := UnitActor.new()
		add_child(actor)
		actor.setup(unit)
		actor.highlight(false, false)
		actor.caption.text = unit.loadout.frame.display_name
		models.append(actor.model)
	var terrain := TerrainActor.new()
	add_child(terrain)
	terrain.setup({"position": [-3.7, -2.0], "height": 1.6, "half_size": [0.8, 0.7], "blocks_los": true, "name": "CONTOUR / TERRAIN"})
	# Same frame at all three bands: count ticks and compare the ground shadows.
	for band in 3:
		var unit := UnitState.new(battle.units[2].loadout)
		unit.position = Vector2(0.0 + band * 2.6, -2.1)
		unit.altitude = band
		var actor := UnitActor.new()
		add_child(actor)
		actor.setup(unit)
		actor.highlight(false, false)
		actor.caption.text = UnitState.ALTITUDES[band]
		models.append(actor.model)
	build_controls(rendering)

func build_controls(rendering: OvaRendering) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = 20
	layer.add_child(panel)
	var stack := VBoxContainer.new()
	panel.add_child(stack)
	var title := Label.new()
	title.text = "NO HAVEN ON EARTH     ·     ART STYLE TEST"
	title.add_theme_font_size_override("font_size", 24)
	stack.add_child(title)
	var row := HBoxContainer.new()
	stack.add_child(row)
	var label := Label.new()
	label.text = "OVA / CEL     ←     sensor_mix     →     SENSOR FEED"
	label.add_theme_font_size_override("font_size", 16)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = 1.0
	slider.custom_minimum_size.x = 280
	slider.value_changed.connect(func(value: float) -> void: RenderingServer.global_shader_parameter_set("sensor_mix", value))
	row.add_child(slider)
	var toggle := CheckButton.new()
	toggle.text = "Black silhouettes"
	toggle.toggled.connect(set_silhouette)
	row.add_child(toggle)
	var effects := HBoxContainer.new()
	stack.add_child(effects)
	var softness := CheckButton.new()
	softness.text = "LaserDisc / 75% 3D"
	softness.toggled.connect(rendering.set_laserdisc)
	effects.add_child(softness)
	if rendering.composite != null:
		var mask := CheckButton.new()
		mask.text = "Mech mask"
		mask.toggled.connect(func(value: bool) -> void: rendering.composite.set_shader_parameter("show_mask", value))
		effects.add_child(mask)
		var paint := CheckButton.new()
		paint.text = "Painterly background"
		paint.button_pressed = true
		paint.toggled.connect(func(value: bool) -> void: rendering.composite.set_shader_parameter("paint_strength", 0.45 if value else 0.0))
		effects.add_child(paint)
		var lines := CheckButton.new()
		lines.text = "Interior lines"
		lines.button_pressed = true
		lines.toggled.connect(func(value: bool) -> void: rendering.composite.set_shader_parameter("edge_strength", 0.65 if value else 0.0))
		effects.add_child(lines)
	var guide := Label.new()
	guide.text = "FRONT / KESTREL · TEAMSTER · MEDVED · TIESHAN · FIGHTER     |     REAR / TERRAIN · GROUND · LOW · HIGH"
	guide.add_theme_font_size_override("font_size", 14)
	stack.add_child(guide)

func set_silhouette(value: bool) -> void:
	silhouette = value
	for model in models:
		apply_silhouette(model, value)

func apply_silhouette(node: Node, value: bool) -> void:
	if node is MeshInstance3D:
		if not materials.has(node):
			materials[node] = node.material_override
		node.material_override = Primitives.material(Color.BLACK, false, true) if value else materials[node]
	for child in node.get_children():
		apply_silhouette(child, value)
