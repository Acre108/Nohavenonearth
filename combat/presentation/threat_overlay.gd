class_name ThreatOverlay
extends TargetingOverlay

## Planning aid for one enemy: faint sectors where it can shoot from where it stands now, and a dashed ring
## for the furthest it could possibly hit after moving this round. Outside the ring is safe this round.
const THREAT := Color("f48478")

## fan: this enemy's offset from the middle of the enemy list, so clustered enemies label different ring edges.
func show_threat(battle: BattleState, unit: UnitState, fan: float = 0.0) -> void:
	position = Vector3(unit.position.x, 0.03, unit.position.y)
	var camera := get_viewport().get_camera_3d()
	var zoom := maxf(1.0, TacticalCamera.view_height(camera, global_position) / 17.5)
	for weapon in unit.loadout.weapons:
		if weapon.energy_cost > unit.energy:
			continue
		var radii := CombatRules.horizontal_range(weapon, 0, CombatRules.reach_allowance(weapon, unit))
		sector(unit.facing, weapon.arc, radii.x, radii.y, Color(THREAT, 0.06))
		Primitives.line(self, arc_points(unit.facing, weapon.arc, radii.y), Color(THREAT, 0.4), 0.03)
	var reach := -1.0
	for band in UnitState.ALTITUDES.size():
		reach = maxf(reach, CombatRules.threat_reach(battle, unit, band))
	if reach <= 0:
		return
	for i in range(48):
		var a := TAU * i / 48.0
		Primitives.line(self, PackedVector3Array([direction(a) * reach, direction(a + TAU / 96.0) * reach]), Color(THREAT, 0.5), 0.04)
	# Label the edge facing the table centre: it stays on the table and differs per enemy, so labels don't stack.
	var inward := battle.bounds.get_center() - unit.position
	var label_angle := (atan2(inward.x, -inward.y) if inward.length() > 0.5 else 0.0) + deg_to_rad(35.0) * fan
	caption("%s REACH %.1f" % [unit.loadout.callsign.split(" / ")[1], reach], direction(label_angle) * reach + Vector3.UP * 0.2, Color(THREAT, 0.85), zoom)
