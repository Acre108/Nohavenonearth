class_name BattleUI
extends CanvasLayer

const BLUE := ArtPalette.FRIEND
const RED := ArtPalette.HOSTILE
const MUTED := Color("8ca5b9")
const GOLD := ArtPalette.DRAFT
const TARGET := ArtPalette.MARK
const INVALID := ArtPalette.INVALID

var controller: BattleController
var root: Control
var header: BattleHeader
var units_panel: BattleUnitPanels
var flight_radial: FlightRadial
var commands: BattleCommands
var sandbox: BattleDebugPanel
var results: BattleResults
var telemetry: BattleTelemetry

func setup(owner_controller: BattleController) -> void:
	controller = owner_controller
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.theme = BattleTheme.make_theme()
	header = BattleHeader.new()
	header.ui = self
	add_child(header)
	units_panel = BattleUnitPanels.new()
	units_panel.ui = self
	add_child(units_panel)
	flight_radial = FlightRadial.new()
	flight_radial.ui = self
	add_child(flight_radial)
	commands = BattleCommands.new()
	commands.ui = self
	add_child(commands)
	sandbox = BattleDebugPanel.new()
	sandbox.ui = self
	add_child(sandbox)
	results = BattleResults.new()
	results.ui = self
	add_child(results)
	telemetry = BattleTelemetry.new()
	telemetry.ui = self
	add_child(telemetry)
	commands.setup_phases()
	header.build_header()
	build_body()
	build_footer()
	flight_radial.build()
	sandbox.build_debug()
	refresh()

func build_body() -> void:
	var left := BattleUISection.panel(root)
	left.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	left.offset_left = 18
	left.offset_right = 282
	left.offset_top = 146
	left.offset_bottom = -226
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(scroll)
	units_panel.roster = VBoxContainer.new()
	units_panel.roster.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(units_panel.roster)
	var right := BattleUISection.panel(root)
	right.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	right.offset_left = -314
	right.offset_right = -18
	right.offset_top = 146
	right.offset_bottom = -226
	var inspect_scroll := ScrollContainer.new()
	inspect_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(inspect_scroll)
	units_panel.inspector = VBoxContainer.new()
	units_panel.inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspect_scroll.add_child(units_panel.inspector)

func build_footer() -> void:
	var footer := HBoxContainer.new()
	root.add_child(footer)
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 18
	footer.offset_right = -18
	footer.offset_top = -214
	footer.offset_bottom = -16
	var log_panel := BattleUISection.panel(footer)
	log_panel.custom_minimum_size.x = 355
	var logs := VBoxContainer.new()
	log_panel.add_child(logs)
	BattleUISection.label(logs, "COMBAT TELEMETRY", 12, BLUE)
	telemetry.log_text = RichTextLabel.new()
	telemetry.log_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	telemetry.log_text.scroll_following = true
	telemetry.log_text.selection_enabled = true
	telemetry.log_text.add_theme_font_size_override("normal_font_size", 13)
	telemetry.log_text.add_theme_font_size_override("bold_font_size", 13)
	telemetry.log_text.bbcode_enabled = true
	logs.add_child(telemetry.log_text)
	var command_panel := BattleUISection.panel(footer)
	command_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Scroll rather than overflow the fixed footer when a phase has many lines.
	var command_scroll := ScrollContainer.new()
	command_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	command_panel.add_child(command_scroll)
	commands.command = VBoxContainer.new()
	commands.command.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_scroll.add_child(commands.command)

func refresh() -> void:
	if controller == null or controller.manager.battle == null:
		return
	var manager: TurnManager = controller.manager
	header.refresh()
	units_panel.refresh_roster()
	flight_radial.refresh_radial()
	units_panel.refresh_inspector()
	commands.refresh_command()
	telemetry.log_text.text = telemetry.log_bbcode(manager.log_lines)
	if manager.phase == TurnManager.Phase.BATTLE_OVER:
		results.show_victory()
	elif is_instance_valid(results.victory_panel):
		results.victory_panel.queue_free()
		results.victory_panel = null

func refresh_view() -> void:
	header.refresh_view()

func update_preview() -> void:
	commands.update_preview()

func toggle_debug() -> void:
	sandbox.toggle_debug()
