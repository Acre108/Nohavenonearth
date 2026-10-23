class_name BattleOverlayRenderer
extends Node

const PREVIEW_SCENE := preload("res://movement/presentation/MovementPreview.tscn")

const ARC_SCENE := preload("res://combat/presentation/TargetingOverlay.tscn")

var controller: BattleController

func refresh_threats() -> void:
	controller.clear_nodes(controller.threats_root)
	if not controller.show_threats or controller.manager.battle == null or controller.manager.phase != TurnManager.Phase.PLANNING:
		return
	var enemies := controller.manager.battle.living(1)
	for i in enemies.size():
		var threat := ThreatOverlay.new()
		controller.threats_root.add_child(threat)
		threat.show_threat(controller.manager.battle, enemies[i], i - (enemies.size() - 1) * 0.5)

func refresh_overlays() -> void:
	controller.clear_nodes(controller.overlays)
	if controller.manager == null or controller.manager.battle == null:
		return
	var weapon := controller.current_weapon()
	var attacker := controller.targeting_unit()
	# While planning a Charge, the crosshairs mark the enemies it can reach instead of weapon targets.
	var charging := controller.manager.phase == TurnManager.Phase.PLANNING and controller.selected != null and controller.selected.loadout.faction == 0 and controller.planning.charging()
	var chargeable: Array[UnitState] = []
	if charging:
		chargeable = MeleeRules.charge_targets(controller.manager.battle, controller.selected, controller.manager.battle.catalogue.manoeuvres[controller.planning.manoeuvre_id])
	for unit in controller.manager.battle.units:
		var legal_target := unit in chargeable if charging else attacker != null and weapon != null and unit.loadout.faction != attacker.loadout.faction and CombatRules.target_error(controller.manager.battle, attacker, unit, weapon).is_empty()
		if controller.actors.has(unit.loadout.id):
			controller.actors[unit.loadout.id].highlight(unit == controller.selected, legal_target)
			controller.actors[unit.loadout.id].set_active(unit == controller.manager.active and controller.manager.phase in [TurnManager.Phase.MOVEMENT, TurnManager.Phase.ACTION, TurnManager.Phase.ATTACK])
		if unit.order != null and unit.alive() and controller.manager.phase in [TurnManager.Phase.PLANNING, TurnManager.Phase.REVEAL, TurnManager.Phase.MOVEMENT]:
			if unit.loadout.faction == 0 or controller.manager.phase != TurnManager.Phase.PLANNING or controller.manager.reveal_enemy:
				var preview: MovementPreview = PREVIEW_SCENE.instantiate()
				controller.overlays.add_child(preview)
				preview.show_order(unit, unit.order)
		if unit.alive():
			for foe in MeleeRules.foes(controller.manager.battle, unit):
				if unit.loadout.id < foe.loadout.id:
					show_engagement(unit, foe)
	if controller.show_arcs and weapon != null and attacker != null and attacker.alive():
		var arc: TargetingOverlay = ARC_SCENE.instantiate()
		controller.overlays.add_child(arc)
		var arc_target := controller.target if controller.target != null and controller.target.alive() and controller.target.loadout.faction != attacker.loadout.faction else null
		arc.show_arc(attacker, weapon, arc_target, controller.manager.phase == TurnManager.Phase.PLANNING and controller.planning.draft != null and controller.planning.draft.valid, controller.manager.battle)
	if controller.selected != null and controller.selected.alive():
		if controller.show_ranges and controller.manager.phase == TurnManager.Phase.PLANNING:
			show_movement_envelope()
		if controller.show_los:
			for enemy in controller.manager.battle.living(1 - controller.selected.loadout.faction):
				var visible_los := TerrainRules.line_of_sight(controller.manager.battle, controller.selected, enemy)
				Primitives.line(controller.overlays, PackedVector3Array([controller.selected.world_position() + Vector3.UP * 0.7, enemy.world_position() + Vector3.UP * 0.7]), ArtPalette.MARK if visible_los else ArtPalette.INVALID, 0.035)
	refresh_draft()

func show_movement_envelope() -> void:
	var root := Node3D.new()
	controller.overlays.add_child(root)
	root.position = Vector3(controller.selected.position.x, 0.025, controller.selected.position.y)
	var radius := controller.selected.loadout.frame.base_move
	if controller.selected.loadout.faction == 0 and controller.manager.battle.catalogue.manoeuvres.has(controller.planning.manoeuvre_id):
		var move: ManoeuvreData = controller.manager.battle.catalogue.manoeuvres[controller.planning.manoeuvre_id]
		radius = MovementRules.maximum_distance(controller.selected, move)
		if move.kind == "vector":
			var points := PackedVector3Array([Vector3.ZERO])
			for i in range(49):
				var angle := controller.selected.facing + deg_to_rad(-move.turn_degrees + 2.0 * move.turn_degrees * i / 48.0)
				points.append(Vector3(sin(angle), 0, -cos(angle)) * radius)
			points.append(Vector3.ZERO)
			Primitives.line(root, points, Color(0.4, 0.85, 0.9, 0.5), 0.025)
			return
	Primitives.ring(root, radius, Color(0.4, 0.85, 0.9, 0.35), 0, 0.02)

func refresh_draft() -> void:
	controller.clear_nodes(controller.drafts_root)
	if controller.planning.draft != null and controller.selected != null and controller.manager.phase == TurnManager.Phase.PLANNING:
		var preview: MovementPreview = PREVIEW_SCENE.instantiate()
		controller.drafts_root.add_child(preview)
		if controller.planning_aircraft():
			# Every alternative stays faintly on the map; hovering one lifts it toward the selected draft.
			for option in controller.planning.option_orders:
				if option.manoeuvre_id != controller.planning.manoeuvre_id:
					preview.show_option(controller.selected, option, option.manoeuvre_id == controller.planning.hover_option)
		preview.show_order(controller.selected, controller.planning.draft, true)
		if controller.planning.choosing_facing:
			preview.show_facing_guide(controller.selected, controller.planning.draft, controller.manager.battle.catalogue.manoeuvres[controller.planning.manoeuvre_id].turn_degrees)

## Two units locked in melee: a bright tie between their bases with a cross where they meet.
func show_engagement(a: UnitState, b: UnitState) -> void:
	var from := Vector3(a.position.x, 0.07, a.position.y)
	var to := Vector3(b.position.x, 0.07, b.position.y)
	Primitives.line(controller.overlays, PackedVector3Array([from, to]), Color(ArtPalette.DRAFT, 0.9), 0.07)
	var middle := (from + to) * 0.5
	var along := (to - from).normalized()
	var side := along.cross(Vector3.UP)
	for direction in [along + side, along - side]:
		var arm: Vector3 = direction.normalized() * 0.22
		Primitives.line(controller.overlays, PackedVector3Array([middle - arm, middle + arm]), ArtPalette.DRAFT, 0.08)
