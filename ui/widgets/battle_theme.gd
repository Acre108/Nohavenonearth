class_name BattleTheme
extends RefCounted

static func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 15
	theme.set_color("font_color", "Label", Color("dce8f1"))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("203447") if state == "normal" else Color("2b4d62")
		if state == "disabled":
			style.bg_color = Color("152330")
		style.set_corner_radius_all(2)
		style.set_content_margin_all(8)
		style.border_color = Color("42677a") if state == "focus" else Color("30485a")
		style.set_border_width_all(1)
		theme.set_stylebox(state, "Button", style)
		theme.set_stylebox(state, "OptionButton", style)
	theme.set_color("font_disabled_color", "Button", Color("617789"))
	theme.set_color("font_color", "Button", Color("deebf2"))
	# One filled accent button per state marks the action that moves the game forward.
	theme.set_type_variation("PrimaryButton", "Button")
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = {"normal": Color("3fb8cf"), "hover": Color("63d8ed"), "pressed": Color("2c93a8"), "focus": Color("3fb8cf")}[state]
		style.border_color = Color("a8eef9") if state == "focus" else style.bg_color
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		style.set_content_margin_all(8)
		theme.set_stylebox(state, "PrimaryButton", style)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		theme.set_color(state, "PrimaryButton", Color("06131c"))
	theme.set_constant("separation", "VBoxContainer", 7)
	theme.set_constant("separation", "HBoxContainer", 9)
	return theme
