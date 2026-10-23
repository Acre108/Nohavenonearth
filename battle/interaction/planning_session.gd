class_name PlanningSession
extends Node

## Owns unconfirmed movement drafts and per-unit planning memory.
var controller: BattleController
var manager: TurnManager:
	get: return controller.manager
var selected: UnitState:
	get: return controller.selected

var draft: MovementOrder
var manoeuvre_id: String = "cruise"
var plan_altitude: int = 1
var plan_rotation: float = 0
var plan_point: Vector2
var destination_fixed: bool = false
var choosing_facing: bool = false
var plan_memory: Dictionary = {}
var hover_last := Vector2.INF
var option_orders: Array[MovementOrder] = []
var hover_option: String = ""
## The enemy a Charge draft homes on.
var charge_target_id: String = ""

func select_unit(unit: UnitState) -> void:
	draft = null
	destination_fixed = false
	choosing_facing = false
	hover_last = Vector2.INF
	plan_rotation = 0
	charge_target_id = ""
	plan_altitude = unit.altitude
	plan_point = unit.position + unit.forward() * minf(2.0, unit.loadout.frame.base_move)
	var moves := MovementRules.available(manager.battle, unit)
	if not moves.is_empty():
		manoeuvre_id = moves[0].id
		if unit.loadout.frame.movement_type == "flying" and unit.altitude > 0:
			manoeuvre_id = "cruise"
	if manager.phase == TurnManager.Phase.PLANNING and unit.loadout.faction == 0:
		if MeleeRules.is_engaged(manager.battle, unit):
			# Locked in melee: nothing to plan until it breaks off.
			controller.refresh_overlays()
			return
		if unit.order != null:
			manoeuvre_id = unit.order.manoeuvre_id
			plan_point = unit.order.destination
			plan_rotation = rad_to_deg(wrapf(unit.order.facing - unit.facing, -PI, PI))
			plan_altitude = unit.order.altitude
			charge_target_id = unit.order.target_id
			destination_fixed = true
		elif plan_memory.has(unit.loadout.id):
			var memory: Dictionary = plan_memory[unit.loadout.id]
			manoeuvre_id = memory.manoeuvre_id
			plan_point = memory.plan_point
			plan_rotation = memory.plan_rotation
			plan_altitude = memory.plan_altitude
			destination_fixed = memory.destination_fixed
			charge_target_id = memory.charge_target_id
		update_draft()

func remember_plan() -> void:
	if draft == null or selected == null or selected.order != null or manager.phase != TurnManager.Phase.PLANNING:
		return
	plan_memory[selected.loadout.id] = {"manoeuvre_id": manoeuvre_id, "plan_point": plan_point, "plan_rotation": plan_rotation, "plan_altitude": plan_altitude, "destination_fixed": destination_fixed, "charge_target_id": charge_target_id}

func charging() -> bool:
	return manager.battle.catalogue.manoeuvres.has(manoeuvre_id) and manager.battle.catalogue.manoeuvres[manoeuvre_id].kind == "charge"

## Clicking an enemy while planning a Charge aims it; clicking the same enemy again confirms.
func choose_charge_target(unit: UnitState) -> void:
	if not charging():
		return
	if unit.loadout.id == charge_target_id and draft != null and draft.valid:
		confirm_move()
		return
	charge_target_id = unit.loadout.id
	destination_fixed = true
	update_draft()
	controller.refresh_all()

func choose_manoeuvre(id: String) -> void:
	choosing_facing = false
	manoeuvre_id = id
	plan_rotation = 0
	destination_fixed = false
	var manoeuvre: ManoeuvreData = manager.battle.catalogue.manoeuvres[id]
	var distance := minf(2.0, MovementRules.maximum_distance(selected, manoeuvre))
	plan_point = selected.position + selected.forward() * distance
	if manoeuvre.kind == "lateral":
		plan_point = selected.position + selected.forward().rotated(PI * 0.5) * distance
	if manoeuvre.kind == "reverse":
		plan_point = selected.position - selected.forward() * distance
	if manoeuvre.kind == "ground":
		plan_altitude = 0
	if manoeuvre.kind == "charge":
		plan_altitude = 0
		# Start aimed at the nearest enemy that can actually be reached; the player can click another.
		var reachable := MeleeRules.charge_targets(manager.battle, selected, manoeuvre)
		charge_target_id = TacticalAI.nearest(reachable, selected.position).loadout.id if not reachable.is_empty() else ""
		destination_fixed = not charge_target_id.is_empty()
	update_draft()
	controller.refresh_all()

func choose_altitude(altitude: int) -> void:
	choosing_facing = false
	plan_altitude = altitude
	update_draft()
	controller.refresh_all()

func rotate_plan(degrees: float) -> void:
	var manoeuvre: ManoeuvreData = manager.battle.catalogue.manoeuvres[manoeuvre_id]
	if manoeuvre.kind != "aircraft":
		plan_rotation = clampf(plan_rotation + degrees, -manoeuvre.turn_degrees, manoeuvre.turn_degrees)
	update_draft()
	controller.refresh_all()

func planning_aircraft() -> bool:
	return manager.phase == TurnManager.Phase.PLANNING and selected != null and selected.alive() and selected.loadout.faction == 0 and selected.loadout.frame.movement_type == "aircraft"

func update_draft() -> void:
	if selected == null or not selected.alive() or selected.loadout.faction != 0 or manager.phase != TurnManager.Phase.PLANNING:
		return
	var manoeuvre: ManoeuvreData = manager.battle.catalogue.manoeuvres[manoeuvre_id]
	if MeleeRules.is_engaged(manager.battle, selected):
		draft = null
		return
	draft = MovementRules.create_order(manager.battle, selected, manoeuvre, plan_point, plan_rotation, plan_altitude, manager.battle.unit_by_id(charge_target_id))
	option_orders.clear()
	if planning_aircraft():
		for move in MovementRules.available(manager.battle, selected):
			option_orders.append(draft if move.id == manoeuvre_id else MovementRules.create_order(manager.battle, selected, move, plan_point, 0, plan_altitude))
	controller.refresh_overlays()
	if controller.ui != null:
		controller.ui.update_preview()

func choose_option(id: String) -> void:
	if id == manoeuvre_id and draft != null and draft.valid:
		confirm_move()
		return
	choose_manoeuvre(id)

func set_hover_option(id: String) -> void:
	if hover_option == id:
		return
	hover_option = id
	# Ghosts only: rebuilding the HUD here would destroy the button under the cursor.
	controller.refresh_draft()

func begin_facing() -> void:
	if draft == null or not draft.valid:
		return
	destination_fixed = true
	var move: ManoeuvreData = manager.battle.catalogue.manoeuvres[manoeuvre_id]
	if move.kind in ["aircraft", "charge"] or is_zero_approx(move.turn_degrees):
		# These manoeuvres have a fixed final heading.
		confirm_move()
		return
	choosing_facing = true
	controller.refresh_all()

func aim_plan_at(point: Vector2) -> void:
	if draft == null or not choosing_facing:
		return
	var offset := point - draft.destination
	if offset.length_squared() < 0.01:
		return
	var move: ManoeuvreData = manager.battle.catalogue.manoeuvres[manoeuvre_id]
	var angle := atan2(offset.x, -offset.y)
	plan_rotation = clampf(rad_to_deg(wrapf(angle - selected.facing, -PI, PI)), -absf(move.turn_degrees), absf(move.turn_degrees))
	update_draft()

func cancel_facing() -> void:
	choosing_facing = false
	destination_fixed = false
	hover_last = Vector2.INF
	controller.refresh_all()

func confirm_move() -> void:
	if manager.confirm_order(selected, draft):
		choosing_facing = false
		destination_fixed = true
		for unit in manager.battle.living(0):
			if manager.needs_order(unit):
				controller.select_unit(unit)
				return
		controller.refresh_all()

func suggest_move() -> void:
	choosing_facing = false
	var suggestion := TacticalAI.choose_order(manager.battle, selected)
	if suggestion == null:
		manager.log_message("No legal manoeuvre found. Use debug to reposition altitude or restart if trapped at the boundary.")
		controller.ui.refresh()
		return
	draft = suggestion
	draft.confirmed = false
	manoeuvre_id = draft.manoeuvre_id
	plan_point = draft.destination
	plan_altitude = draft.altitude
	charge_target_id = draft.target_id
	plan_rotation = rad_to_deg(wrapf(draft.facing - selected.facing, -PI, PI))
	destination_fixed = true
	if planning_aircraft():
		# Rebuild the radial alternatives around the suggested path (aircraft orders are deterministic).
		update_draft()
	controller.refresh_all()

func set_plan_point(point: Vector2) -> void:
	var move: ManoeuvreData = manager.battle.catalogue.manoeuvres[manoeuvre_id]
	plan_point = point
	if move.kind == "lateral":
		var side := selected.forward().rotated(PI * 0.5)
		plan_point = selected.position + side * clampf((point - selected.position).dot(side), -2, 2)
	elif move.kind == "reverse":
		plan_point = selected.position - selected.forward() * clampf((selected.position - point).dot(selected.forward()), 1, 2)
	elif move.distance == 1 and move.kind == "vector":
		plan_point = selected.position + (point - selected.position).normalized()
	update_draft()
