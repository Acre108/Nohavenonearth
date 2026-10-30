class_name PointCosts
extends RefCounted

## Prices frames, weapons and pilots from what they do in combat, using the weights in costs.json.
## A design's lore (generation and tier) sets the points it should cost; matchups at equal points then
## test the weights, and the weights, not individual mechs, are what get tuned.
const PATH := "res://data/catalogues/costs.json"
var weights: Dictionary

func _init(path: String = PATH) -> void:
	weights = JSON.parse_string(FileAccess.get_file_as_string(path))

## The points a mech of this generation and tier is meant to cost: frame, hands and weapons, without the pilot.
func mech_target(frame: FrameData) -> float:
	return float(weights.generation_budget.get(str(frame.generation), 100)) * float(weights.tier_multiplier.get(frame.tier, 1.0))

func frame_cost(frame: FrameData, catalogue: Catalogue = null) -> float:
	return frame_breakdown(frame, catalogue).values().reduce(func(total: float, part: float) -> float: return total + part, 0.0)

## Itemised so the report can show where a frame's points go.
func frame_breakdown(frame: FrameData, catalogue: Catalogue = null) -> Dictionary:
	var w: Dictionary = weights.frame
	var parts := {
		"structure": frame.structure * w.structure_per_point,
		"armour": frame.armour * w.armour_per_point + (w.armour_type if frame.armour_type != "none" and frame.armour > 0 else 0.0),
		"size": float(w.size.get(frame.size_class, 0.0)),
		"mobility": frame.base_move * w.move_per_unit,
		"energy": frame.energy_capacity * w.energy_capacity_per_point + frame.energy_recharge * w.energy_recharge_per_point,
		"stats": 0.0,
	}
	if frame.movement_type == "flying":
		parts.mobility += w.flight
	elif frame.movement_type == "aircraft":
		parts.mobility += w.aircraft
	# Ground and Charge come with legs; every other manoeuvre is an extra option.
	parts.mobility += w.manoeuvre * frame.manoeuvres.filter(func(id: String) -> bool: return id not in ["ground", "charge"]).size()
	for stat in UnitState.STAT_NAMES:
		parts.stats += (float(frame.stat_bonuses.get(stat, 0.0)) + float(frame.stat_fractions.get(stat, 0.0))) * float(w.stat_bonus_per_point.get(stat, 0.0))
	if catalogue != null and not frame.default_melee.is_empty():
		parts["hands"] = weapon_cost(catalogue.weapons[frame.default_melee])
	return parts

## Expected damage per attack against the reference target, times the range and arc it can use it from.
func weapon_cost(weapon: WeaponData) -> float:
	var w: Dictionary = weights.weapon
	var target: Dictionary = w.reference_target
	var attacker: Dictionary = w.reference_attacker
	var hit := clampf(CombatRules.BASE_HIT + CombatRules.PER_POINT * (float(attacker.attack) - float(target.reflex)) + weapon.aim_bonus + SizeClass.HIT_MODIFIER.get(target.size, 0.0), CombatRules.MIN_HIT, CombatRules.MAX_HIT)
	var crit := float(attacker.precision) * CombatRules.CRIT_PER_PRECISION / 100.0
	var glance := CombatRules.glance_chance(weapon, hit) / 100.0
	var armour := maxi(0, int(target.armour) - weapon.armour_piercing)
	var per_shot := hit / 100.0 * ((1.0 - crit) * CombatRules.shot_damage(weapon, armour, AttackResult.Shot.HIT) + crit * CombatRules.shot_damage(weapon, armour, AttackResult.Shot.CRIT)) + glance * CombatRules.shot_damage(weapon, armour, AttackResult.Shot.GLANCE)
	var reach: float = w.melee_range_factor if weapon.melee else w.range_base + w.range_per_unit * weapon.range_max - w.minimum_range_per_unit * weapon.range_min
	var arc := 1.0
	for key in w.arc_factor:
		if weapon.arc >= float(key):
			arc = maxf(arc, float(w.arc_factor[key]))
	return maxf(1.0, per_shot * weapon.shots * w.points_per_damage * reach * arc - weapon.energy_cost * w.energy_per_point)

func pilot_cost(pilot: PilotData) -> float:
	var w: Dictionary = weights.pilot
	var total := 0.0
	for stat in pilot.stats:
		total += float(pilot.stats[stat]) * float(w.stat_per_point.get(stat, 0.0))
	for ability in pilot.abilities:
		total += float(w.ability.get(ability, 0.0))
	return total

## Frame (with hands) plus carried weapons; the pilot is priced separately.
func mech_cost(loadout: UnitLoadout, catalogue: Catalogue) -> float:
	var total := frame_cost(loadout.frame, catalogue)
	for weapon in loadout.weapons:
		if weapon.id != loadout.frame.default_melee:
			total += weapon_cost(weapon)
	return total
