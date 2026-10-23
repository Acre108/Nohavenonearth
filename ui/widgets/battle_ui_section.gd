class_name BattleUISection
extends Node

## Shared widget construction for the battle HUD sections.
const BLUE := ArtPalette.FRIEND
const RED := ArtPalette.HOSTILE
const MUTED := Color("8ca5b9")
const GOLD := ArtPalette.DRAFT
const TARGET := ArtPalette.MARK
const INVALID := ArtPalette.INVALID

var ui: BattleUI
var controller: BattleController:
	get: return ui.controller
var root: Control:
	get: return ui.root

static func panel(parent: Node, color: Color = Color("111f2de8")) -> PanelContainer:
	var node := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("304657")
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(13)
	node.add_theme_stylebox_override("panel", style)
	parent.add_child(node)
	return node

static func label(parent: Node, text: String, size: int = 15, color: Color = Color("dce8f1")) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", maxi(12, size))
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

static func button(parent: Node, text: String, callback: Callable, disabled: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.disabled = disabled
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

static func primary(node: Button, enabled: bool = true) -> Button:
	if enabled and not node.disabled:
		node.theme_type_variation = "PrimaryButton"
	return node

static func clear(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
