class_name WorkshopRuntime
extends Node
## Only deployments explicitly launched from the workshop use its persistent state.
## Autoloaded as /root/WorkshopSession. The class name differs because Godot
## rejects a class_name that matches an autoload name.
var store := WorkshopState.new()
var active: bool = false
var battle_id: String = ""
var notice: String = ""
var save_available: bool = true
var stores: Dictionary = {}

func select_frame(frame_id: String) -> void:
	stores[store.frame_id] = store
	if stores.has(frame_id):
		store = stores[frame_id]
	else:
		var path := WorkshopState.SAVE_PATH if frame_id == "m9_teamster" else "user://kestrel_workshop_v1.json"
		store = WorkshopState.new(path, frame_id)
		stores[frame_id] = store
	save_available = store.load_save()
	notice = "" if save_available else store.error + " Saving is blocked to protect it."

func unit_id() -> String:
	return "blue_kestrel" if store.frame_id == "hx7_kestrel" else "blue_teamster"

func _ready() -> void:
	save_available = store.load_save()
	if not save_available:
		notice = store.error + " Saving is blocked to protect it."

func deploy() -> void:
	if not save_available:
		return
	active = true
	battle_id = str(Time.get_unix_time_from_system()) + "_" + str(Time.get_ticks_usec())
	get_tree().change_scene_to_file("res://battle/world/Battlefield.tscn")

func configure(catalogue: Catalogue) -> void:
	if not active:
		return
	var edit := store.draft()
	for loadout in catalogue.loadouts:
		if loadout.id != unit_id():
			continue
		loadout.frame = store.resolve(loadout.frame, edit)
		loadout.pilot = store.pilots.pilot(edit.pilot)
		loadout.callsign = store.pilots.entries[edit.pilot].callsign
		loadout.starting_structure = maxi(0, loadout.frame.structure - int(store.owned.hull_damage))
		loadout.workshop_finish = store.owned.finish
		loadout.workshop_parts = store.fit_parts(edit)
		loadout.workshop_part_finishes = store.fit_finishes(edit)
		loadout.weapons.clear()
		for weapon_id in store.weapon_ids(edit): loadout.weapons.append(catalogue.weapons[weapon_id])
		if not loadout.frame.default_melee.is_empty():
			loadout.weapons.append(catalogue.weapons[loadout.frame.default_melee])

func capture_result(battle: BattleState) -> bool:
	if not active or store.owned.last_result == battle_id:
		return true
	var mech := battle.unit_by_id(unit_id())
	if mech == null:
		return true
	var damage := mech.loadout.frame.structure - maxi(0, mech.structure)
	# Withdrawal removes a unit from tactical play by zeroing Structure. Keep its pre-withdrawal hull.
	if mech.withdrawn:
		damage = int(store.owned.hull_damage)
	if not store.record_result(battle_id, damage):
		notice = store.error if not store.error.is_empty() else "Sortie result was already recorded."
		return false
	var callsign: String = store.pilots.entries[store.owned.get("pilot", WorkshopState.DEFAULT_PILOT)].callsign
	notice = callsign + " returned. Hull damage recorded; component wear is unchanged."
	return true

func return_to_workshop(battle: BattleState) -> void:
	if not capture_result(battle):
		var dialog := AcceptDialog.new()
		dialog.title = "Could not save sortie result"
		dialog.dialog_text = notice + " Return again to retry."
		add_child(dialog)
		dialog.confirmed.connect(dialog.queue_free)
		dialog.popup_centered()
		return
	active = false
	get_tree().change_scene_to_file("res://workshop/Workshop.tscn")
