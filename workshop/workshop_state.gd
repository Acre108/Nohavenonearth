class_name WorkshopState
extends RefCounted
## Flat regions, at most two components each. Definitions never hold owned state.
const CONTENT := "res://data/catalogues/teamster_workshop.json"
const SAVE_PATH := "user://teamster_workshop_v1.json"
const LABOUR := 40
const HULL_RATE := 8
## Components below this integrity apply their wear penalties.
const WORN_BELOW := 60
const DEFAULT_PILOT := "anchor"
const STARTING_SPARES := ["sensor_standard", "sensor_precision", "structure_braced", "torso_heavy", "arm_standard", "arm_precision", "arm_reinforced", "leg_fast", "leg_braced", "power_buffered", "service_upgraded", "module_recovery", "foreign_sensor", "oversize_arm"]
## Spares added in content revision 2 (weapon arms and paired limb variants), seeded into older saves.
const NEW_SPARES := {"spare_arm_marksman":"arm_marksman", "spare_arm_support":"arm_support", "spare_arm_cannon":"arm_cannon", "spare_arm_breacher":"arm_breacher", "spare_arm_precision_pair":"arm_precision", "spare_arm_reinforced_pair":"arm_reinforced", "spare_leg_fast_pair":"leg_fast", "spare_leg_braced_pair":"leg_braced"}
const CONTENT_REVISION := 2
## Stock arms carry no weapon entry; their actuator mounts the factory weapon for that side.
const STOCK_ARM_WEAPONS := {"right_arm.actuator":"ar40_rifle", "left_arm.actuator":"pb4_stake"}
const WEAPON_SLOTS := ["right_arm.actuator", "left_arm.actuator", "backpack.module"]
const FRAME_STATS := ["structure", "armour", "base_move", "energy_capacity", "energy_recharge"]
var regions: Array = []
var parts: Dictionary = {}
var finishes: Array = []
var slots: Dictionary = {}
var manufacturers: Dictionary = {}
var workshop_frame: FrameData
var owned: Dictionary = {}
var error: String = ""
var save_path: String
var pilots := WorkshopPilots.new()

func _init(path: String = SAVE_PATH) -> void:
	save_path = path
	var content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CONTENT))
	regions = content.regions
	finishes = content.finishes
	manufacturers = content.manufacturers
	workshop_frame = Catalogue.new().frames[content.frame_id]
	for part in content.parts:
		assert(part.get("rarity", "") in ["standard", "uncommon", "rare"], "Unknown component rarity")
		assert(manufacturers.has(part.manufacturer), "Unknown component manufacturer")
		assert(SizeClass.valid(part.size_class), "Unknown component size")
		assert(part.energy_reservation >= 0 and is_equal_approx(part.energy_reservation * 4.0, roundf(part.energy_reservation * 4.0)), "Reservations must be nonnegative quarter Energy")
		parts[part.id] = part
	for region in regions:
		assert(region.slots.size() <= 2, "Workshop regions may have at most two components")
		for slot in region.slots:
			slots[slot.id] = slot
	owned = initial_state()

func initial_state() -> Dictionary:
	var state := {"version":1, "credits":1800, "installed":{}, "inventory":{}, "hull_damage":14, "finish":"depot", "part_finishes":{}, "pilot":DEFAULT_PILOT, "last_result":""}
	var count := 0
	for slot_id in slots:
		count += 1
		var uid := "factory_%02d" % count
		state.installed[slot_id] = uid
		# The damaged left actuator gives a first visit something worn to repair.
		state.inventory[uid] = {"part":slots[slot_id].standard, "integrity":55 if slot_id == "left_arm.actuator" else 100}
	for part_id in STARTING_SPARES:
		state.inventory["spare_" + part_id] = {"part":part_id, "integrity":80 if part_id == "arm_standard" else 100}
	seed_new_spares(state)
	return state

func seed_new_spares(state: Dictionary) -> void:
	if int(state.get("content_revision", 0)) >= CONTENT_REVISION:
		state.content_revision = int(state.content_revision)
		return
	for uid in NEW_SPARES:
		if not state.inventory.has(uid):
			state.inventory[uid] = {"part":NEW_SPARES[uid], "integrity":100}
	state.content_revision = CONTENT_REVISION

func fit_parts(edit: Dictionary) -> Dictionary:
	var result := {}
	for slot in slots: result[slot] = owned.inventory[edit.installed[slot]].part
	return result

func weapon_ids(edit: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for slot in WEAPON_SLOTS:
		var weapon := weapon_for(part_for(slot, edit), slot)
		if not weapon.is_empty(): result.append(weapon)
	return result

## The weapon this part provides when mounted in the slot, or "".
func weapon_for(part: Dictionary, slot_id: String) -> String:
	return part.get("weapon", STOCK_ARM_WEAPONS.get(slot_id, ""))

func dependency_issue(edit: Dictionary) -> String:
	var fit := fit_parts(edit)
	for slot in fit:
		var part: Dictionary = parts[fit[slot]]
		for required in part.get("requires", {}):
			if fit.get(required) != part.requires[required]:
				return "%s requires %s in %s." % [part.name, parts[part.requires[required]].name, required]
	return ""

## A detached copy of the owned fit to edit. Methods taking `edit` expect one of these drafts.
func draft() -> Dictionary:
	return {"installed":owned.installed.duplicate(true), "repairs":[], "repair_hull":false, "finish":owned.finish, "part_finishes":owned.get("part_finishes", {}).duplicate(true), "pilot":owned.get("pilot", DEFAULT_PILOT)}

## A copy of the draft with one slot refitted.
func with_part(edit: Dictionary, slot_id: String, uid: String) -> Dictionary:
	var trial := edit.duplicate(true)
	trial.installed[slot_id] = uid
	return trial

## Why this owned component cannot replace the slot's part in the draft, or "" when it can.
func fit_issue(edit: Dictionary, slot_id: String, uid: String, base: FrameData = null) -> String:
	var mismatch := compatibility(owned_part(uid), slot_id, base)
	if mismatch.is_empty() and not budget(with_part(edit, slot_id, uid), base).valid:
		return "Energy budget exceeded"
	return mismatch

## An owned copy of the part that the draft does not already install, or "".
func spare_of(part_id: String, edit: Dictionary) -> String:
	var installed: Array = edit.installed.values()
	for uid in owned.inventory:
		if owned.inventory[uid].part == part_id and uid not in installed:
			return uid
	return ""

func fit_finishes(edit: Dictionary) -> Dictionary:
	var result := {}
	for slot in slots:
		var uid: String = edit.installed[slot]
		if edit.get("part_finishes", {}).has(uid):
			result["Component_" + String(slot).replace(".", "_")] = WorkshopAppearance.finish_by_id(edit.part_finishes[uid])
	return result

func integrity(uid: String, edit: Dictionary) -> int:
	return 100 if uid in edit.repairs else int(owned.inventory[uid].integrity)

func part_for(slot_id: String, edit: Dictionary) -> Dictionary:
	return owned_part(edit.installed[slot_id])

## Catalogue definition of an owned component.
func owned_part(uid: String) -> Dictionary:
	return parts[owned.inventory[uid].part]

func repair_cost(uid: String) -> int:
	return (100 - int(owned.inventory[uid].integrity)) * int(owned_part(uid).repair_rate)

func hull_repair_cost() -> int:
	return int(owned.hull_damage) * HULL_RATE

func cost(edit: Dictionary) -> int:
	var total := hull_repair_cost() if edit.repair_hull else 0
	for slot_id in slots:
		if edit.installed.get(slot_id, "") != owned.installed[slot_id]:
			total += LABOUR
	for uid in edit.repairs:
		if owned.inventory.has(uid):
			total += repair_cost(uid)
	return total

func validate_state(state: Dictionary) -> String:
	if not state.get("pilot", DEFAULT_PILOT) is String or not pilots.entries.has(state.get("pilot", DEFAULT_PILOT)):
		return "Unknown workshop pilot."
	if state.get("version") != 1:
		return "Unsupported workshop save version."
	for key in ["credits", "hull_damage", "installed", "inventory", "finish", "last_result"]:
		if not state.has(key):
			return "Incomplete workshop save."
	if not state.installed is Dictionary or not state.inventory is Dictionary:
		return "Invalid inventory format."
	if not (state.credits is float or state.credits is int) or not (state.hull_damage is float or state.hull_damage is int):
		return "Invalid workshop resources."
	if state.credits < 0 or state.hull_damage < 0 or state.credits != floor(state.credits) or state.hull_damage != floor(state.hull_damage):
		return "Invalid workshop resources."
	if state.installed.size() != slots.size() or not state.last_result is String:
		return "Invalid installed component map."
	var finish_ids := finishes.map(func(f: Dictionary) -> String: return f.id)
	if state.finish not in finish_ids:
		return "Unknown paint finish."
	if not state.get("part_finishes", {}) is Dictionary:
		return "Invalid component finishes."
	for uid in state.get("part_finishes", {}):
		if not state.inventory.has(uid) or state.part_finishes[uid] not in finish_ids:
			return "Unknown component finish."
	for uid in state.inventory:
		var item = state.inventory[uid]
		if not item is Dictionary or not parts.has(item.get("part", "")):
			return "Unknown inventory component."
		var health = item.get("integrity", -1)
		if not (health is int or health is float) or health < 0 or health > 100 or health != floor(health):
			return "Invalid component condition."
	var used: Array = []
	for slot_id in slots:
		var uid = state.installed.get(slot_id, "")
		if not uid is String or not state.inventory.has(uid) or uid in used:
			return "Missing or duplicate installed component."
		var mismatch := compatibility(parts[state.inventory[uid].part], slot_id)
		if not mismatch.is_empty():
			return mismatch
		used.append(uid)
	return ""

func validate(edit: Dictionary) -> String:
	if not edit.get("installed") is Dictionary or not edit.get("repairs") is Array or not edit.get("repair_hull") is bool:
		return "Invalid refit draft."
	var candidate := owned.duplicate(true)
	candidate.installed = edit.installed
	candidate.finish = edit.get("finish", "")
	candidate.part_finishes = edit.get("part_finishes", {})
	candidate.pilot = edit.get("pilot", DEFAULT_PILOT)
	var issue := validate_state(candidate)
	if not issue.is_empty():
		return issue
	issue = dependency_issue(edit)
	if not issue.is_empty(): return issue
	var repaired: Array = []
	for uid in edit.repairs:
		if not owned.inventory.has(uid) or uid in repaired:
			return "Invalid repair selection."
		repaired.append(uid)
	var power := budget(edit)
	if not power.valid:
		return "Energy budget exceeded: %s reserved / %s plant capacity." % [str(power.reserved), str(power.rated)]
	if cost(edit) > owned.credits:
		return "Insufficient funds for this refit."
	return ""

func changed(edit: Dictionary) -> bool:
	var refitted: bool = edit.installed != owned.installed
	var serviced: bool = not edit.repairs.is_empty() or edit.repair_hull
	var repainted: bool = edit.finish != owned.finish or edit.get("part_finishes", {}) != owned.get("part_finishes", {})
	var reassigned: bool = edit.get("pilot", DEFAULT_PILOT) != owned.get("pilot", DEFAULT_PILOT)
	return refitted or serviced or repainted or reassigned

## True when the draft swaps, repairs or repaints the component in this slot.
func slot_changed(slot_id: String, edit: Dictionary) -> bool:
	var uid: String = edit.installed[slot_id]
	var swapped: bool = uid != owned.installed[slot_id]
	var repaired: bool = uid in edit.repairs
	var repainted: bool = edit.part_finishes.get(uid, "") != owned.get("part_finishes", {}).get(uid, "")
	return swapped or repaired or repainted

func apply(edit: Dictionary, path: String = "") -> bool:
	if path.is_empty(): path = save_path
	error = validate(edit)
	if not error.is_empty():
		return false
	var candidate := owned.duplicate(true)
	candidate.credits -= cost(edit)
	candidate.installed = edit.installed.duplicate(true)
	candidate.finish = edit.finish
	candidate.part_finishes = edit.get("part_finishes", {}).duplicate(true)
	candidate.pilot = edit.get("pilot", DEFAULT_PILOT)
	for uid in edit.repairs:
		candidate.inventory[uid].integrity = 100
	if edit.repair_hull:
		candidate.hull_damage = 0
	if not write_state(candidate, path):
		return false
	owned = candidate
	return true

func write_state(state: Dictionary, path: String) -> bool:
	# Replace only after a complete temporary file exists; retain the prior save on error.
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		error = "Could not write workshop save."
		return false
	file.store_string(JSON.stringify(state, "\t"))
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK or DirAccess.rename_absolute(temp, path) != OK:
		error = "Could not replace workshop save. Previous configuration retained."
		return false
	return true

func load_save(path: String = "") -> bool:
	if path.is_empty(): path = save_path
	if not FileAccess.file_exists(path):
		return true
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		error = "Workshop save could not be read. Original file retained."
		return false
	var parsed = json.data
	if not parsed is Dictionary:
		error = "Workshop save could not be read. Original file retained."
		return false
	error = validate_state(parsed)
	if not error.is_empty():
		return false
	# JSON numbers arrive as floats. Normalise owned counters for exact round trips.
	for key in ["version", "credits", "hull_damage"]:
		parsed[key] = int(parsed[key])
	for item in parsed.inventory.values():
		item.integrity = int(item.integrity)
	seed_new_spares(parsed)
	if not parsed.has("part_finishes"): parsed.part_finishes = {}
	if not parsed.has("pilot"): parsed.pilot = DEFAULT_PILOT
	owned = parsed
	return true

func resolve(base: FrameData, edit: Dictionary) -> FrameData:
	# Catalogue values describe a complete standard fit. Alternatives add only deltas.
	var frame: FrameData = base.duplicate(true)
	frame.stat_bonuses = base.stat_bonuses.duplicate(true)
	frame.energy_reserved = 0.0
	for slot_id in slots:
		var part := part_for(slot_id, edit)
		add_bonuses(frame, part.bonuses)
		frame.energy_reserved += float(part.energy_reservation)
		if integrity(edit.installed[slot_id], edit) < WORN_BELOW:
			add_bonuses(frame, part.wear)
	frame.structure = maxi(1, frame.structure)
	frame.energy_capacity = maxi(1, frame.energy_capacity)
	frame.energy_recharge = maxi(0, frame.energy_recharge)
	frame.base_move = maxf(0.5, frame.base_move)
	return frame

func manufacturer_name(tag: String) -> String:
	return manufacturers.get(tag, tag)

func compatibility(part: Dictionary, slot_id: String, target: FrameData = null) -> String:
	if target == null: target = workshop_frame
	var allowed := target.compatible_manufacturers.duplicate()
	if allowed.is_empty(): allowed.append(target.manufacturer)
	if part.get("manufacturer", "") not in allowed:
		return "Manufacturer mismatch: %s requires %s." % [target.display_name, manufacturer_name(target.manufacturer)]
	if part.get("size_class", "") != target.size_class:
		return "Size mismatch: %s part / %s frame." % [SizeClass.NAMES.get(part.get("size_class", ""), "Unknown"), SizeClass.NAMES[target.size_class]]
	if part.family != slots[slot_id].family:
		return "Mount mismatch: needs %s; part uses %s." % [slots[slot_id].family, part.family]
	if part.has("allowed_slots") and slot_id not in part.allowed_slots:
		return "Side-specific mount: fits " + ", ".join(part.allowed_slots) + "."
	return ""

func budget(edit: Dictionary, base: FrameData = null) -> Dictionary:
	var frame := resolve(workshop_frame if base == null else base, edit)
	return {"rated":frame.energy_capacity, "reserved":frame.energy_reserved, "available":frame.energy_available(), "valid":frame.energy_reserved <= frame.energy_capacity}

func add_bonuses(frame: FrameData, bonuses: Dictionary) -> void:
	for stat in bonuses:
		if stat in FRAME_STATS:
			frame.set(stat, frame.get(stat) + bonuses[stat])
		else:
			frame.stat_bonuses[stat] = frame.stat_bonuses.get(stat, 0.0) + bonuses[stat]

func hull(base: FrameData, edit: Dictionary) -> int:
	return maxi(0, resolve(base, edit).structure - (0 if edit.repair_hull else int(owned.hull_damage)))

func readiness(base: FrameData, edit: Dictionary) -> String:
	var dependency := dependency_issue(edit)
	if not dependency.is_empty(): return dependency
	for slot_id in slots:
		var mismatch := compatibility(part_for(slot_id, edit), slot_id, base)
		if not mismatch.is_empty(): return mismatch
	if not budget(edit, base).valid:
		return "Installed components exceed the plant's Energy budget."
	for slot_id in slots:
		if integrity(edit.installed[slot_id], edit) <= 0:
			return "Disabled component: " + slots[slot_id].name
	if hull(base, edit) <= 0:
		return "Hull recovery required. Repair before deployment."
	return ""

func record_result(result_id: String, damage: int, path: String = "") -> bool:
	if path.is_empty(): path = save_path
	error = ""
	if result_id.is_empty() or result_id == owned.last_result:
		return false
	var candidate := owned.duplicate(true)
	candidate.hull_damage = maxi(0, damage)
	candidate.last_result = result_id
	if not write_state(candidate, path):
		return false
	owned = candidate
	return true
