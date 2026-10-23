class_name AbilityRules
extends RefCounted

# Event context is data, never a scene node. Add future effect handlers here.
const EVENTS: Array[String] = ["before_movement", "after_movement", "before_attack", "after_attack_roll", "when_attacked", "when_damaged", "when_destroyed", "end_of_round"]

static func for_event(battle: BattleState, unit: UnitState, event: String) -> Array[AbilityData]:
	var result: Array[AbilityData] = []
	for id in unit.loadout.pilot.abilities:
		var ability: AbilityData = battle.catalogue.abilities[id]
		if ability.event == event:
			result.append(ability)
	return result

static func apply(battle: BattleState, unit: UnitState, ability_id: String, event: String, context: Dictionary) -> Dictionary:
	if ability_id not in unit.loadout.pilot.abilities or not battle.catalogue.abilities.has(ability_id):
		return {"ok": false, "reason": "Pilot does not have this ability."}
	var ability: AbilityData = battle.catalogue.abilities[ability_id]
	if ability.event != event:
		return {"ok": false, "reason": "Ability cannot be used at this event."}
	if ability.effect == "rotate":
		var delta: float = context.get("degrees", 0.0)
		if absf(unit.ability_rotation + delta) > ability.amount + 0.01:
			return {"ok": false, "reason": "Additional rotation is limited to 45°."}
		if not unit.ability_paid:
			if unit.will < ability.will_cost:
				return {"ok": false, "reason": "Not enough Will."}
			unit.will -= ability.will_cost
			unit.ability_paid = true
		unit.facing += deg_to_rad(delta)
		unit.ability_rotation += delta
		return {"ok": true, "amount": delta}
	if ability.effect == "reroll" or ability.effect == "accuracy":
		if unit.will < ability.will_cost:
			return {"ok": false, "reason": "Not enough Will."}
		unit.will -= ability.will_cost
		return {"ok": true, "amount": ability.amount, "cost": ability.will_cost}
	return {"ok": false, "reason": "Unimplemented ability effect."}
