class_name BattleUnitPanels
extends BattleUISection

var roster: VBoxContainer
var inspector: VBoxContainer
var stats_window: Window

func refresh_roster() -> void:
	clear(roster)
	var battle: BattleState = controller.manager.battle
	for faction in [0, 1]:
		label(roster, "BLUE / YOUR FLIGHT" if faction == 0 else "RED / HOSTILE CONTACTS", 12, BLUE if faction == 0 else RED)
		for unit in battle.units:
			if unit.loadout.faction != faction:
				continue
			var status := "DESTROYED" if not unit.alive() else "%d HP · %s Energy · %s" % [unit.structure, str(unit.energy), UnitState.ALTITUDES[unit.altitude].capitalize()]
			var order_state := ""
			if controller.manager.phase == TurnManager.Phase.PLANNING and unit.alive():
				order_state = ("✓ READY" if unit.order != null else "NEEDS ORDER") if faction == 0 else "ORDERS HIDDEN"
			var item := button(roster, "%s%s%s\n%s" % ["› " if unit == controller.selected else "", unit.loadout.callsign, ("   " + order_state) if order_state != "" else "", status], func() -> void: controller.select_unit(unit))
			item.alignment = HORIZONTAL_ALIGNMENT_LEFT
			item.add_theme_font_size_override("font_size", 13)
			item.add_theme_color_override("font_color", (BLUE if faction == 0 else RED) if unit.alive() else MUTED.darkened(0.3))
	label(roster, "FIELD GUIDE", 12, GOLD)
	var help := label(roster, "Click a unit to inspect.\nMechs: click a destination,\nthen aim and click to lock.\nAircraft: pick a path on the\nring, click it again to confirm.\nEsc picks a new destination.\nAmber = draft · Cyan = ordered\nPale sector = weapon range\nMagenta in a sector = no line of sight\n+N COVER = −N×10% to be hit\nInner contour = minimum range\nWhite brackets = selected\nWhite crosshair = legal target\nMagenta = illegal / blocked\nChevron = facing\n1 tether tick = Low · 2 = High\n\nWASD / arrows   Pan\nWheel   Zoom\nRight-drag / Q E   Orbit\nMiddle-drag   Pan\nR   Reset camera\nV / wheel in   Close view\nAny key   Skip cinematic\nF8   Sensor view\nF3   Debug sandbox", 12, MUTED)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func refresh_inspector() -> void:
	clear(inspector)
	var unit: UnitState = controller.selected
	if unit == null:
		label(inspector, "SELECT A UNIT", 17, BLUE)
		return
	# Only what a player needs to make the next decision; the full breakdown lives in the stats window.
	# The stats button sits beside the name so it is never scrolled out of sight.
	var heading := HBoxContainer.new()
	inspector.add_child(heading)
	label(heading, unit.loadout.callsign, 17, BLUE if unit.loadout.faction == 0 else RED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var stats_button := button(heading, "Full stats…", func() -> void: show_stats(unit))
	stats_button.add_theme_font_size_override("font_size", 12)
	stats_button.tooltip_text = "Pilot skills, frame bonuses, armour and every rule number for this unit."
	label(inspector, unit.loadout.frame.display_name, 15)
	label(inspector, "%s · %s altitude" % [unit_kind(unit), UnitState.ALTITUDES[unit.altitude].capitalize()], 12, GOLD)
	label(inspector, "HP  %d / %d" % [unit.structure, unit.loadout.frame.structure], 14)
	var health := ProgressBar.new()
	health.max_value = unit.loadout.frame.structure
	health.value = unit.structure
	health.show_percentage = false
	health.custom_minimum_size.y = 6
	inspector.add_child(health)
	var energy := label(inspector, "Energy  %s / %s   (+%d each round)" % [str(unit.energy), str(unit.loadout.frame.energy_available()), unit.loadout.frame.energy_recharge], 13, GOLD)
	if unit.loadout.frame.energy_reserved > 0:
		label(inspector, "%s of %d Energy reserved by hardware" % [str(unit.loadout.frame.energy_reserved), unit.loadout.frame.energy_capacity], 12, MUTED)
	energy.tooltip_text = "Spent on advanced moves and some weapons. Refills a little at the end of each round."
	energy.mouse_filter = Control.MOUSE_FILTER_PASS
	if not unit.loadout.pilot.abilities.is_empty():
		var will := label(inspector, "Will  %d / %d   (for pilot powers, never refills)" % [unit.will, unit.will_max()], 13, GOLD)
		will.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label(inspector, "WEAPONS", 11, BLUE)
	for weapon in unit.loadout.weapons:
		# Mid-attack, weapon buttons select the active unit's weapon, so only that unit's are live.
		var weapon_button := button(inspector, weapon.display_name, func() -> void: controller.choose_weapon(unit.loadout.weapons.find(weapon)), controller.blue_attacking() and unit != controller.manager.active)
		weapon_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		weapon_button.add_theme_font_size_override("font_size", 13)
		weapon_button.tooltip_text = "Show this weapon's reach on the map."
		label(inspector, weapon_line(unit, weapon), 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not unit.locks.is_empty():
		var locks: PackedStringArray = []
		for id in unit.locks:
			locks.append(controller.manager.battle.unit_by_id(id).loadout.callsign)
		label(inspector, "Locked on: " + ", ".join(locks), 12, GOLD).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for id in unit.loadout.pilot.abilities:
		var ability: AbilityData = controller.manager.battle.catalogue.abilities[id]
		label(inspector, "POWER · %s  (%d Will)" % [ability.display_name, ability.will_cost], 11, BLUE)
		label(inspector, ability.description, 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func unit_kind(unit: UnitState) -> String:
	if unit.loadout.frame.id == "type99_tank":
		return "Tank"
	return {"flying": "Flying mech", "ground": "Ground mech", "aircraft": "Aircraft"}.get(unit.loadout.frame.movement_type, unit.loadout.frame.movement_type.capitalize())

static func range_text(weapon: WeaponData) -> String:
	return ("range %s–%s" % [str(weapon.range_min), str(weapon.range_max)]) if weapon.range_min > 0 else "range up to %s" % str(weapon.range_max)

static func arc_text(weapon: WeaponData) -> String:
	return "fires all around" if weapon.arc >= 360 else "%d° in front" % int(weapon.arc)

static func weapon_line(unit: UnitState, weapon: WeaponData) -> String:
	var parts: PackedStringArray = ["%d shot%s × %d %s" % [weapon.shots, "" if weapon.shots == 1 else "s", weapon.damage, weapon.damage_type]]
	if weapon.armour_piercing > 0:
		parts.append("AP %d" % weapon.armour_piercing)
	if weapon.aim_bonus != 0:
		parts.append("%+d%% aim" % int(weapon.aim_bonus))
	parts.append_array([range_text(weapon), arc_text(weapon)])
	if weapon.melee:
		parts.append("melee")
	if weapon.heavy:
		parts.append("heavy")
	if weapon.energy_cost > 0:
		parts.append("%d Energy" % weapon.energy_cost)
	return " · ".join(parts)

func show_stats(unit: UnitState) -> void:
	if not is_instance_valid(stats_window):
		stats_window = Window.new()
		stats_window.size = Vector2i(700, 680)
		stats_window.transient = true
		stats_window.close_requested.connect(func() -> void: stats_window.hide())
		root.add_child(stats_window)
	stats_window.title = "%s / Full stats" % unit.loadout.callsign
	for child in stats_window.get_children():
		child.queue_free()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	stats_window.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	var explain := func(text: String) -> void: label(body, text, 12, MUTED).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var frame := unit.loadout.frame
	label(body, "%s — %s" % [unit.loadout.callsign, frame.display_name], 18, BLUE if unit.loadout.faction == 0 else RED)
	label(body, "Pilot %s · %s" % [unit.loadout.pilot.display_name, unit_kind(unit)], 13, MUTED)
	label(body, "PILOT SKILLS", 12, GOLD)
	explain.call("Total = pilot + frame bonus (including fitted parts), up to the frame's maximum. Every point has the same effect, shown on the right.")
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 14)
	body.add_child(grid)
	for heading in ["Skill", "Pilot", "Frame bonus", "Frame max", "Total", "Each point"]:
		label(grid, heading, 12, BLUE)
	var meaning := {"gunnery": "+10% to hit with ranged weapons", "melee": "+10% to hit with melee weapons", "precision": "+10% crit chance (crits ignore armour)", "reflex": "−10% to be hit · moves and fires earlier", "systems": "Electronic attack (not in play yet)", "countermeasures": "Electronic defence (not in play yet)", "spirit": "+1 maximum Will"}
	for stat in UnitState.STAT_NAMES:
		label(grid, stat.capitalize(), 13)
		label(grid, stat_text(float(unit.pilot_stats.get(stat, 0))), 13, MUTED)
		label(grid, stat_text(float(unit.bonus_stats.get(stat, 0)) + float(unit.fraction_stats.get(stat, 0))), 13, MUTED)
		label(grid, stat_text(unit.stat_max(stat)), 13, MUTED)
		label(grid, stat_text(unit.stat(stat)), 13, GOLD)
		label(grid, meaning.get(stat, ""), 12, MUTED)
	label(body, "FRAME", 12, GOLD)
	label(body, "%s · HP %d / %d · Armour %d (%s) · Move %s" % [SizeClass.NAMES.get(frame.size_class, frame.size_class), unit.structure, frame.structure, frame.armour, "vs any type" if frame.armour_type == "none" else "+%d vs %s" % [CombatRules.TYPE_MATCH_BONUS, frame.armour_type], str(frame.base_move)], 13)
	explain.call("Armour comes off every hit, +%d against its own damage type, minus the weapon's armour piercing; crits ignore it. Size: attacks get %+d%% to hit this frame, and it carries weapons up to its own size." % [CombatRules.TYPE_MATCH_BONUS, int(SizeClass.HIT_MODIFIER.get(frame.size_class, 0.0))])
	label(body, "Energy %s / %s, refills %d per round · Will %d / %d, never refills" % [str(unit.energy), str(frame.energy_available()), frame.energy_recharge, unit.will, unit.will_max()], 13)
	if frame.energy_reserved > 0:
		explain.call("Installed hardware reserves %s of the plant's %d Energy. Recharge cannot exceed the remaining %s." % [str(frame.energy_reserved), frame.energy_capacity, str(frame.energy_available())])
	label(body, "WEAPONS", 12, GOLD)
	for weapon in unit.loadout.weapons:
		label(body, weapon.display_name, 13)
		explain.call("%s · AP %d · %+d%% aim · %s size · uses %s%s%s · %s · %s · %d Energy per attack" % [weapon_line(unit, weapon).split(" · ")[0], weapon.armour_piercing, int(weapon.aim_bonus), SizeClass.NAMES.get(weapon.size, weapon.size), CombatRules.attack_stat(weapon).capitalize(), " (range from base edge)" if weapon.melee else "", " · heavy: a near miss (within 20%) is a glancing hit for half damage" if weapon.heavy else "", range_text(weapon), arc_text(weapon), weapon.energy_cost])
	label(body, "MANOEUVRES", 12, GOLD)
	for move: ManoeuvreData in MovementRules.available(controller.manager.battle, unit):
		explain.call("%s — up to %s units%s" % [move.display_name, str(snappedf(MovementRules.maximum_distance(unit, move), 0.01)), (" · %d Energy" % move.energy_cost) if move.energy_cost > 0 else ""])
	label(body, "TARGET LOCKS", 12, GOLD)
	explain.call("Holds one lock. Locking on uses the unit's action; the next shot at the locked target rerolls one miss.")
	stats_window.popup_centered()

static func stat_text(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, roundf(value)) else str(snappedf(value, 0.25))
