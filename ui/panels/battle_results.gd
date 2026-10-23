class_name BattleResults
extends BattleUISection

var workshop_session: WorkshopRuntime:
	get:
		return get_node("/root/WorkshopSession") as WorkshopRuntime

var victory_panel: PanelContainer

func show_victory() -> void:
	if is_instance_valid(victory_panel):
		return
	victory_panel = panel(root, Color("0c1928f8"))
	victory_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	victory_panel.offset_left = -235
	victory_panel.offset_right = 235
	victory_panel.offset_top = -95
	victory_panel.offset_bottom = 95
	var stack := VBoxContainer.new()
	victory_panel.add_child(stack)
	var winner: int = controller.manager.battle.winner()
	label(stack, "AIRSPACE SECURED" if winner == 0 else ("DETACHMENT LOST" if winner == 1 else "MUTUAL DESTRUCTION"), 25, BLUE if winner == 0 else RED)
	label(stack, "Battle concluded in round %d." % controller.manager.battle.round_number, 15, MUTED)
	if workshop_session.active:
		primary(button(stack, "RETURN TO WORKSHOP", controller.return_to_workshop))
	else:
		primary(button(stack, "START ANOTHER SKIRMISH", func() -> void: controller.restart()))
		button(stack, "OPEN WORKSHOP", controller.return_to_workshop)
	# Let the final shot and destruction play before the result covers the field.
	victory_panel.modulate.a = 0.0
	create_tween().tween_property(victory_panel, "modulate:a", 1.0, 0.35).set_delay(1.3)
