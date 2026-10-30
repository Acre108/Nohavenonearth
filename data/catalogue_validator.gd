class_name CatalogueValidator
extends RefCounted

## Validate identifiers and cross references before constructing Resources.
static func validate(definitions: Dictionary, scenario: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var ids := {}
	for group in ["weapons", "manoeuvres", "abilities", "pilots", "frames"]:
		ids[group] = {}
		if not definitions.get(group) is Array:
			errors.append("Catalogue requires an array: %s." % group)
			continue
		for entry in definitions[group]:
			if not entry is Dictionary or not entry.get("id") is String or entry.id.is_empty():
				errors.append("Every %s entry needs a nonempty string id." % group)
				continue
			if ids[group].has(entry.id):
				errors.append("Duplicate %s id: %s." % [group, entry.id])
			ids[group][entry.id] = true
	if not errors.is_empty():
		return errors
	var weapons_by_id := {}
	for weapon in definitions.weapons:
		weapons_by_id[weapon.id] = weapon
	var frames_by_id := {}
	for frame in definitions.frames:
		frames_by_id[frame.id] = frame
	for pilot in definitions.pilots:
		_check_references(pilot.get("abilities", []), ids.abilities, "Pilot %s abilities" % pilot.id, errors)
		_check_stats(pilot.get("stats", {}), "Pilot %s stats" % pilot.id, errors)
		for key in pilot.get("stats", {}):
			var value: Variant = pilot.stats[key]
			if key in UnitState.PILOT_CAPS and (value is float or value is int) and (value != roundf(value) or value > UnitState.PILOT_CAPS[key]):
				errors.append("Pilot %s.%s must be a whole number up to %d." % [pilot.id, key, UnitState.PILOT_CAPS[key]])
	for weapon in definitions.weapons:
		if not (weapon.get("shots") is float or weapon.get("shots") is int) or weapon.shots < 1:
			errors.append("Weapon %s requires at least one shot." % weapon.id)
		if not (weapon.get("damage") is float or weapon.get("damage") is int) or weapon.damage < 0:
			errors.append("Weapon %s requires non-negative damage." % weapon.id)
		if weapon.get("damage_type", "ballistic") not in WeaponData.DAMAGE_TYPES:
			errors.append("Weapon %s has unknown damage_type: %s." % [weapon.id, str(weapon.get("damage_type"))])
		if not SizeClass.valid(weapon.get("size", "medium")):
			errors.append("Weapon %s has unknown size: %s." % [weapon.id, str(weapon.get("size"))])
		# Hit chances move in d10 steps.
		if fmod(float(weapon.get("aim_bonus", 0)), CombatRules.PER_POINT) != 0.0:
			errors.append("Weapon %s aim_bonus must be a multiple of 10." % weapon.id)
	for frame in definitions.frames:
		_check_references(frame.get("manoeuvres", []), ids.manoeuvres, "Frame %s manoeuvres" % frame.id, errors)
		_check_stats(frame.get("stat_bonuses", {}), "Frame %s stat_bonuses" % frame.id, errors)
		_check_stats(frame.get("stat_max", {}), "Frame %s stat_max" % frame.id, errors)
		# Thresholds are the only ceiling on a mech's totals, so none may be left out; pilot-only stats
		# such as Spirit are the pilot's own, so frames may neither raise nor limit them.
		for key in UnitState.STAT_NAMES:
			for field in ["stat_max", "stat_bonuses"]:
				var values: Variant = frame.get(field, {})
				if not values is Dictionary:
					continue
				if key in UnitState.PILOT_ONLY and values.has(key):
					errors.append("Frame %s %s cannot include %s, a pilot-only stat." % [frame.id, field, key])
				elif field == "stat_max" and key not in UnitState.PILOT_ONLY and not values.has(key):
					errors.append("Frame %s stat_max is missing %s." % [frame.id, key])
		if not SizeClass.valid(frame.get("size_class", "medium")):
			errors.append("Frame %s has unknown size_class: %s." % [frame.id, str(frame.get("size_class"))])
		if frame.get("armour_type", "none") != "none" and frame.get("armour_type") not in WeaponData.DAMAGE_TYPES:
			errors.append("Frame %s has unknown armour_type: %s." % [frame.id, str(frame.get("armour_type"))])
		var hands: String = frame.get("default_melee", "")
		if not hands.is_empty() and (not weapons_by_id.has(hands) or not weapons_by_id[hands].get("melee", false)):
			errors.append("Frame %s default_melee must name a melee weapon: %s." % [frame.id, hands])
		if not frame.get("altitude_access") is Array:
			errors.append("Frame %s requires altitude_access." % frame.id)
	if not scenario.get("units") is Array:
		errors.append("Scenario requires a units array.")
	else:
		var unit_ids := {}
		for unit in scenario.units:
			if not unit is Dictionary or not unit.get("id") is String:
				errors.append("Each scenario unit requires a string id.")
				continue
			if unit.id.is_empty() or unit_ids.has(unit.id):
				errors.append("Empty or duplicate unit id: %s." % unit.id)
			unit_ids[unit.id] = true
			for pair in [["pilot", "pilots"], ["frame", "frames"]]:
				if not ids[pair[1]].has(unit.get(pair[0], "")):
					errors.append("Unit %s references unknown %s: %s." % [unit.id, pair[0], unit.get(pair[0], "")])
			_check_references(unit.get("weapons"), ids.weapons, "Unit %s weapons" % unit.id, errors)
			if frames_by_id.has(unit.get("frame", "")) and unit.get("weapons") is Array:
				var frame_size: String = frames_by_id[unit.frame].get("size_class", "medium")
				for weapon_id in unit.weapons:
					if weapons_by_id.has(weapon_id) and not SizeClass.can_carry(frame_size, weapons_by_id[weapon_id].get("size", "medium")):
						errors.append("Unit %s: %s is too big for a %s frame." % [unit.id, weapon_id, SizeClass.NAMES.get(frame_size, frame_size)])
			if not _pair(unit.get("start_position")):
				errors.append("Unit %s requires a numeric start_position pair." % unit.id)
	if not scenario.get("terrain") is Array:
		errors.append("Scenario requires a terrain array.")
	var field: Variant = scenario.get("battlefield")
	if not field is Dictionary:
		errors.append("Scenario requires battlefield bounds.")
	elif not _pair(field.get("origin")) or not _pair(field.get("size")):
		errors.append("Battlefield origin and size must be numeric pairs.")
	elif field.size[0] <= 0 or field.size[1] <= 0:
		errors.append("Battlefield size must be positive.")
	return errors

static func _check_stats(values: Variant, context: String, errors: Array[String]) -> void:
	if not values is Dictionary:
		errors.append("%s must be an object." % context)
		return
	for key in values:
		if key not in UnitState.STAT_NAMES:
			errors.append("%s has unknown stat: %s." % [context, str(key)])
		elif not (values[key] is float or values[key] is int) or values[key] < 0:
			errors.append("%s.%s must be a non-negative number." % [context, key])

static func _pair(value: Variant) -> bool:
	return value is Array and value.size() == 2 and (value[0] is float or value[0] is int) and (value[1] is float or value[1] is int)

static func _check_references(values: Variant, known: Dictionary, context: String, errors: Array[String]) -> void:
	if not values is Array:
		errors.append("%s must be an array." % context)
		return
	for id in values:
		if not id is String or not known.has(id):
			errors.append("%s references unknown id: %s." % [context, str(id)])
