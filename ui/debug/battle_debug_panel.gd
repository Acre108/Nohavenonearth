class_name BattleDebugPanel
extends BattleUISection

var debug_window: Window
var debug_body: VBoxContainer

func build_debug() -> void:
	debug_window = Window.new()
	debug_window.title = "No Haven on Earth / Rules sandbox"
	debug_window.size = Vector2i(560, 690)
	debug_window.transient = true
	debug_window.visible = false
	debug_window.close_requested.connect(func() -> void: debug_window.hide())
	root.add_child(debug_window)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	debug_window.add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	debug_body = VBoxContainer.new()
	debug_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(debug_body)

func toggle_debug() -> void:
	if debug_window.visible:
		debug_window.hide()
	else:
		refresh_debug()
		debug_window.popup_centered()

func toggle(parent: Node, text: String, value: bool, callback: Callable) -> void:
	var item := CheckBox.new()
	item.text = text
	item.button_pressed = value
	item.toggled.connect(callback)
	parent.add_child(item)

func spin(parent: Node, value: float, maximum: float, callback: Callable, minimum: float = 0, step: float = 1) -> SpinBox:
	var item := SpinBox.new()
	item.min_value = minimum
	item.max_value = maximum
	item.step = step
	item.value = value
	item.custom_minimum_size.x = 90
	item.value_changed.connect(callback)
	parent.add_child(item)
	return item

func refresh_debug() -> void:
	clear(debug_body)
	var manager: TurnManager = controller.manager
	label(debug_body, "RULES SANDBOX", 20, BLUE)
	var row := HBoxContainer.new()
	debug_body.add_child(row)
	button(row, "RESTART BATTLE", func() -> void: debug_window.hide(); controller.restart())
	button(row, "ADVANCE ONE STEP", func() -> void: manager.advance(); refresh_debug())
	toggle(debug_body, "Enemy AI", manager.ai_enabled, func(value: bool) -> void: manager.set_ai(value))
	toggle(debug_body, "Reveal secret enemy orders", manager.reveal_enemy, func(value: bool) -> void: manager.reveal_enemy = value; controller.refresh_all())
	toggle(debug_body, "Pause automatic resolution", manager.paused, func(value: bool) -> void: manager.paused = value; controller.refresh_all())
	toggle(debug_body, "Show line of sight", controller.show_los, func(value: bool) -> void: controller.show_los = value; controller.refresh_overlays())
	toggle(debug_body, "Show firing arcs", controller.show_arcs, func(value: bool) -> void: controller.show_arcs = value; controller.refresh_overlays())
	toggle(debug_body, "Show movement ranges", controller.show_ranges, func(value: bool) -> void: controller.show_ranges = value; controller.refresh_overlays())
	var unit: UnitState = controller.selected
	if unit == null:
		return
	label(debug_body, "EDIT / " + unit.loadout.callsign, 17, GOLD)
	label(debug_body, "Live overrides affect this battle; base data stays intact.", 12, MUTED)
	var grid := GridContainer.new()
	grid.columns = 4
	debug_body.add_child(grid)
	for heading in ["Stat", "Pilot", "Bonus (frame/parts)", "Total"]:
		label(grid, heading, 13, MUTED)
	# Pilot ratings are whole; bonus quarter steps exercise fractional parts. The total is what the rules use.
	for stat in UnitState.STAT_NAMES:
		label(grid, stat.capitalize())
		var total_label := Label.new()
		spin(grid, float(unit.pilot_stats.get(stat, 0)), UnitState.PILOT_CAPS[stat] + 2, func(value: float) -> void: unit.pilot_stats[stat] = value; total_label.text = str(unit.stat(stat)); manager.debug_changed(unit), 0, 1)
		spin(grid, float(unit.bonus_stats.get(stat, 0)), UnitState.PILOT_CAPS[stat] + 2, func(value: float) -> void: unit.bonus_stats[stat] = value; total_label.text = str(unit.stat(stat)); manager.debug_changed(unit), 0, 0.25)
		total_label.text = str(unit.stat(stat))
		grid.add_child(total_label)
	var resources := GridContainer.new()
	resources.columns = 2
	debug_body.add_child(resources)
	label(resources, "Structure")
	spin(resources, unit.structure, unit.loadout.frame.structure, func(value: float) -> void: unit.structure = int(value); manager.debug_changed(unit))
	label(resources, "Energy")
	spin(resources, unit.energy, unit.loadout.frame.energy_available(), func(value: float) -> void: unit.energy = value; manager.debug_changed(unit), 0, 0.25)
	label(resources, "Will")
	spin(resources, unit.will, 20, func(value: float) -> void: unit.will = int(value); manager.debug_changed(unit))
	label(resources, "Force altitude")
	var altitude := OptionButton.new()
	resources.add_child(altitude)
	for band in UnitState.ALTITUDES:
		altitude.add_item(band)
	altitude.select(unit.altitude)
	altitude.item_selected.connect(func(index: int) -> void: unit.altitude = index; unit.order = null; manager.debug_changed(unit))
	var damage_row := HBoxContainer.new()
	debug_body.add_child(damage_row)
	button(damage_row, "DAMAGE −1", func() -> void: unit.structure = maxi(0, unit.structure - 1); manager.debug_changed(unit); refresh_debug())
	button(damage_row, "DESTROY SELECTED", func() -> void: unit.structure = 0; manager.debug_changed(unit); refresh_debug())
