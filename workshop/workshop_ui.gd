class_name WorkshopUI
extends Control

const INK := Color("10191e")
const PANEL := Color("18252b")
const BAY := Color("101c21")
const CARD := Color("203037")
const FOOTER := Color("1d2b30")
const TEXT := Color("e2e4d7")
const MUTED := Color("91a3a6")
const DIM := Color("687c80")
const ACCENT := Color("e6b876")
const GREEN := Color("a4c7a0")
const RED := Color("ee9982")
const BUTTON_FILL := Color("223238")
const BUTTON_LIT := Color("34474a")
const BUTTON_OFF := Color("1c282d")
const BUTTON_EDGE := Color("3c5054")
const POPUP_EDGE := Color("5b7279")
const LEFT_SLOTS := ["head.sensor", "torso.structure", "torso.armour", "left_arm.actuator", "left_arm.armour", "left_leg.drive", "left_leg.armour"]
const RIGHT_SLOTS := ["power.plant", "backpack.service", "backpack.module", "right_arm.actuator", "right_arm.armour", "right_leg.drive", "right_leg.armour"]
const SLOT_TITLES := {"head.sensor":"Sensors", "torso.structure":"Structure", "torso.armour":"Plating", "power.plant":"Power plant", "backpack.service":"Service rig", "backpack.module":"Mission module"}
## Preview clips as [animation, menu title], in AnimationChoice order.
const CLIPS := [["idle", "Idle"], ["walk", "Walk"], ["turn_left", "Turn left"], ["turn_right", "Turn right"], ["ready", "Weapon ready"], ["fire_rifle", "Fire rifle"], ["fire_missiles", "Fire missiles"], ["fire_stake", "Fire stake"], ["melee", "Melee"], ["twohand_ready", "Rifle aim"], ["twohand_fire", "Rifle fire"], ["twohand_reload", "Rifle reload"], ["fire_cannon", "Fire cannon"], ["fire_breacher", "Fire breacher"]]
const INSPECTION_MODES := [["assembled", "Assembled"], ["exploded", "Exploded"], ["isolated", "Isolate region"]]
const STAT_LABELS := {"base_move":"Move", "energy_capacity":"Energy", "energy_recharge":"Recharge"}
## Stat table columns as [heading, tooltip].
const TABLE_COLUMNS := [["STAT", ""], ["FRAME", "Frame includes equipment and wear."], ["PILOT", ""], ["TOTAL", "Pilot + Frame in whole points (fractions count once they add up to a point), capped at Threshold."], ["THRESHOLD", "Maximum allowed by this frame."]]
## The two-handed rifle needs both arms; neither is legal alone.
const RIFLE_KIT := {"right_arm.actuator":"arm_marksman", "left_arm.actuator":"arm_support"}
const EXITS := {
	"menu": {"scene":"res://ui/menu/Landing.tscn", "prompt":"return to the main menu"},
	"demo": {"scene":"res://battle/world/Battlefield.tscn", "prompt":"open the standalone skirmish"},
}
const BUTTON_STATES := ["normal", "hover", "pressed", "focus"]

var workshop_session: WorkshopRuntime:
	get: return get_node("/root/WorkshopSession") as WorkshopRuntime
var store: WorkshopState
var catalogue := Catalogue.new()
## The unapplied refit being edited; see WorkshopState.draft().
var draft: Dictionary
var base: FrameData
var pilot_stats: Dictionary
var selected_region := "left_arm"
var selected_slot := "left_arm.actuator"
var inspected_uid := ""
## What the picker popup shows: "parts", "paint" or "weapons".
var picker_mode := "parts"
var show_incompatible := false
var message := ""
var pending_exit := ""

var title_caption: Label
var credits_label: Label
var fit_status: Label
var bay_caption: Label
var preview: WorkshopPreview
var inspection_buttons: Dictionary = {}
var slot_buttons: Dictionary = {}
var slot_condition_labels: Dictionary = {}
var animation_choice: OptionButton
var tool_buttons: Dictionary = {}
var stats_column: VBoxContainer
var footer: HBoxContainer
var pilot_bar: HBoxContainer
var picker: PopupPanel
var picker_scroll: ScrollContainer
var picker_content: VBoxContainer
var exit_dialog: ConfirmationDialog
var frame_choice: OptionButton
const WORKSHOP_FRAMES := ["m9_teamster", "hx7_kestrel"]

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("sensor_mix", 0.0)
	store = workshop_session.store
	draft = store.draft()
	base = store.workshop_frame
	pilot_stats = store.pilots.entries[draft.pilot].stats
	message = workshop_session.notice
	workshop_session.notice = ""
	theme = make_theme()
	build()
	refresh()

# --- Widget helpers ---

func make_theme() -> Theme:
	var result := BattleTheme.make_theme()
	result.default_font_size = 14
	result.set_color("font_color", "Label", TEXT)
	var fills := {"normal": BUTTON_FILL, "disabled": BUTTON_OFF}
	for state in BUTTON_STATES + ["disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = fills.get(state, BUTTON_LIT)
		box.border_color = ACCENT if state == "focus" else BUTTON_EDGE
		box.set_border_width_all(1)
		box.set_corner_radius_all(3)
		box.set_content_margin_all(10)
		result.set_stylebox(state, "Button", box)
	result.set_color("font_color", "Button", TEXT)
	result.set_color("font_hover_color", "Button", Color.WHITE)
	result.set_color("font_disabled_color", "Button", DIM)
	return result

func label(parent: Node, text: String, size: int = 14, colour: Color = TEXT) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", colour)
	parent.add_child(node)
	return node

func paragraph(parent: Node, text: String, colour: Color = MUTED) -> Label:
	var node := label(parent, text, 13, colour)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node

func button(parent: Node, text: String, action: Callable, primary: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(action)
	parent.add_child(node)
	if primary:
		for state in BUTTON_STATES:
			var box: StyleBoxFlat = theme.get_stylebox(state, "Button").duplicate()
			box.bg_color = ACCENT.lightened(0.15) if state == "hover" else ACCENT
			box.border_color = ACCENT
			node.add_theme_stylebox_override(state, box)
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			node.add_theme_color_override(key, INK)
	return node

## Gives a button an accent border in the listed states.
func outline(node: Button, states: Array, width: int = 1) -> void:
	for state in states:
		var box: StyleBoxFlat = theme.get_stylebox(state, "Button").duplicate()
		box.border_color = ACCENT
		box.set_border_width_all(width)
		node.add_theme_stylebox_override(state, box)

## A rounded panel; returns its content column.
func panel(parent: Node, colour: Color = PANEL, expand: bool = false, min_width: float = 0.0) -> VBoxContainer:
	var shell := PanelContainer.new()
	var box := StyleBoxFlat.new()
	box.bg_color = colour
	box.set_content_margin_all(17)
	box.set_corner_radius_all(4)
	shell.add_theme_stylebox_override("panel", box)
	if expand: shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.custom_minimum_size.x = min_width
	parent.add_child(shell)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	shell.add_child(content)
	return content

func scroll_stack(parent: Node) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 10)
	scroll.add_child(stack)
	return stack

func clear(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func part_icon(uid: String) -> EquipmentSlot:
	var icon := EquipmentSlot.new()
	icon.part = store.owned_part(uid)
	icon.slot_id = selected_slot
	icon.condition = store.integrity(uid, draft)
	icon.customised = draft.part_finishes.has(uid)
	return icon

# --- Layout, built once in screen order ---

func build() -> void:
	var background := ColorRect.new()
	background.color = INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	margin.add_child(page)
	build_header(page)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	build_bay(body)
	build_sidebar(body)
	footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	panel(page, FOOTER).add_child(footer)
	build_picker()
	build_exit_dialog()

func build_header(page: Node) -> void:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	page.add_child(top)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	title_caption = label(titles, "", 12, ACCENT)
	label(titles, base.display_name, 28)
	frame_choice = OptionButton.new()
	frame_choice.name = "FrameChoice"
	for id in WORKSHOP_FRAMES: frame_choice.add_item(catalogue.frames[id].display_name)
	frame_choice.select(WORKSHOP_FRAMES.find(store.frame_id))
	frame_choice.item_selected.connect(select_frame)
	top.add_child(frame_choice)
	credits_label = label(top, "", 20, ACCENT)
	button(top, "Battle demo", request_exit.bind("demo"))
	button(top, "Main menu", request_exit.bind("menu"))

## Inspection controls, the model flanked by slot icons, then playback and tools.
func build_bay(body: Node) -> void:
	var character := panel(body, BAY, true)
	var heading := HBoxContainer.new()
	character.add_child(heading)
	var lineage: String = store.manufacturer_name(base.manufacturer) + "  /  " + SizeClass.NAMES[base.size_class]
	label(heading, lineage.to_upper(), 11, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fit_status = label(heading, "", 11, GREEN)
	build_inspection_bar(character)
	var bay := HBoxContainer.new()
	bay.add_theme_constant_override("separation", 18)
	bay.size_flags_vertical = Control.SIZE_EXPAND_FILL
	character.add_child(bay)
	build_slot_column(bay, LEFT_SLOTS, false)
	build_model_view(bay)
	build_slot_column(bay, RIGHT_SLOTS, true)
	build_view_bar(character)

func build_inspection_bar(parent: Node) -> void:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	parent.add_child(bar)
	for pair in INSPECTION_MODES:
		var mode: String = pair[0]
		var choice := button(bar, pair[1], set_inspection.bind(mode))
		choice.name = "View_" + mode
		choice.toggle_mode = true
		choice.add_theme_color_override("font_pressed_color", ACCENT)
		outline(choice, ["pressed"])
		inspection_buttons[mode] = choice
	var views := HBoxContainer.new()
	bar.add_child(views)
	button(views, "Front", set_camera_angle.bind(0.0))
	button(views, "Rear", set_camera_angle.bind(PI))
	button(views, "3/4", set_camera_angle.bind(-0.6))

func build_slot_column(parent: Node, ids: Array, right: bool) -> void:
	var column := VBoxContainer.new()
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	column.add_theme_constant_override("separation", 10)
	parent.add_child(column)
	for slot in ids:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		column.add_child(row)
		var icon := EquipmentSlot.new()
		icon.icon_size = 56
		icon.name = "Slot_" + String(slot).replace(".", "_")
		icon.slot_id = slot
		icon.pressed.connect(open_slot.bind(slot))
		row.add_child(icon)
		slot_buttons[slot] = icon
		var caption := VBoxContainer.new()
		caption.custom_minimum_size.x = 62
		caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(caption)
		var region := label(caption, String(slot).get_slice(".", 0).replace("_", " ").to_upper(), 10, MUTED)
		var title := label(caption, short_slot(slot), 12)
		var condition := label(caption, "", 10, MUTED)
		slot_condition_labels[slot] = condition
		if right:
			row.move_child(caption, 0)
			for entry in [region, title, condition]:
				entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func build_model_view(bay: Node) -> void:
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bay.add_child(stack)
	preview = WorkshopPreview.new()
	preview.frame_id = store.frame_id
	if store.frame_id == "hx7_kestrel": preview.zoom = 2.25
	preview.highlight_selection = false
	preview.region_selected.connect(select_region)
	preview.custom_minimum_size = Vector2(240, 260)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(preview)
	bay_caption = label(stack, "Drag to rotate  /  Scroll to zoom", 11, MUTED)
	bay_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func build_view_bar(parent: Node) -> void:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	parent.add_child(bar)
	animation_choice = OptionButton.new()
	animation_choice.name = "AnimationChoice"
	animation_choice.tooltip_text = "Animation preview"
	for clip in animation_menu():
		animation_choice.add_item(clip[1])
	bar.add_child(animation_choice)
	var playback := HBoxContainer.new()
	bar.add_child(playback)
	button(playback, "Play", play_animation)
	button(playback, "Pause", toggle_pause)
	button(playback, "Rest", preview.play_preview.bind("rest"))
	var tools := HBoxContainer.new()
	tools.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(tools)
	tool_buttons.paint = button(tools, "Paint", open_picker.bind("paint"))
	tool_buttons.weapons = button(tools, "Weapons" if store.frame_id == "hx7_kestrel" else "Weapon kits", open_picker.bind("weapons"))
	for entry in tool_buttons.values():
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func build_sidebar(body: Node) -> void:
	var sidebar := panel(body, PANEL, false, 378)
	label(sidebar, "FRAME + PILOT", 12, ACCENT)
	stats_column = scroll_stack(sidebar)
	stats_column.add_theme_constant_override("separation", 3)

func build_picker() -> void:
	picker = PopupPanel.new()
	picker.name = "EquipmentPicker"
	picker.transparent_bg = true
	var box := StyleBoxFlat.new()
	box.bg_color = PANEL
	box.border_color = POPUP_EDGE
	box.set_border_width_all(1)
	box.set_content_margin_all(18)
	box.set_corner_radius_all(5)
	picker.add_theme_stylebox_override("panel", box)
	add_child(picker)
	picker_scroll = ScrollContainer.new()
	picker_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	picker.add_child(picker_scroll)
	picker_content = VBoxContainer.new()
	picker_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker_content.add_theme_constant_override("separation", 12)
	picker_scroll.add_child(picker_content)
	picker.about_to_popup.connect(mark_picker_slot.bind(true))
	picker.popup_hide.connect(mark_picker_slot.bind(false))

func build_exit_dialog() -> void:
	exit_dialog = ConfirmationDialog.new()
	exit_dialog.title = "Unapplied changes"
	exit_dialog.ok_button_text = "Discard & continue"
	exit_dialog.confirmed.connect(leave)
	add_child(exit_dialog)

# --- Refresh: redraws everything that depends on the draft ---

func refresh() -> void:
	var pilot: Dictionary = store.pilots.entries[draft.pilot]
	var pending := store.changed(draft)
	frame_choice.disabled = pending
	frame_choice.tooltip_text = "Apply or discard changes before switching frames." if pending else "Choose a workshop frame"
	pilot_stats = pilot.stats
	title_caption.text = "WORKSHOP  /  " + pilot.callsign
	credits_label.text = "%s CR" % int(store.owned.credits)
	fit_status.text = "UNAPPLIED REFIT" if pending else "INSTALLED FIT"
	fit_status.add_theme_color_override("font_color", ACCENT if pending else GREEN)
	for slot in slot_buttons:
		refresh_slot(slot)
	# The recovery module replaces the Hornet pod's geometry. The selected region
	# is passed so isolated and exploded inspection keep it in view.
	var show_recovery: bool = store.frame_id == "m9_teamster" and store.part_for("backpack.module", draft).get("weapon", "") != "hornet_pod"
	preview.show_fit(WorkshopAppearance.finish_by_id(draft.finish), selected_region, show_recovery, store.fit_parts(draft), store.fit_finishes(draft))
	sync_inspection_buttons()
	clear(picker_content)
	match picker_mode:
		"parts": build_parts()
		"paint": build_paint()
		"weapons": build_weapons()
	build_stats()
	build_footer()

func refresh_slot(slot: String) -> void:
	var icon: EquipmentSlot = slot_buttons[slot]
	var uid: String = draft.installed[slot]
	icon.part = store.part_for(slot, draft)
	icon.condition = store.integrity(uid, draft)
	icon.customised = draft.part_finishes.has(uid)
	icon.set_process(icon.customised)
	icon.pending = store.slot_changed(slot, draft)
	icon.active = picker_mode == "parts" and slot == selected_slot and picker.visible
	var rarity: String = icon.part.get("rarity", "standard").capitalize()
	var finish := "Customised" if icon.customised else "Factory finish"
	icon.tooltip_text = "%s\n%s · %s · %d%%\n%s" % [icon.part.name, rarity, finish, icon.condition, short_slot(slot)]
	icon.queue_redraw()
	var condition: Label = slot_condition_labels[slot]
	condition.text = "%d%%" % icon.condition
	condition.add_theme_color_override("font_color", RED if is_worn(icon.condition) else MUTED)

func sync_inspection_buttons() -> void:
	for mode in inspection_buttons:
		inspection_buttons[mode].set_pressed_no_signal(mode == preview.inspection_mode)

## Outlines the slot whose parts the picker shows, while it is open.
func mark_picker_slot(open: bool) -> void:
	for slot in slot_buttons:
		var icon: EquipmentSlot = slot_buttons[slot]
		icon.active = open and picker_mode == "parts" and slot == selected_slot
		icon.queue_redraw()

# --- Picker: parts ---

func open_slot(slot: String) -> void:
	selected_slot = slot
	selected_region = slot.get_slice(".", 0)
	inspected_uid = draft.installed[slot]
	open_picker("parts")

func select_region(id: String) -> void:
	for region in store.regions:
		if region.id == id:
			open_slot(region.slots[0].id)
			return

func open_picker(mode: String) -> void:
	picker_mode = mode
	refresh()
	picker_scroll.scroll_vertical = 0
	var viewport := get_viewport_rect().size
	var extent := Vector2i(470, mini(680, int(viewport.y) - 100))
	var origin := Vector2i((viewport - Vector2(extent)) / 2)
	if mode == "parts":
		# Open beside the slot icon, on the side facing the model.
		var rect := (slot_buttons[selected_slot] as Control).get_global_rect()
		origin.x = int(rect.end.x + 14) if selected_slot in LEFT_SLOTS else int(rect.position.x - extent.x - 14)
		origin.y = clampi(int(rect.position.y - 40), 65, int(viewport.y) - extent.y - 30)
	picker.popup(Rect2i(origin, extent))

func popup_heading(title: String) -> void:
	var row := HBoxContainer.new()
	picker_content.add_child(row)
	label(row, title, 22).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button(row, "×", picker.hide).tooltip_text = "Close · Esc"

func build_parts() -> void:
	popup_heading(selected_region.replace("_", " ").capitalize() + " / " + short_slot(selected_slot))
	var equipped_uid: String = draft.installed[selected_slot]
	var title := HBoxContainer.new()
	picker_content.add_child(title)
	label(title, "EQUIPMENT · %d CR FITTING" % WorkshopState.LABOUR, 11, ACCENT).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var toggle := CheckButton.new()
	toggle.text = "All parts"
	toggle.tooltip_text = "Include incompatible parts"
	toggle.button_pressed = show_incompatible
	toggle.toggled.connect(set_show_incompatible)
	title.add_child(toggle)
	var candidates := part_candidates(equipped_uid)
	if inspected_uid not in candidates:
		inspected_uid = equipped_uid
	build_candidate_grid(candidates, equipped_uid)
	var inspecting_equipped := inspected_uid == equipped_uid
	label(picker_content, "EQUIPPED" if inspecting_equipped else "ALTERNATIVE", 11, MUTED)
	var card := equipment_card(picker_content, inspected_uid, inspecting_equipped)
	card.tooltip_text = store.owned_part(inspected_uid).description
	if inspecting_equipped:
		build_finish_row(equipped_uid)
		if candidates.size() == 1:
			label(picker_content, "No spares available", 13, MUTED)
	else:
		build_swap_preview(card, inspected_uid)

## The equipped part, then each spare of the slot's family that fits (or every spare when showing incompatible parts).
func part_candidates(equipped_uid: String) -> Array:
	var candidates: Array = [equipped_uid]
	var installed: Array = draft.installed.values()
	for uid in store.owned.inventory:
		if uid in installed: continue
		if store.owned_part(uid).family != store.slots[selected_slot].family: continue
		if show_incompatible or store.fit_issue(draft, selected_slot, uid, base).is_empty():
			candidates.append(uid)
	return candidates

func build_candidate_grid(candidates: Array, equipped_uid: String) -> void:
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	picker_content.add_child(grid)
	for uid in candidates:
		var option := part_icon(uid)
		option.active = uid == inspected_uid
		option.tooltip_text = option.part.name + (" · Equipped" if uid == equipped_uid else " · Spare")
		option.name = "Inspect_" + uid
		option.pressed.connect(inspect_part.bind(uid))
		grid.add_child(option)

func equipment_card(parent: Node, uid: String, installed: bool) -> VBoxContainer:
	var part := store.owned_part(uid)
	var card := panel(parent, CARD)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)
	var icon := part_icon(uid)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(titles)
	paragraph(titles, part.name, TEXT).add_theme_font_size_override("font_size", 16)
	var rarity: String = part.get("rarity", "standard").capitalize()
	label(titles, rarity + (" · Customised" if icon.customised else ""), 11, icon.rarity_colour())
	var maker := String(part.manufacturer).replace("_", " ").to_upper()
	label(titles, "%s  /  %s" % [maker, SizeClass.NAMES[part.size_class]], 11, MUTED).tooltip_text = store.manufacturer_name(part.manufacturer)
	var stats := HBoxContainer.new()
	card.add_child(stats)
	var worn := is_worn(icon.condition)
	label(stats, "%d%% condition" % icon.condition, 12, RED if worn else TEXT).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label(stats, "%s Energy reserved" % str(part.energy_reservation), 12, ACCENT if part.energy_reservation > 0 else MUTED)
	paragraph(card, effects_text(part.bonuses), TEXT)
	if worn:
		paragraph(card, "Wear: " + effects_text(part.wear), RED)
	var weapon_id := store.weapon_for(part, selected_slot)
	if not weapon_id.is_empty():
		var weapon: WeaponData = catalogue.weapons[weapon_id]
		paragraph(card, weapon.display_name + "\n" + weapon_summary(weapon), GREEN)
	if installed:
		var queued: bool = uid in draft.repairs
		var repair := button(card, "Undo repair" if queued else "Repair · %d CR" % store.repair_cost(uid), toggle_repair.bind(uid))
		repair.disabled = icon.condition == 100 and not queued
	return card

## Stat changes and the Equip button for a spare under inspection.
func build_swap_preview(card: Node, uid: String) -> void:
	var trial := store.with_part(draft, selected_slot, uid)
	var issue := store.fit_issue(draft, selected_slot, uid, base)
	if issue.is_empty():
		paragraph(card, comparison(store.resolve(base, draft), store.resolve(base, trial)), ACCENT)
		var dependency := store.dependency_issue(trial)
		if not dependency.is_empty():
			paragraph(card, dependency, RED)
	else:
		paragraph(card, issue, RED)
	var equip := button(card, "Equip", replace_part.bind(uid))
	equip.name = "Equip_" + uid
	equip.disabled = not issue.is_empty()

func build_finish_row(uid: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	picker_content.add_child(row)
	label(row, "Finish", 12, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button(row, "Factory", set_part_finish.bind(uid, "")).tooltip_text = "Use frame finish; remove customisation"
	for finish in store.finishes:
		var swatch := button(row, "", set_part_finish.bind(uid, finish.id))
		swatch.custom_minimum_size = Vector2(30, 30)
		swatch.tooltip_text = finish.name + " · Customise this component"
		var chosen: bool = draft.part_finishes.get(uid) == finish.id
		var box := StyleBoxFlat.new()
		box.bg_color = Color(finish.primary)
		box.border_color = ACCENT if chosen else Color(finish.marking)
		box.set_border_width_all(2)
		box.set_corner_radius_all(3)
		for state in BUTTON_STATES:
			swatch.add_theme_stylebox_override(state, box)

# --- Picker: paint and weapons ---

func build_paint() -> void:
	popup_heading("Paint & markings")
	label(picker_content, "FRAME FINISH · FREE", 11, MUTED)
	for finish in store.finishes:
		var row := HBoxContainer.new()
		picker_content.add_child(row)
		for key in ["primary", "secondary", "marking"]:
			var swatch := ColorRect.new()
			swatch.color = Color(finish[key])
			swatch.custom_minimum_size = Vector2(30, 30)
			row.add_child(swatch)
		var title: String = finish.name + (" ✓" if finish.id == draft.finish else "")
		button(row, title, set_finish.bind(finish.id)).size_flags_horizontal = Control.SIZE_EXPAND_FILL

func build_weapons() -> void:
	popup_heading("Weapon kits")
	if store.frame_id == "m9_teamster": button(picker_content, "Preview two-handed rifle kit", preview_marksman_kit)
	for weapon_id in store.weapon_ids(draft):
		var weapon: WeaponData = catalogue.weapons[weapon_id]
		var card := panel(picker_content, CARD)
		paragraph(card, weapon.display_name, TEXT)
		paragraph(card, weapon_summary(weapon), GREEN)
	var dependency := store.dependency_issue(draft)
	if not dependency.is_empty():
		paragraph(picker_content, dependency, RED)

# --- Sidebar stats ---

func build_stats() -> void:
	clear(stats_column)
	var installed_fit := store.resolve(base, store.draft())
	var proposed := store.resolve(base, draft)
	var saved_pilot: Dictionary = store.pilots.entries[store.owned.get("pilot", WorkshopState.DEFAULT_PILOT)]
	label(stats_column, store.pilots.entries[draft.pilot].callsign + " / " + base.display_name.to_upper(), 11, MUTED)
	build_frame_summary(proposed)
	stats_column.add_child(HSeparator.new())
	build_stat_table(proposed, installed_fit, saved_pilot.stats)
	stats_column.add_child(HSeparator.new())
	build_weapon_list(proposed)

func stat_row(title: String, value: String, key: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	stats_column.add_child(row)
	label(row, title, 11, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var number := label(row, value, 12)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	number.name = "Stat_" + key
	return row

func build_frame_summary(frame: FrameData) -> void:
	stat_row("Hull", "%d / %d" % [store.hull(base, draft), frame.structure], "hull")
	stat_row("Armour", number_text(frame.armour), "armour")
	stat_row("Move", number_text(frame.base_move), "move")
	var energy := "%s / %s plant" % [number_text(frame.energy_available()), number_text(frame.energy_capacity)]
	stat_row("Energy available", energy, "energy").tooltip_text = "%s Energy reserved by installed components." % number_text(frame.energy_reserved)
	stat_row("Recharge", "+" + number_text(frame.energy_recharge), "recharge")
	var title := "Undo hull repair" if draft.repair_hull else "Repair hull · %d CR" % store.hull_repair_cost()
	var repair := button(stats_column, title, toggle_hull_repair)
	repair.name = "RepairHull"
	repair.add_theme_font_size_override("font_size", 11)
	repair.disabled = int(store.owned.hull_damage) == 0

## Frame, pilot, total and threshold per stat. Totals that differ from the saved fit are highlighted.
func build_stat_table(proposed: FrameData, installed_fit: FrameData, saved_stats: Dictionary) -> void:
	var table := GridContainer.new()
	table.name = "StatsTable"
	table.columns = TABLE_COLUMNS.size()
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table.add_theme_constant_override("h_separation", 8)
	table.add_theme_constant_override("v_separation", 7)
	stats_column.add_child(table)
	for column in TABLE_COLUMNS:
		var caption := label(table, column[0], 10, MUTED)
		caption.tooltip_text = column[1]
		if column[0] == "STAT":
			caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for key in UnitState.STAT_NAMES:
		var frame_value: float = float(proposed.stat_bonuses.get(key, 0)) + float(proposed.stat_fractions.get(key, 0))
		var pilot_value: float = pilot_stats.get(key, 0)
		var total := resolved_stat(proposed, key)
		var threshold := UnitState.stat_cap(key, proposed)
		var total_changed := total != resolved_stat(installed_fit, key, saved_stats)
		var title := label(table, stat_name(key), 11, MUTED)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.tooltip_text = stat_note(key)
		var tooltip := "%s frame + %s pilot → %s total (max %s)." % [number_text(frame_value), number_text(pilot_value), number_text(total), number_text(threshold)]
		table_cell(table, "Frame_" + key, frame_value, MUTED, tooltip)
		table_cell(table, "Pilot_" + key, pilot_value, MUTED, tooltip)
		table_cell(table, "Stat_" + key, total, ACCENT if total_changed else TEXT, tooltip)
		table_cell(table, "Threshold_" + key, threshold, MUTED, tooltip)

func table_cell(table: Node, node_name: String, value: float, colour: Color, tooltip: String) -> void:
	var number := label(table, number_text(value), 12, colour)
	number.name = node_name
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	number.tooltip_text = tooltip

func stat_note(key: String) -> String:
	if key in UnitState.RESERVED_STATS:
		return "Reserved stat; no combat rule yet."
	if key == "spirit":
		return "Will is whole Spirit."
	return ""

func build_weapon_list(frame: FrameData) -> void:
	label(stats_column, "EQUIPPED WEAPONS", 11, ACCENT)
	var weapons := store.weapon_ids(draft)
	if not frame.default_melee.is_empty():
		weapons.append(frame.default_melee)
	for id in weapons:
		var weapon: WeaponData = catalogue.weapons[id]
		var stack := VBoxContainer.new()
		stack.name = "Weapon_" + id
		stack.add_theme_constant_override("separation", 1)
		stats_column.add_child(stack)
		paragraph(stack, weapon.display_name, TEXT).add_theme_font_size_override("font_size", 12)
		paragraph(stack, weapon_summary(weapon), MUTED).add_theme_font_size_override("font_size", 10)
		var role := ""
		if weapon.heavy: role = " · Heavy"
		elif weapon.melee: role = " · Melee"
		stack.tooltip_text = "%s%s · Arc %s° · Aim %s%%" % [weapon.damage_type.capitalize(), role, number_text(weapon.arc), number_text(weapon.aim_bonus * 100)]

# --- Footer ---

func build_footer() -> void:
	clear(footer)
	build_pilot_bar()
	var pending := store.changed(draft)
	var issue := store.validate(draft)
	var warning := store.readiness(base, draft)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(info)
	label(info, footer_title(pending, warning), 14, ACCENT if pending else TEXT)
	var status := footer_status(issue, warning)
	var note := paragraph(info, status, MUTED if issue.is_empty() else RED)
	note.visible = not status.is_empty()
	label(footer, "%d CR" % store.cost(draft), 21, ACCENT).vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	button(footer, "Repair all", repair_all)
	button(footer, "Discard", discard_draft).disabled = not pending
	var can_save: bool = workshop_session.save_available
	button(footer, "Apply refit", apply_refit, true).disabled = not pending or not issue.is_empty() or not can_save
	var deploy_button := button(footer, "Deploy →", deploy)
	deploy_button.disabled = pending or not warning.is_empty() or not can_save
	deploy_button.tooltip_text = "Apply or discard pending changes first." if pending else warning

func footer_title(pending: bool, warning: String) -> String:
	if pending:
		return "Pending refit"
	return "Ready to deploy" if warning.is_empty() else "Service required"

## The most urgent note: a validation issue, then the latest message, then a readiness warning.
func footer_status(issue: String, warning: String) -> String:
	for text: String in [issue, message, warning]:
		if not text.is_empty():
			return text
	return ""

func build_pilot_bar() -> void:
	pilot_bar = HBoxContainer.new()
	pilot_bar.name = "PilotBar"
	pilot_bar.add_theme_constant_override("separation", 6)
	footer.add_child(pilot_bar)
	for id in store.pilots.entries:
		var entry: Dictionary = store.pilots.entries[id]
		var choice := button(pilot_bar, entry.callsign + "\n" + entry.role, select_pilot.bind(id))
		choice.name = "Pilot_" + id
		choice.custom_minimum_size = Vector2(130, 68)
		choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice.add_theme_font_size_override("font_size", 11)
		choice.expand_icon = true
		choice.add_theme_constant_override("icon_max_width", 52)
		if ResourceLoader.exists(entry.portrait):
			choice.icon = load(entry.portrait)
		choice.tooltip_text = entry.display_name + " · " + entry.role + "\n" + effects_text(entry.stats) + "\nClick to assign; Apply refit to save."
		if draft.pilot == id:
			outline(choice, BUTTON_STATES, 2)
			choice.add_theme_color_override("font_color", ACCENT)

# --- Draft edits ---

## Sets the footer message and redraws.
func show_message(text: String) -> void:
	message = text
	refresh()

func inspect_part(uid: String) -> void:
	inspected_uid = uid
	refresh()

func set_show_incompatible(value: bool) -> void:
	show_incompatible = value
	refresh()

func replace_part(uid: String) -> void:
	draft.installed[selected_slot] = uid
	picker.hide()
	show_message("Part equipped in draft.")

func set_finish(id: String) -> void:
	draft.finish = id
	refresh()

func set_part_finish(uid: String, finish: String) -> void:
	if finish.is_empty():
		draft.part_finishes.erase(uid)
	else:
		draft.part_finishes[uid] = finish
	show_message("")

func toggle_repair(uid: String) -> void:
	if uid in draft.repairs:
		draft.repairs.erase(uid)
	else:
		draft.repairs.append(uid)
	show_message("")

func toggle_hull_repair() -> void:
	draft.repair_hull = not draft.repair_hull
	refresh()

func repair_all() -> void:
	draft.repair_hull = int(store.owned.hull_damage) > 0
	for uid in draft.installed.values():
		if int(store.owned.inventory[uid].integrity) < 100 and uid not in draft.repairs:
			draft.repairs.append(uid)
	show_message("Repairs queued.")

func preview_marksman_kit() -> void:
	var trial := draft.duplicate(true)
	for slot in RIFLE_KIT:
		var part_id: String = RIFLE_KIT[slot]
		if store.part_for(slot, trial).id == part_id: continue
		var uid := store.spare_of(part_id, trial)
		if uid.is_empty():
			show_message("The required marksman or support component is not available in stores.")
			return
		trial.installed[slot] = uid
	draft = trial
	show_message("Rifle kit equipped in draft.")

func select_pilot(id: String) -> void:
	if not store.pilots.entries.has(id): return
	draft.pilot = id
	show_message("")

func discard_draft() -> void:
	draft = store.draft()
	show_message("")

func apply_refit() -> void:
	if store.apply(draft):
		draft = store.draft()
		show_message("Refit saved.")
	else:
		show_message(store.error)

# --- Preview controls ---

func set_inspection(mode: String) -> void:
	preview.set_inspection(mode)
	sync_inspection_buttons()

func set_camera_angle(angle: float) -> void:
	preview.angle = angle
	preview.update_camera()

func toggle_pause() -> void:
	if preview.animator != null:
		preview.animator.set_paused(not preview.animator.paused)

func play_animation() -> void:
	var clip: String = animation_menu()[animation_choice.selected][0]
	var two_handed := TeamsterParts.two_handed(store.fit_parts(draft))
	if clip.begins_with("twohand_") and not two_handed:
		show_message("Fit the two-handed rifle kit first.")
		return
	var required := preview.animator.weapon_for_animation(clip)
	# With the rifle kit fitted, the BR-90 stands in for the stock rifle.
	if clip == "fire_rifle" and two_handed:
		required = "br90_rifle"
	if not required.is_empty() and required not in store.weapon_ids(draft):
		show_message("Fit the matching weapon to preview this animation.")
		return
	set_inspection("assembled")
	message = ""
	build_footer()
	preview.play_preview(clip)

func animation_menu() -> Array:
	return KestrelAnimator.MENU if store.frame_id == "hx7_kestrel" else CLIPS

# --- Text formatting ---

func short_slot(slot: String) -> String:
	if store.frame_id == "hx7_kestrel":
		if slot == "left_arm.actuator": return "Actuator"
		if slot == "right_arm.actuator": return "Rifle arm"
		if slot == "right_arm.armour": return "Knife shell"
		if slot == "backpack.module": return "Wing stores"
	if SLOT_TITLES.has(slot):
		return SLOT_TITLES[slot]
	match slot.get_slice(".", 1):
		"actuator": return "Weapon arm"
		"drive": return "Drive"
	return "Armour"

func stat_name(key: String) -> String:
	return STAT_LABELS.get(key, key.capitalize())

func effects_text(effects: Dictionary) -> String:
	if effects.is_empty():
		return "Standard fit"
	var text: PackedStringArray = []
	for key in effects:
		text.append(("+" if effects[key] > 0 else "") + "%s %s" % [effects[key], stat_name(key)])
	return " · ".join(text)

func weapon_summary(weapon: WeaponData) -> String:
	return "%d × %d DMG · AP %d · RNG %s–%s · %d EN" % [weapon.shots, weapon.damage, weapon.armour_piercing, number_text(weapon.range_min), number_text(weapon.range_max), weapon.energy_cost]

func comparison(before: FrameData, after: FrameData) -> String:
	var changes: PackedStringArray = []
	for key in WorkshopState.FRAME_STATS:
		if before.get(key) != after.get(key):
			changes.append("%s %s → %s" % [stat_name(key), before.get(key), after.get(key)])
	for key in UnitState.STAT_NAMES:
		var old_value := resolved_stat(before, key)
		var new_value := resolved_stat(after, key)
		if old_value != new_value:
			changes.append("%s %s → %s" % [stat_name(key), old_value, new_value])
	if before.energy_available() != after.energy_available():
		changes.append("Available Energy %s → %s" % [before.energy_available(), after.energy_available()])
	return " · ".join(changes) if not changes.is_empty() else "No combat stat change"

func number_text(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, roundf(value)) else str(value)

## Frame + pilot for one stat, resolved exactly as UnitState.stat() does in battle.
func resolved_stat(frame: FrameData, key: String, stats: Dictionary = {}) -> float:
	if stats.is_empty(): stats = pilot_stats
	return UnitState.resolve_stat(key, float(stats.get(key, 0)), float(frame.stat_bonuses.get(key, 0)), float(frame.stat_fractions.get(key, 0)), frame)

func is_worn(condition: int) -> bool:
	return condition < WorkshopState.WORN_BELOW

# --- Navigation ---

func select_frame(index: int) -> void:
	if store.changed(draft): return
	workshop_session.select_frame(WORKSHOP_FRAMES[index])
	store = workshop_session.store
	draft = store.draft()
	base = store.workshop_frame
	selected_region = "torso"
	selected_slot = "torso.armour"
	picker_mode = "parts"
	message = workshop_session.notice
	workshop_session.notice = ""
	clear(self)
	inspection_buttons.clear()
	slot_buttons.clear()
	slot_condition_labels.clear()
	tool_buttons.clear()
	build()
	refresh()

func deploy() -> void:
	if store.changed(draft) or not store.readiness(base, draft).is_empty():
		return
	# Persist the initial standard fit even if no refit was needed.
	if not store.apply(draft):
		show_message(store.error)
		return
	workshop_session.deploy()

func request_exit(destination: String) -> void:
	pending_exit = destination
	if store.changed(draft):
		exit_dialog.dialog_text = "Discard the pending refit and %s?" % EXITS[destination].prompt
		exit_dialog.popup_centered()
	else:
		leave()

func leave() -> void:
	if not EXITS.has(pending_exit): return
	workshop_session.active = false
	get_tree().change_scene_to_file(EXITS[pending_exit].scene)
