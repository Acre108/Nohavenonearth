class_name BattleCommands
extends BattleUISection

var planning: PlanningCommands
var action: ActionCommands
var attack: AttackCommands

func setup_phases() -> void:
	planning = PlanningCommands.new()
	action = ActionCommands.new()
	attack = AttackCommands.new()
	for section in [planning, action, attack]:
		section.ui = ui
		add_child(section)

var command: VBoxContainer
var feedback: Label
var threat_label: Label
var facing_value: Label
var confirm_button: Button
var commit_button: Button
var last_result: AttackResult

func refresh_command() -> void:
	clear(command)
	confirm_button = null
	commit_button = null
	feedback = null
	threat_label = null
	facing_value = null
	var manager: TurnManager = controller.manager
	match manager.phase:
		TurnManager.Phase.PLANNING:
			planning.build()
		TurnManager.Phase.ACTION:
			action.build()
		TurnManager.Phase.ATTACK:
			attack.build()
		TurnManager.Phase.BATTLE_OVER:
			label(command, "BATTLE OVER", 17, BLUE)
			show_dice()
		TurnManager.Phase.REVEAL:
			label(command, "REVEAL / ENEMY ORDERS EXPOSED", 17, RED)
			for enemy in manager.battle.living(1):
				if enemy.order != null:
					label(command, "%s  →  %s  ·  %s" % [enemy.loadout.callsign, manager.battle.catalogue.manoeuvres[enemy.order.manoeuvre_id].display_name, UnitState.ALTITUDES[enemy.order.altitude]], 13, RED.lightened(0.2))
			label(command, "Red paths show where each enemy is going. Higher Reflex moves first.", 12, MUTED)
			primary(button(command, "RESOLVE MOVEMENT  →    Space", func() -> void: manager.advance()))
		_:
			label(command, TurnManager.PHASE_NAMES[manager.phase] + (" / PAUSED" if manager.paused else " / RESOLVING"), 17, BLUE)
			label(command, "Acting: " + (manager.active.loadout.callsign if manager.active != null else "—"), 14, MUTED)
			show_dice()
			if manager.paused:
				primary(button(command, "ADVANCE ONE STEP", func() -> void: manager.advance()))

func plan_steps(aircraft: bool, charge: bool = false) -> void:
	var steps: PackedStringArray = ["Pick a flight path on the ring", "Click it again to confirm"] if aircraft else ["Click a destination", "Aim · click to lock"]
	var current := 1 if aircraft or controller.planning.choosing_facing else 0
	if charge:
		steps = ["Click an enemy to charge", "Click it again to confirm"]
		current = 1 if controller.planning.draft != null and controller.planning.draft.valid else 0
	var row := HBoxContainer.new()
	command.add_child(row)
	for i in steps.size():
		if i > 0:
			label(row, "→", 13, MUTED)
		var done := i < current
		label(row, ("✓ " if done else "%s " % ["①", "②"][i]) + steps[i], 14 if i == current else 13, GOLD if i == current else (BLUE if done else MUTED))
	if not aircraft and controller.planning.choosing_facing:
		label(row, "   Esc: new destination", 12, MUTED)

func update_preview() -> void:
	if feedback == null or not is_instance_valid(feedback):
		return
	var order: MovementOrder = controller.planning.draft
	var aircraft: bool = controller.planning_aircraft()
	# Mechs confirm through the facing click (or after Suggest); a hovering draft is not yet an order.
	confirm_button.disabled = order == null or not order.valid or not (aircraft or controller.planning.choosing_facing or controller.planning.destination_fixed)
	update_threat_line()
	if order == null:
		feedback.text = "Pick a flight path on the ring around the aircraft." if aircraft else "Hover the field to preview, then click a destination."
		return
	var turned := rad_to_deg(wrapf(order.facing - controller.selected.facing, -PI, PI))
	var summary := "%.1f units · %s · %d Energy · ends turned %+.0f°" % [controller.selected.position.distance_to(order.destination), UnitState.ALTITUDES[order.altitude], order.energy_cost, turned]
	var charge_target: UnitState = controller.manager.battle.unit_by_id(order.target_id)
	if not order.valid:
		feedback.text = "INVALID / " + order.reason
	elif charge_target != null:
		feedback.text = "CHARGE / %s  ·  %.1f units · %d Energy  ·  locks both units in melee, +%d%% melee to hit it this round. It homes on the target if it moves first.  Click it again or CONFIRM MOVE." % [charge_target.loadout.callsign, controller.selected.position.distance_to(order.destination), order.energy_cost, int(MeleeRules.CHARGE_BONUS)]
	elif order.leaves_battlefield:
		feedback.text = "WITHDRAWAL / This flight path leaves the table. The aircraft will be removed. Pick a turn to stay in battle."
	elif aircraft:
		var move: ManoeuvreData = controller.manager.battle.catalogue.manoeuvres[controller.planning.manoeuvre_id]
		feedback.text = "%s / %s  ·  hover the ring to compare, click it again to confirm" % [move.display_name.to_upper(), summary]
	elif controller.planning.choosing_facing:
		feedback.text = "AIM / Destination set · ends turned %+.0f°  ·  click to lock and confirm" % turned
	elif controller.planning.destination_fixed and controller.selected.order == null:
		feedback.text = "READY / %s  ·  CONFIRM MOVE to accept, or click a new destination" % summary
	else:
		feedback.text = "LEGAL / %s  ·  click to set this destination" % summary
	feedback.add_theme_color_override("font_color", GOLD if order.valid and not order.leaves_battlefield else INVALID)

func update_threat_line() -> void:
	if threat_label == null or not is_instance_valid(threat_label):
		return
	var draft: MovementOrder = controller.planning.draft
	threat_label.visible = draft != null and draft.valid
	if not threat_label.visible:
		return
	var threats: Dictionary = controller.draft_threats()
	var names := func(units: Array) -> String: return ", ".join(PackedStringArray(units.map(func(u: UnitState) -> String: return u.loadout.callsign)))
	var parts: PackedStringArray = []
	if not threats.in_arc.is_empty():
		parts.append("In arc now: %s" % names.call(threats.in_arc))
	if not threats.in_reach.is_empty():
		parts.append("Within reach after moving: %s" % names.call(threats.in_reach))
	if parts.is_empty():
		threat_label.text = "THREAT / Outside every enemy's reach this round"
		threat_label.add_theme_color_override("font_color", TARGET)
	else:
		threat_label.text = "THREAT / " + "  ·  ".join(parts)
		threat_label.add_theme_color_override("font_color", RED if not threats.in_arc.is_empty() else GOLD)

func show_forecast(odds: Dictionary) -> void:
	label(command, "FORECAST  ≈ %.1f damage   ·   %d%% chance to hurt   ·   %d%% chance to destroy" % [odds.expected, roundi(odds.p_damage * 100), roundi(odds.p_destroy * 100)], 14, BLUE)
	var parts: PackedStringArray = ["%d shot%s at %d%% to hit" % [odds.shots, "" if odds.shots == 1 else "s", roundi(odds.hit_chance)]]
	if odds.cover > 0:
		parts[0] += " (cover −%d%%)" % (odds.cover * int(CombatRules.PER_POINT))
	parts.append("%d damage per hit after armour" % odds.hit_damage)
	if odds.crit_chance > 0:
		parts.append("%d%% crit for %d" % [roundi(odds.crit_chance), odds.crit_damage])
	if odds.glance_chance > 0:
		parts.append("%d%% glancing for %d" % [roundi(odds.glance_chance), odds.glance_damage])
	if odds.charged:
		parts.append("charge +%d%%" % int(MeleeRules.CHARGE_BONUS))
	if odds.rerolls > 0:
		parts.append("up to %d reroll%s" % [odds.rerolls, "" if odds.rerolls == 1 else "s"])
	label(command, " · ".join(parts), 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func show_incoming() -> void:
	var battle: BattleState = controller.manager.battle
	var lines: PackedStringArray = []
	for result in controller.manager.round_attacks:
		var defender := battle.unit_by_id(result.defender_id)
		if defender.loadout.faction == 0:
			lines.append("%s → %s  /  %s  /  %s" % [battle.unit_by_id(result.attacker_id).loadout.callsign, defender.loadout.callsign, result.weapon_name, AttackFX.damage_text(result)])
	if lines.is_empty():
		return
	label(command, "INCOMING THIS ROUND", 11, RED)
	label(command, "\n".join(lines), 12, RED.lightened(0.25))

func show_dice() -> void:
	if last_result == null:
		return
	var battle: BattleState = controller.manager.battle
	var attacker := battle.unit_by_id(last_result.attacker_id)
	var defender := battle.unit_by_id(last_result.defender_id)
	# Lead with what happened; the dice are the explanation underneath.
	var outcome := "%d DAMAGE → %s" % [last_result.damage, defender.loadout.callsign]
	if last_result.destroyed:
		outcome += "  ·  DESTROYED"
	elif last_result.damage <= 0:
		outcome = ("ARMOUR HELD → %s" if last_result.connected() > 0 else "MISSED → %s") % defender.loadout.callsign
	var row := HBoxContainer.new()
	command.add_child(row)
	label(row, "LAST SHOT", 11, MUTED).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label(row, outcome, 14, AttackFX.damage_color(last_result, defender.loadout.faction) if last_result.damage > 0 else MUTED)
	label(row, "%s · %s" % [attacker.loadout.callsign, last_result.weapon_name], 12, MUTED).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# ● hit · ◆ crit (ignores armour) · ◐ glancing · ○ miss
	var pips := ""
	for i in last_result.shots.size():
		pips += ["○", "◐", "●", "◆"][last_result.shots[i]] + ("↻" if i in last_result.rerolled_indices else "") + " "
	var notes: PackedStringArray = ["%d%% to hit" % roundi(last_result.hit_chance)]
	if last_result.cover > 0:
		notes.append("cover −%d%%" % (last_result.cover * int(CombatRules.PER_POINT)))
	if last_result.armour > 0:
		notes.append("armour −%d per hit" % last_result.armour)
	if last_result.parting:
		notes.append("parting strike")
	if last_result.charged:
		notes.append("charge +%d%%" % int(MeleeRules.CHARGE_BONUS))
	if last_result.pushed:
		notes.append("pushed")
	if not last_result.rerolled_indices.is_empty():
		notes.append("↻ rerolled")
	if last_result.will_spent > 0:
		notes.append("%d Will spent" % last_result.will_spent)
	label(command, "Shots %s   %s" % [pips, " · ".join(notes)], 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
