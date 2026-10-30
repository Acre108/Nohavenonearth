class_name BattleHeader
extends BattleUISection

var workshop_session: WorkshopRuntime:
	get:
		return get_node("/root/WorkshopSession") as WorkshopRuntime

var round_label: Label
var status_label: Label
var status_style: StyleBoxFlat
var phase_row: HBoxContainer
var initiative_label: Label
var view_label: Label
var sensor_toggle: CheckButton
var cinematics: MenuButton

func build_header() -> void:
	var top := panel(root, Color("0c1723f5"))
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 18
	top.offset_top = 14
	top.offset_right = -18
	top.offset_bottom = 133
	var stack := VBoxContainer.new()
	top.add_child(stack)
	var row := HBoxContainer.new()
	stack.add_child(row)
	label(row, "NO HAVEN ON EARTH", 25, BLUE)
	var subtitle := label(row, "TACTICAL SKIRMISH  /  PROTOTYPE 01", 12, MUTED)
	subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var status_panel := PanelContainer.new()
	status_style = StyleBoxFlat.new()
	status_style.set_corner_radius_all(12)
	status_style.content_margin_left = 14
	status_style.content_margin_right = 14
	status_style.content_margin_top = 3
	status_style.content_margin_bottom = 3
	status_style.set_border_width_all(1)
	status_panel.add_theme_stylebox_override("panel", status_style)
	status_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(status_panel)
	status_label = label(status_panel, "", 14)
	round_label = label(row, "ROUND 01", 19, GOLD)
	button(row, "Reset view · R", func() -> void: controller.camera.reset_view())
	button(row, "Close view · V", func() -> void: controller.camera.toggle_close())
	button(row, "Debug · F3", ui.sandbox.toggle_debug)
	button(row, "Workshop", open_workshop)
	var phase_line := HBoxContainer.new()
	stack.add_child(phase_line)
	phase_row = HBoxContainer.new()
	phase_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_line.add_child(phase_row)
	view_label = label(phase_line, "BATTLEFIELD", 12, ArtPalette.MARK)
	view_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sensor_toggle = CheckButton.new()
	sensor_toggle.text = "Sensor view · F8"
	sensor_toggle.add_theme_font_size_override("font_size", 12)
	sensor_toggle.button_pressed = controller.presentation.sensor_enabled
	sensor_toggle.toggled.connect(func(value: bool) -> void: controller.presentation.set_sensor_view(value))
	phase_line.add_child(sensor_toggle)
	cinematics = MenuButton.new()
	cinematics.text = "Cinematics ▾"
	cinematics.add_theme_font_size_override("font_size", 12)
	cinematics.tooltip_text = "Camera cinematics for each side's attacks"
	var choices := cinematics.get_popup()
	choices.add_check_item("Blue attacks", 0)
	choices.add_check_item("Red attacks", 1)
	choices.hide_on_checkable_item_selection = false
	for faction in 2:
		choices.set_item_checked(faction, CinematicSettings.plays_for(faction))
	choices.id_pressed.connect(func(faction: int) -> void:
		CinematicSettings.set_for(faction, not CinematicSettings.plays_for(faction))
		choices.set_item_checked(faction, CinematicSettings.plays_for(faction)))
	phase_line.add_child(cinematics)
	initiative_label = label(stack, "", 12, MUTED)
	refresh_view()

func open_workshop() -> void:
	if controller.manager.phase == TurnManager.Phase.BATTLE_OVER:
		controller.return_to_workshop()
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Return to service bay"
	dialog.dialog_text = "End this skirmish and return to the workshop?" + (" The " + workshop_session.store.workshop_frame.display_name + "'s current hull damage will be saved." if workshop_session.active else " This standalone demo does not affect your workshop mech.")
	dialog.ok_button_text = "Return to workshop"
	add_child(dialog)
	var was_paused := controller.manager.paused
	controller.manager.paused = true
	dialog.confirmed.connect(func() -> void: controller.return_to_workshop(); dialog.queue_free())
	dialog.canceled.connect(func() -> void: controller.manager.paused = was_paused; dialog.queue_free())
	dialog.popup_centered()

func refresh_view() -> void:
	if view_label == null:
		return
	view_label.text = "SENSOR FEED" if controller.presentation.is_sensor else "BATTLEFIELD"
	sensor_toggle.set_pressed_no_signal(controller.presentation.sensor_enabled)

func refresh_status() -> void:
	var manager: TurnManager = controller.manager
	var blue_active := manager.active != null and manager.active.loadout.faction == 0
	var acting := manager.active.loadout.callsign.replace(" / ", " ") if manager.active != null else ""
	var text := "RESOLVING…"
	var kind := "auto"
	match manager.phase:
		TurnManager.Phase.PLANNING:
			text = "YOUR MOVE · PLAN ORDERS"
			kind = "you"
		TurnManager.Phase.REVEAL:
			text = "YOUR MOVE · REVIEW ENEMY ORDERS"
			kind = "you"
		TurnManager.Phase.ACTION, TurnManager.Phase.ATTACK:
			if manager.active != null:
				var verb := "ACT" if manager.phase == TurnManager.Phase.ACTION else "FIRE"
				text = ("YOUR MOVE · %s %s" % [acting, verb]) if blue_active else ("ENEMY %s · %s" % ["ACTING" if verb == "ACT" else "FIRING", acting])
				kind = "you" if blue_active else "enemy"
		TurnManager.Phase.BATTLE_OVER:
			text = "BATTLE OVER"
			kind = "over"
	if manager.auto_blue and kind == "you":
		kind = "auto"
	if manager.paused and kind in ["auto", "enemy"]:
		text = "PAUSED · " + text.trim_suffix("…")
	status_label.text = text
	var fill: Color = {"you": GOLD, "enemy": Color("3a1c22"), "auto": Color("16283a"), "over": Color("16283a")}[kind]
	status_style.bg_color = fill
	status_style.border_color = {"you": GOLD, "enemy": RED, "auto": Color("30485a"), "over": BLUE}[kind]
	status_label.add_theme_color_override("font_color", {"you": Color("1b1408"), "enemy": RED, "auto": MUTED, "over": BLUE}[kind])

func refresh() -> void:
	var manager: TurnManager = controller.manager
	round_label.text = "ROUND %02d" % manager.battle.round_number
	refresh_status()
	clear(phase_row)
	for i in range(6):
		var text := "%02d  %s" % [i + 1, TurnManager.PHASE_NAMES[i]]
		var phase_label := label(phase_row, text, 13, BLUE if i == manager.phase else MUTED.darkened(0.25))
		phase_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var queue := manager.movement_queue if manager.phase in [TurnManager.Phase.REVEAL, TurnManager.Phase.MOVEMENT] else manager.attack_queue
	if queue.is_empty():
		initiative_label.text = "Higher Reflex moves first and fires first · ties are random"
	else:
		var names: PackedStringArray = []
		for unit in queue:
			names.append(("▶ " if unit == manager.active else "") + unit.loadout.callsign.split(" / ")[1])
		var moving := manager.phase in [TurnManager.Phase.REVEAL, TurnManager.Phase.MOVEMENT]
		initiative_label.text = ("MOVE ORDER (quickest first)   " if moving else "FIRING ORDER (quickest first)   ") + "  →  ".join(names)
	initiative_label.tooltip_text = "Order is set by each pilot's Reflex skill. Open a unit's Full stats to see it."
	initiative_label.mouse_filter = Control.MOUSE_FILTER_PASS
