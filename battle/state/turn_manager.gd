class_name TurnManager
extends Node

signal state_changed
signal phase_changed
signal active_changed(unit: UnitState)
signal unit_moved(unit: UnitState, path: PackedVector2Array)
signal attack_resolved(result: AttackResult)
signal logged(message: String)
signal rule_event(event: String, unit: UnitState, context: Dictionary)

enum Phase { PLANNING, REVEAL, MOVEMENT, ACTION, ATTACK, END, BATTLE_OVER }
const PHASE_NAMES: Array[String] = ["PLANNING", "REVEAL", "MOVEMENT", "ACTION", "ATTACK", "END", "BATTLE OVER"]
var battle: BattleState
var phase: Phase = Phase.PLANNING
var active: UnitState
var movement_queue: Array[UnitState] = []
var attack_queue: Array[UnitState] = []
var queue: Array[UnitState] = []
var cursor: int = 0
var ai_enabled: bool = true
var paused: bool = false
var reveal_enemy: bool = false
var auto_blue: bool = false
var timer: float = 0.0
var resolution_delay: float = 0.8
# Extra pause after an attack so its effects play out and its result can be read.
var attack_hold: float = 1.4
var hold: float = 0.0
var round_attacks: Array[AttackResult] = []
var log_lines: Array[String] = []

func setup(seed_value: int = -1, catalogue: Catalogue = null) -> void:
	battle = BattleState.new(Catalogue.new() if catalogue == null else catalogue, seed_value)
	log_lines.clear()
	active = null
	log_message("Destroy every Red unit to win.")
	begin_planning()

func _process(delta: float) -> void:
	if battle == null or paused or phase in [Phase.PLANNING, Phase.BATTLE_OVER]:
		return
	if phase in [Phase.ACTION, Phase.ATTACK] and active != null and active.loadout.faction == 0 and not auto_blue:
		return
	# The reveal is the payoff of simultaneous orders; the player continues when ready.
	if phase == Phase.REVEAL and not auto_blue:
		return
	timer += delta
	if timer >= resolution_delay + hold:
		timer = 0.0
		hold = 0.0
		advance()

func log_message(message: String) -> void:
	log_lines.append(message)
	if log_lines.size() > 250:
		log_lines.pop_front()
	logged.emit(message)

const HOLD_PREFIX := "Nothing in range, holding fire: "
const NO_ACTION_PREFIX := "No lock in range or power to use, skipping action: "

func log_hold(unit: UnitState) -> void:
	log_grouped(HOLD_PREFIX, unit)

## Consecutive skipped activations share one line instead of flooding the log.
func log_grouped(prefix: String, unit: UnitState) -> void:
	if not log_lines.is_empty() and log_lines[-1].begins_with(prefix):
		log_lines[-1] += ", " + unit.loadout.callsign
		logged.emit(log_lines[-1])
	else:
		log_message(prefix + unit.loadout.callsign)

func set_phase(value: Phase) -> void:
	phase = value
	timer = 0.0
	phase_changed.emit()
	state_changed.emit()

func begin_planning() -> void:
	active = null
	hold = 0.0
	round_attacks.clear()
	movement_queue.clear()
	attack_queue.clear()
	MeleeRules.clean(battle)
	MeleeRules.face_foes(battle)
	for unit in battle.living():
		unit.order = null
		unit.action_used = false
		unit.attacked = false
		unit.ability_paid = false
		unit.ability_rotation = 0.0
		unit.charge_target = ""
		clean_locks(unit)
	# Enemy choices are made before the player plans, without reading player orders.
	if ai_enabled:
		for unit in battle.living(1):
			unit.order = TacticalAI.choose_order(battle, unit)
	log_message("ROUND %d · Give each Blue unit a move. Red has already chosen in secret." % battle.round_number)
	set_phase(Phase.PLANNING)

func clean_locks(unit: UnitState) -> void:
	var valid_locks: Array[String] = []
	for id in unit.locks:
		var target := battle.unit_by_id(id)
		if target != null and target.alive():
			valid_locks.append(id)
	unit.locks = valid_locks
	while unit.locks.size() > UnitState.LOCK_CAPACITY:
		unit.locks.pop_front()

func can_commit() -> bool:
	if phase != Phase.PLANNING:
		return false
	for unit in battle.living(0):
		# Units locked in melee have no movement to plan.
		if MeleeRules.is_engaged(battle, unit):
			continue
		if unit.order == null or not unit.order.confirmed or not MovementRules.validation_error(battle, unit, unit.order).is_empty():
			return false
	return not battle.living(0).is_empty()

## Units that still need a movement order this round.
func needs_order(unit: UnitState) -> bool:
	return unit.alive() and unit.order == null and not MeleeRules.is_engaged(battle, unit)

func confirm_order(unit: UnitState, order: MovementOrder) -> bool:
	if phase != Phase.PLANNING or unit.loadout.faction != 0 or order == null:
		return false
	order.reason = MovementRules.validation_error(battle, unit, order)
	order.valid = order.reason.is_empty()
	if not order.valid:
		return false
	order.confirmed = true
	unit.order = order
	state_changed.emit()
	return true

func commit() -> bool:
	if not can_commit():
		return false
	# Quicker pilots move first, claiming contested space, and fire first.
	movement_queue = battle.initiative(false)
	attack_queue = movement_queue.duplicate()
	log_message("Orders revealed. Quicker pilots (higher Reflex) move and fire first.")
	for unit in battle.living():
		if MeleeRules.is_engaged(battle, unit):
			log_message("%s is locked in melee and holds its ground." % unit.loadout.callsign)
		elif unit.order != null and not unit.order.target_id.is_empty():
			log_message("%s plans to CHARGE %s." % [unit.loadout.callsign, battle.unit_by_id(unit.order.target_id).loadout.callsign])
		elif unit.order != null:
			log_message("%s plans %s at %s altitude." % [unit.loadout.callsign, battle.catalogue.manoeuvres[unit.order.manoeuvre_id].display_name, UnitState.ALTITUDES[unit.order.altitude].capitalize()])
	set_phase(Phase.REVEAL)
	return true

func advance() -> void:
	if check_victory():
		return
	match phase:
		Phase.PLANNING:
			if can_commit():
				commit()
		Phase.REVEAL:
			queue = movement_queue.duplicate()
			cursor = 0
			set_phase(Phase.MOVEMENT)
		Phase.MOVEMENT:
			if cursor < queue.size():
				active = queue[cursor]
				cursor += 1
				if active.alive():
					active_changed.emit(active)
					rule_event.emit("before_movement", active, {})
					var movement := MovementRules.resolve(battle, active)
					log_message(movement.message)
					if movement.moved:
						unit_moved.emit(active, movement.path)
					if not active.alive():
						rule_event.emit("when_destroyed", active, {"withdrawal": true})
					rule_event.emit("after_movement", active, movement)
				state_changed.emit()
			else:
				start_action()
		Phase.ACTION:
			if active != null:
				if active.loadout.faction == 1 or auto_blue:
					if ai_enabled or active.loadout.faction == 0:
						if TacticalAI.should_break_off(battle, active):
							perform_break_off(active)
						else:
							var target := TacticalAI.nearest(battle.living(1 - active.loadout.faction), active.position)
							if CombatRules.take_lock(battle, active, target):
								log_message("%s locks on to %s." % [active.loadout.callsign, target.loadout.callsign])
				end_action()
		Phase.ATTACK:
			if active != null:
				if (active.loadout.faction == 1 and ai_enabled) or auto_blue:
					var choice := TacticalAI.choose_attack(battle, active)
					if not choice.is_empty():
						fire(choice.weapon, choice.target, auto_blue, choice.push)
						return
				pass_attack()
		Phase.END:
			for unit in battle.living():
				unit.energy = minf(unit.loadout.frame.energy_available(), unit.energy + unit.loadout.frame.energy_recharge)
				rule_event.emit("end_of_round", unit, {})
			battle.round_number += 1
			log_message("End of round · Energy refills a little (Will does not).")
			begin_planning()

func start_action() -> void:
	queue = attack_queue.duplicate()
	cursor = 0
	set_phase(Phase.ACTION)
	next_active()

func next_active() -> void:
	active = null
	while cursor < queue.size():
		var candidate := queue[cursor]
		cursor += 1
		# A parting strike already used this unit's attack for the round.
		if phase == Phase.ATTACK and candidate.attacked:
			continue
		if candidate.alive():
			if phase == Phase.ATTACK and not CombatRules.has_legal_attack(battle, candidate):
				candidate.attacked = true
				log_hold(candidate)
				continue
			# No lock in range and no power to spend: don't make anyone click through an empty activation.
			if phase == Phase.ACTION and not CombatRules.has_action_choice(battle, candidate):
				log_grouped(NO_ACTION_PREFIX, candidate)
				continue
			active = candidate
			break
	if active == null:
		if phase == Phase.ACTION:
			queue = attack_queue.duplicate()
			cursor = 0
			set_phase(Phase.ATTACK)
			next_active()
		elif phase == Phase.ATTACK:
			set_phase(Phase.END)
		return
	timer = 0.0
	active_changed.emit(active)
	state_changed.emit()

func end_action() -> void:
	if phase == Phase.ACTION:
		next_active()

func lock_target(target: UnitState) -> bool:
	if phase != Phase.ACTION or active == null or active.loadout.faction != 0:
		return false
	if CombatRules.take_lock(battle, active, target):
		log_message("%s locks on to %s." % [active.loadout.callsign, target.loadout.callsign])
		if not CombatRules.has_action_choice(battle, active):
			end_action()
		else:
			state_changed.emit()
		return true
	return false

## Player command: the active Blue unit breaks off from melee, using its action.
func break_off() -> bool:
	if phase != Phase.ACTION or active == null or active.loadout.faction != 0:
		return false
	if not perform_break_off(active):
		return false
	if phase == Phase.ACTION:
		end_action()
	return true

## Each foe takes its attack early as a parting strike, then the unit backs away. Does not end the activation.
func perform_break_off(unit: UnitState) -> bool:
	var outcome := MeleeRules.break_off(battle, unit)
	if not outcome.ok:
		log_message(outcome.reason)
		state_changed.emit()
		return false
	log_message("%s tries to break off from melee." % unit.loadout.callsign)
	for result: AttackResult in outcome.strikes:
		log_message("%s takes a parting strike with %s." % [battle.unit_by_id(result.attacker_id).loadout.callsign, result.weapon_name])
		log_message(result.summary())
		if result.damage > 0:
			rule_event.emit("when_damaged", unit, {"result": result})
		round_attacks.append(result)
		hold = attack_hold
		attack_resolved.emit(result)
	if not unit.alive():
		if battle.add_wreck(unit):
			log_message("%s leaves a wreck: ground units behind it get cover." % unit.loadout.callsign)
		rule_event.emit("when_destroyed", unit, {"result": outcome.strikes[-1]})
	log_message(outcome.message)
	if outcome.moved:
		unit_moved.emit(unit, outcome.path)
	MeleeRules.clean(battle)
	state_changed.emit()
	check_victory()
	return true

func rotate_ability(degrees: float) -> void:
	if phase != Phase.ACTION or active == null or active.loadout.faction != 0:
		return
	var effect := AbilityRules.apply(battle, active, "newtype", "after_movement", {"degrees": degrees})
	if effect.ok:
		log_message("%s uses Newtype Reflexes to turn %+.0f° (%d Will left)." % [active.loadout.callsign, active.ability_rotation, active.will])
	else:
		log_message(effect.reason)
	state_changed.emit()

func fire(weapon: WeaponData, target: UnitState, use_will: bool = false, push: bool = false) -> bool:
	if phase != Phase.ATTACK or active == null:
		return false
	rule_event.emit("before_attack", active, {"target": target, "weapon": weapon})
	rule_event.emit("when_attacked", target, {"attacker": active})
	var result := CombatRules.resolve(battle, active, target, weapon, use_will, func(rolled: AttackResult) -> void: rule_event.emit("after_attack_roll", active, {"result": rolled}), push)
	if result == null:
		return false
	log_message("%s fires %s at %s." % [active.loadout.callsign, weapon.display_name, target.loadout.callsign])
	log_message(result.summary())
	if result.damage > 0:
		rule_event.emit("when_damaged", target, {"result": result})
	if result.destroyed:
		if battle.add_wreck(target):
			log_message("%s leaves a wreck: ground units behind it get cover." % target.loadout.callsign)
		rule_event.emit("when_destroyed", target, {"result": result})
		MeleeRules.clean(battle)
	round_attacks.append(result)
	hold = attack_hold + (0.6 if result.destroyed else 0.0)
	attack_resolved.emit(result)
	state_changed.emit()
	if not check_victory():
		next_active()
	return true

func pass_attack() -> void:
	if phase != Phase.ATTACK or active == null:
		return
	active.attacked = true
	hold = 0.0
	log_message("%s holds fire." % active.loadout.callsign)
	next_active()

func check_victory() -> bool:
	if battle == null or battle.winner() < 0:
		return false
	if phase != Phase.BATTLE_OVER:
		active = null
		var winner := battle.winner()
		log_message("BLUE VICTORY / Airspace secured." if winner == 0 else ("RED VICTORY / Blue detachment lost." if winner == 1 else "DRAW / Both detachments destroyed."))
		set_phase(Phase.BATTLE_OVER)
	return true

func set_ai(enabled: bool) -> void:
	ai_enabled = enabled
	if phase == Phase.PLANNING:
		for unit in battle.living(1):
			unit.order = TacticalAI.choose_order(battle, unit) if enabled else null
	state_changed.emit()

func debug_changed(unit: UnitState) -> void:
	clean_locks(unit)
	MeleeRules.clean(battle)
	if unit.alive():
		unit.withdrawn = false
		battle.remove_wreck(unit)
	else:
		battle.add_wreck(unit)
	if phase == Phase.PLANNING and unit.order != null:
		unit.order.valid = MovementRules.validation_error(battle, unit, unit.order).is_empty()
		if not unit.order.valid:
			unit.order = null
	if not check_victory() and active == unit and not unit.alive() and phase in [Phase.ACTION, Phase.ATTACK]:
		next_active()
	elif phase == Phase.ATTACK and active != null and not CombatRules.has_legal_attack(battle, active):
		active.attacked = true
		log_hold(active)
		next_active()
	state_changed.emit()
