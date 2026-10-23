class_name ActionCommands
extends BattleUISection

func build() -> void:
	var manager: TurnManager = controller.manager
	if manager.active == null:
		return
	label(ui.commands.command, "ACTION / " + manager.active.loadout.callsign, 16, BLUE)
	if manager.active.loadout.faction == 1:
		label(ui.commands.command, "Enemy choosing an action…", 14, MUTED)
		return
	var foes := MeleeRules.foes(manager.battle, manager.active)
	if not foes.is_empty():
		melee_choice(manager, foes)
	var has_power := "newtype" in manager.active.loadout.pilot.abilities
	label(ui.commands.command, "Optional: lock on to one enemy so your next shot at it rerolls one miss." + (" Newtype Reflexes can also turn this unit." if has_power else ""), 13, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var row := HBoxContainer.new()
	ui.commands.command.add_child(row)
	var targets := OptionButton.new()
	row.add_child(targets)
	# Only offer locks that can succeed; the skip rule guarantees there is a choice here.
	var enemies := CombatRules.lockable_targets(manager.battle, manager.active)
	for enemy in enemies:
		targets.add_item(enemy.loadout.callsign)
	if enemies.is_empty():
		targets.add_item("No enemy close enough to lock (8)")
		targets.disabled = true
	var lock_button := primary(button(row, "LOCK ON", func() -> void:
		if targets.selected >= 0:
			var target := enemies[targets.selected]
			if not manager.lock_target(target):
				manager.log_message(CombatRules.lock_error(manager.battle, manager.active, target))
				ui.refresh(), manager.active.action_used or enemies.is_empty()))
	primary(button(row, "END ACTION  →", func() -> void: manager.end_action()), lock_button.disabled)
	if "newtype" in manager.active.loadout.pilot.abilities:
		var powers := HBoxContainer.new()
		ui.commands.command.add_child(powers)
		label(powers, "Newtype Reflexes · turn extra (1 Will)", 12, GOLD)
		button(powers, "↶ −15°", func() -> void: manager.rotate_ability(-15))
		button(powers, "+15° ↷", func() -> void: manager.rotate_ability(15))
		label(powers, "%+.0f° of ±45°" % manager.active.ability_rotation, 12, MUTED)

## Engaged units choose here between trading blows (do nothing) and breaking off.
func melee_choice(manager: TurnManager, foes: Array[UnitState]) -> void:
	var names := ", ".join(PackedStringArray(foes.map(func(foe: UnitState) -> String: return foe.loadout.callsign)))
	label(ui.commands.command, "ENGAGED / Locked in melee with " + names, 14, GOLD)
	var error := MeleeRules.break_off_error(manager.battle, manager.active)
	var expected := MeleeRules.parting_damage(manager.battle, manager.active)
	var detail := "Stay to trade blows in the Attack phase (only %s can be targeted), or break off: back away %.1f, then fire freely. Breaking off uses this action, and each foe takes its attack at you now as a parting strike, +%d%% to hit (≈%.1f damage)." % [names, MeleeRules.BREAK_OFF_DISTANCE, int(MeleeRules.PARTING_BONUS), expected]
	label(ui.commands.command, detail, 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var row := HBoxContainer.new()
	ui.commands.command.add_child(row)
	var button_node := button(row, "BREAK OFF", func() -> void: manager.break_off(), not error.is_empty())
	button_node.tooltip_text = error if not error.is_empty() else "Each foe spends its attack on a parting strike at +20%, then this unit backs away out of reach."
	if not error.is_empty():
		label(row, error, 12, INVALID).size_flags_vertical = Control.SIZE_SHRINK_CENTER
