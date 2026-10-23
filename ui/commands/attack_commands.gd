class_name AttackCommands
extends BattleUISection

func build() -> void:
	var manager: TurnManager = controller.manager
	if manager.active == null:
		return
	if manager.active.loadout.faction == 1:
		label(ui.commands.command, "ENEMY FIRE / " + manager.active.loadout.callsign, 16, RED)
		ui.commands.show_dice()
		ui.commands.show_incoming()
		return
	label(ui.commands.command, "ATTACK / " + manager.active.loadout.callsign, 16, BLUE)
	var row := HBoxContainer.new()
	ui.commands.command.add_child(row)
	var weapons := OptionButton.new()
	row.add_child(weapons)
	for weapon in manager.active.loadout.weapons:
		weapons.add_item("%s · %d × %d%s" % [weapon.display_name, weapon.shots, weapon.damage, (" · %d Energy" % weapon.energy_cost) if weapon.energy_cost > 0 else ""])
	weapons.select(controller.weapon_index)
	weapons.item_selected.connect(func(index: int) -> void: controller.choose_weapon(index))
	var targets := OptionButton.new()
	row.add_child(targets)
	var chosen_weapon: WeaponData = controller.current_weapon()
	var legal := CombatRules.legal_targets(manager.battle, manager.active, chosen_weapon)
	var enemies := manager.battle.living(1)
	for i in enemies.size():
		var odds := "  (can't hit)"
		if enemies[i] in legal:
			odds = "  ≈%.1f damage" % CombatRules.forecast(manager.battle, manager.active, enemies[i], chosen_weapon, controller.use_will, controller.use_push).expected
		targets.add_item(enemies[i].loadout.callsign + odds)
		if enemies[i] == controller.target:
			targets.select(i)
	targets.item_selected.connect(func(index: int) -> void: controller.choose_target(enemies[index]))
	var target_error := "No target selected." if controller.target == null else CombatRules.target_error(manager.battle, manager.active, controller.target, chosen_weapon)
	primary(button(row, "FIRE", func() -> void: controller.fire_selected(), not target_error.is_empty()))
	primary(button(row, "HOLD FIRE  →", func() -> void: manager.pass_attack()), not target_error.is_empty())
	if not target_error.is_empty():
		var reason := "CANNOT FIRE / %s" % target_error
		if controller.target != null and legal.is_empty():
			reason += "  No enemy is a legal %s target." % chosen_weapon.display_name
		elif controller.target != null:
			reason += "  Legal: " + ", ".join(PackedStringArray(legal.map(func(unit: UnitState) -> String: return unit.loadout.callsign)))
		label(ui.commands.command, reason, 13, INVALID).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		ui.commands.show_forecast(CombatRules.forecast(manager.battle, manager.active, controller.target, chosen_weapon, controller.use_will, controller.use_push))
	# Rebuilding on toggle keeps the forecast in step with the armed powers.
	if "push" in manager.active.loadout.pilot.abilities:
		power_toggle("Push — +20% to hit this attack (1 Will)", controller.use_push, manager.active.will <= 0, func(enabled: bool) -> void: controller.set_use_push(enabled))
	if "see_it" in manager.active.loadout.pilot.abilities:
		power_toggle("Use I Can See It — reroll up to 2 misses (1 Will)", controller.use_will, manager.active.will <= 0, func(enabled: bool) -> void: controller.set_use_will(enabled))
	ui.commands.show_dice()
	ui.commands.show_incoming()

func power_toggle(text: String, pressed: bool, disabled: bool, callback: Callable) -> void:
	var power := CheckBox.new()
	power.text = text
	power.button_pressed = pressed
	power.disabled = disabled
	power.toggled.connect(callback)
	ui.commands.command.add_child(power)
