extends Control

const TEXT := Color("e2e4d7")
const MUTED := Color("91a3a6")
const GOLD := Color("e6b876")
var workshop_button: Button
var battle_button: Button

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("sensor_mix", 0.0)
	theme = BattleTheme.make_theme()
	var background := ColorRect.new()
	background.color = Color("10191e")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 48)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 22)
	margin.add_child(page)
	add_label(page, "FIELD OPERATIONS     /     PROTOTYPE", 13, MUTED)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 56)
	page.add_child(body)
	var copy := VBoxContainer.new()
	copy.custom_minimum_size.x = 460
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	copy.add_theme_constant_override("separation", 18)
	body.add_child(copy)
	add_label(copy, "NO HAVEN ON EARTH", 45, TEXT)
	add_paragraph(copy, "Keep the machines running.\nTake the squad into battle.", 21, MUTED)
	copy.add_child(HSeparator.new())
	add_label(copy, "01   /   SERVICE DEPOT", 12, GOLD)
	workshop_button = add_button(copy, "Open workshop", open_workshop)
	workshop_button.name = "OpenWorkshop"
	add_paragraph(copy, "Inspect your M9 Teamster. Assign a pilot, repair damage, replace components and customise its finish. Applied refits are saved locally.")
	add_label(copy, "02   /   TACTICAL SKIRMISH", 12, ArtPalette.FRIEND)
	battle_button = add_button(copy, "Play battle demo", open_demo)
	battle_button.name = "PlayBattleDemo"
	add_paragraph(copy, "Command the US squad against Pact forces in a standalone battle with the standard loadouts.")
	var bay := VBoxContainer.new()
	bay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bay.size_flags_stretch_ratio = 1.15
	body.add_child(bay)
	add_label(bay, "M9 TEAMSTER     /     BRANNOCK–HALE", 12, GOLD)
	var preview := WorkshopPreview.new()
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bay.add_child(preview)
	preview.angle = -0.45
	preview.update_camera()
	preview.show_fit(WorkshopAppearance.finish_by_id("depot"), "", false)
	add_label(bay, "GROUND FRAME    ·    STANDARD SERVICE FIT", 12, MUTED)
	page.add_child(HSeparator.new())
	add_label(page, "Workshop deployments use your saved refit. The battle demo uses the original squad loadouts.", 13, MUTED)
	workshop_button.grab_focus()

func add_label(parent: Node, text: String, font_size: int, colour: Color) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", colour)
	parent.add_child(node)
	return node

func add_paragraph(parent: Node, text: String, font_size: int = 15, colour: Color = MUTED) -> void:
	var node := add_label(parent, text, font_size, colour)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func add_button(parent: Node, text: String, action: Callable) -> Button:
	var node := Button.new()
	node.text = text + "  →"
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node.custom_minimum_size.y = 58
	node.add_theme_font_size_override("font_size", 20)
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(action)
	parent.add_child(node)
	return node

func open_workshop() -> void:
	get_node("/root/WorkshopSession").active = false
	get_tree().change_scene_to_file("res://workshop/Workshop.tscn")

func open_demo() -> void:
	get_node("/root/WorkshopSession").active = false
	get_tree().change_scene_to_file("res://battle/world/Battlefield.tscn")
