extends SceneTree

var manager: TurnManager
var report: Dictionary = {"seed": 20261017, "policy": "Existing tactical AI on both sides; Blue enables I Can See It. Newtype rotation is not used by this policy.", "rounds": [], "attacks": [], "activations": [], "movements": [], "log": [], "steps": 0}
var pre_attack_structure: int = 0
var use_newtype: bool = false

func _initialize() -> void:
	run.call_deferred()

func snapshot() -> Array:
	var result: Array = []
	for unit in manager.battle.units:
		result.append(unit.to_dict())
	return result

func run() -> void:
	use_newtype = "--newtype" in OS.get_cmdline_user_args()
	if use_newtype:
		report.policy = "Existing tactical AI on both sides; Blue enables I Can See It and uses Newtype rotation only to gain a legal shot."
	manager = TurnManager.new()
	root.add_child(manager)
	manager.paused = true
	manager.auto_blue = true
	manager.logged.connect(func(message: String) -> void:
		report.log.append({"round": manager.battle.round_number, "message": message})
		print("R%d / %s" % [manager.battle.round_number, message]))
	manager.rule_event.connect(func(event: String, unit: UnitState, context: Dictionary) -> void:
		if event == "before_attack":
			pre_attack_structure = context.target.structure
		if event == "after_movement" and unit.order != null:
			report.movements.append({"round": manager.battle.round_number, "unit": unit.loadout.id,
				"manoeuvre": unit.order.manoeuvre_id, "altitude": unit.altitude,
				"energy_cost": unit.order.energy_cost, "moved": context.moved,
				"energy_after": unit.energy}))
	manager.attack_resolved.connect(func(result: AttackResult) -> void:
		var attacker := manager.battle.unit_by_id(result.attacker_id)
		var defender := manager.battle.unit_by_id(result.defender_id)
		report.attacks.append({"round": manager.battle.round_number, "attacker": result.attacker_id,
			"defender": result.defender_id, "weapon": result.weapon_name, "shots": result.shots,
			"initial_shots": result.initial_shots, "hit_chance": result.hit_chance, "pushed": result.pushed,
			"damage": result.damage, "actual_damage": mini(pre_attack_structure, result.damage),
			"cover": result.cover, "destroyed": result.destroyed, "will_spent": result.will_spent,
			"lock_used": result.lock_used, "rerolls": result.rerolled_indices.size(),
			"attacker_energy_after": attacker.energy, "attacker_will_after": attacker.will,
			"defender_structure_after": defender.structure}))
	manager.setup(report.seed)
	report.battlefield = manager.battle.to_dict().bounds
	report.starting_structure = {}
	for unit in manager.battle.units:
		report.starting_structure[unit.loadout.id] = unit.structure
	var failed := false
	while manager.phase != TurnManager.Phase.BATTLE_OVER and report.steps < 4000:
		report.steps += 1
		if manager.phase == TurnManager.Phase.PLANNING:
			report.rounds.append({"round": manager.battle.round_number, "start": snapshot()})
			for unit in manager.battle.living(0).filter(manager.needs_order):
				var order := TacticalAI.choose_order(manager.battle, unit)
				if order == null or not manager.confirm_order(unit, order):
					failed = true
					break
			if failed:
				break
		if use_newtype and manager.phase == TurnManager.Phase.ACTION and manager.active != null:
			var ace := manager.active
			if ace.loadout.faction == 0 and "newtype" in ace.loadout.pilot.abilities and ace.will > 0 and TacticalAI.choose_attack(manager.battle, ace).is_empty():
				var projected := UnitState.new(ace.loadout)
				projected.position = ace.position
				projected.altitude = ace.altitude
				projected.energy = ace.energy
				ace.copy_stats_to(projected)
				for degrees in [15.0, -15.0, 30.0, -30.0, 45.0, -45.0]:
					projected.facing = ace.facing + deg_to_rad(degrees)
					if not TacticalAI.choose_attack(manager.battle, projected).is_empty():
						manager.rotate_ability(degrees)
						break
		if manager.phase == TurnManager.Phase.ATTACK and manager.active != null:
			var unit := manager.active
			var options: Array = []
			for weapon in unit.loadout.weapons:
				for target in manager.battle.living(1 - unit.loadout.faction):
					options.append({"weapon": weapon.id, "target": target.loadout.id,
						"reason": CombatRules.target_error(manager.battle, unit, target, weapon)})
			report.activations.append({"round": manager.battle.round_number, "unit": unit.loadout.id,
				"state": unit.to_dict(), "options": options})
		manager.advance()
	report.winner = manager.battle.winner()
	report.final_round = manager.battle.round_number
	report.final_state = snapshot()
	report.completed = manager.phase == TurnManager.Phase.BATTLE_OVER
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var file := FileAccess.open("res://artifacts/mock-battle%s.json" % ("-newtype" if use_newtype else ""), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("MOCK BATTLE / winner %d / round %d / %d attacks / completed %s" % [report.winner, report.final_round, report.attacks.size(), report.completed])
	manager.free()
	quit(0 if report.completed and not failed else 1)
