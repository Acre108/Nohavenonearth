class_name FlightRadial
extends BattleUISection

var radial: Control
var radial_items: Array[Dictionary] = []

const RADIAL_RADIUS := 64.0
const RADIAL_BUTTON := Vector2(40, 26)
const RADIAL_MIN_GAP := 2.0 * asin((RADIAL_BUTTON.x * 0.5 + 4.0) / RADIAL_RADIUS)

func build() -> void:
	radial = Control.new()
	radial.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	radial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(radial)

func refresh_radial() -> void:
	clear(radial)
	radial_items.clear()
	if not controller.planning_aircraft():
		return
	# Rebuilt buttons never see the cursor leave, so drop any stale hover ghost.
	controller.clear_hover_option()
	var catalogue: Catalogue = controller.manager.battle.catalogue
	for order in controller.planning.option_orders:
		var move: ManoeuvreData = catalogue.manoeuvres[order.manoeuvre_id]
		var item := button(radial, radial_name(move), func() -> void: controller.choose_option(move.id), not order.valid)
		item.custom_minimum_size = RADIAL_BUTTON
		item.add_theme_font_size_override("font_size", 12)
		var tip := "%s\n%d Energy" % [move.display_name, move.energy_cost]
		if not order.valid:
			tip += "\nUnavailable: " + order.reason
		elif order.leaves_battlefield:
			tip += "\nLeaves the table: the aircraft withdraws from battle."
			item.add_theme_color_override("font_color", INVALID)
		item.tooltip_text = tip + ("\nClick again to confirm." if move.id == controller.planning.manoeuvre_id else "\nClick to select.")
		if move.id == controller.planning.manoeuvre_id:
			primary(item)
		# Compact padding, copied from whichever style (plain or primary) the button now uses.
		for state in ["normal", "hover", "pressed", "disabled"]:
			var style: StyleBoxFlat = item.get_theme_stylebox(state).duplicate()
			style.set_content_margin_all(3)
			item.add_theme_stylebox_override(state, style)
		item.mouse_entered.connect(func() -> void: controller.set_hover_option(move.id))
		item.mouse_exited.connect(func() -> void:
			if controller.planning.hover_option == move.id:
				controller.set_hover_option(""))
		radial_items.append({"button": item, "order": order})
	layout_radial()

static func radial_name(move: ManoeuvreData) -> String:
	var text := ""
	for word in move.display_name.split(" ", false):
		text += word if word.is_valid_int() else word.get_slice("-", word.get_slice_count("-") - 1).left(1)
	return text.to_upper()

func _process(_delta: float) -> void:
	if not radial_items.is_empty():
		layout_radial()

func layout_radial() -> void:
	var unit: UnitState = controller.selected
	if unit == null or not controller.actors.has(unit.loadout.id):
		return
	var camera: Camera3D = controller.camera
	var body: Vector3 = controller.actors[unit.loadout.id].body.global_position
	var center := camera.unproject_position(body)
	var forward := (camera.unproject_position(body + Vector3(unit.forward().x, 0, unit.forward().y)) - center).angle()
	var angles: Array[float] = []
	for item in radial_items:
		var order: MovementOrder = item.order
		var tip := camera.unproject_position(Vector3(order.destination.x, body.y, order.destination.y))
		angles.append(wrapf((tip - center).angle() - forward, -PI, PI))
	var order_index: Array = range(angles.size())
	order_index.sort_custom(func(a: int, b: int) -> bool: return angles[a] < angles[b] or (is_equal_approx(angles[a], angles[b]) and a < b))
	for pass_count in 24:
		for k in range(1, order_index.size()):
			var gap: float = angles[order_index[k]] - angles[order_index[k - 1]]
			if gap < RADIAL_MIN_GAP:
				angles[order_index[k - 1]] -= (RADIAL_MIN_GAP - gap) * 0.5
				angles[order_index[k]] += (RADIAL_MIN_GAP - gap) * 0.5
	for i in radial_items.size():
		var item: Button = radial_items[i].button
		item.position = center + Vector2.from_angle(forward + angles[i]) * RADIAL_RADIUS - item.size * 0.5
