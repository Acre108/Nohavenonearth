class_name PlanningCommands
extends BattleUISection

func build() -> void:
	var manager: TurnManager = controller.manager
	var unit: UnitState = controller.selected
	var title := HBoxContainer.new()
	ui.commands.command.add_child(title)
	var count := 0
	var total := 0
	for friendly in manager.battle.living(0):
		if MeleeRules.is_engaged(manager.battle, friendly):
			continue
		total += 1
		if friendly.order != null:
			count += 1
	label(title, "PLAN / %d OF %d ORDERS" % [count, total], 16, BLUE).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var threats := CheckBox.new()
	threats.text = "Enemy threat  T"
	threats.tooltip_text = "Shaded sectors: where each enemy can shoot from where it stands.\nDashed ring: the furthest it could hit after moving this round."
	threats.button_pressed = controller.show_threats
	threats.focus_mode = Control.FOCUS_NONE
	threats.toggled.connect(func(_on: bool) -> void: controller.toggle_threats.call_deferred())
	title.add_child(threats)
	ui.commands.commit_button = primary(button(title, "COMMIT ORDERS  →", func() -> void: controller.commit_orders(), not manager.can_commit() or controller.planning.choosing_facing))
	if unit == null or unit.loadout.faction != 0 or not unit.alive():
		label(ui.commands.command, "Select a Blue unit to plot its movement.", 15, MUTED)
		return
	var foes := MeleeRules.foes(manager.battle, unit)
	if not foes.is_empty():
		label(ui.commands.command, "ENGAGED / Locked in melee with " + ", ".join(PackedStringArray(foes.map(func(foe: UnitState) -> String: return foe.loadout.callsign))), 15, GOLD)
		label(ui.commands.command, "No movement this round, and it can only attack the units it is fighting. In the Action phase it can BREAK OFF (each foe takes its attack at it early, at +20%), or stay and trade blows.", 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		return
	var aircraft: bool = controller.planning_aircraft()
	ui.commands.plan_steps(aircraft, controller.planning.charging())
	var controls := HBoxContainer.new()
	ui.commands.command.add_child(controls)
	if not aircraft:
		# Aircraft choose their path on the radial ring instead of a list.
		label(controls, "Manoeuvre", 12, MUTED).size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var move_choice := OptionButton.new()
		move_choice.disabled = controller.planning.choosing_facing
		controls.add_child(move_choice)
		var moves := MovementRules.available(manager.battle, unit)
		for i in moves.size():
			move_choice.add_item(moves[i].display_name + ("  ·  %d Energy" % moves[i].energy_cost if moves[i].energy_cost > 0 else ""))
			move_choice.set_item_tooltip(i, "Costs %d Energy" % moves[i].energy_cost)
			if moves[i].id == controller.planning.manoeuvre_id:
				move_choice.select(i)
		move_choice.item_selected.connect(func(index: int) -> void: controller.choose_manoeuvre(moves[index].id))
	label(controls, "Altitude", 12, MUTED).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var altitude := OptionButton.new()
	altitude.disabled = controller.planning.choosing_facing
	controls.add_child(altitude)
	for i in unit.loadout.frame.altitude_access.size():
		var band: int = unit.loadout.frame.altitude_access[i]
		altitude.add_item(UnitState.ALTITUDES[band])
		if band == controller.planning.plan_altitude:
			altitude.select(i)
	altitude.item_selected.connect(func(index: int) -> void: controller.choose_altitude(unit.loadout.frame.altitude_access[index]))
	ui.commands.confirm_button = button(controls, "LOCK FACING" if controller.planning.choosing_facing else "CONFIRM MOVE", func() -> void: controller.confirm_move())
	# Once every order is in, COMMIT takes over as the primary action.
	if not manager.can_commit():
		ui.commands.confirm_button.theme_type_variation = "PrimaryButton"
	button(controls, "Suggest", func() -> void: controller.suggest_move()).tooltip_text = "Ask the same tactical AI for a legal draft for this unit."
	ui.commands.threat_label = label(ui.commands.command, "", 12, MUTED)
	ui.commands.threat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.commands.feedback = label(ui.commands.command, "", 12, GOLD)
	ui.commands.feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.commands.update_preview()
