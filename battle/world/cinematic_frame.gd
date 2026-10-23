class_name CinematicFrame
extends CanvasLayer

## Letterbox bars and a one-line attack caption, shown while the HUD is hidden for a cinematic.
const BAR := 0.11
var top: ColorRect
var bottom: ColorRect
var caption: Label
var hint: Label
var fade: Tween

func _ready() -> void:
	# Above the 3D finish (-10), below the HUD (1), which is hidden while this shows.
	layer = 0
	top = bar(Control.PRESET_TOP_WIDE)
	bottom = bar(Control.PRESET_BOTTOM_WIDE)
	caption = Label.new()
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.add_theme_font_size_override("font_size", 20)
	caption.add_theme_color_override("font_color", Color("e8edf2"))
	bottom.add_child(caption)
	hint = Label.new()
	hint.text = "ANY KEY OR CLICK · SKIP"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hint.offset_right = -28
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("8ca5b9"))
	bottom.add_child(hint)
	set_bars(0.0)
	visible = false

func bar(preset: Control.LayoutPreset) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = Color("05070d")
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(preset)
	add_child(rect)
	return rect

func show_caption(text: String, color: Color) -> void:
	caption.text = text
	caption.add_theme_color_override("font_color", color)
	visible = true
	animate(1.0)

func close() -> void:
	animate(0.0)

func animate(goal: float) -> void:
	if fade != null:
		fade.kill()
	fade = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	fade.tween_method(set_bars, top.anchor_bottom / BAR, goal, 0.3)
	if goal <= 0.0:
		fade.chain().tween_callback(func() -> void: visible = false)

func set_bars(amount: float) -> void:
	top.anchor_bottom = BAR * amount
	top.offset_bottom = 0
	bottom.anchor_top = 1.0 - BAR * amount
	bottom.offset_top = 0
	caption.modulate.a = amount
	hint.modulate.a = amount
