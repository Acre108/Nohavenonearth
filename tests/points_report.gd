extends SceneTree

## Prints every frame's cost against its lore target, every weapon's cost, and each deployed unit's total.
## `--script res://tests/points_report.gd`

func _initialize() -> void:
	var catalogue := Catalogue.new()
	var costs := PointCosts.new()
	print("FRAMES  (frame cost, hands included; the target applies to frame + weapons)")
	for frame: FrameData in catalogue.frames.values():
		var parts := costs.frame_breakdown(frame, catalogue)
		var items: PackedStringArray = []
		for key in parts:
			items.append("%s %.1f" % [key, parts[key]])
		var cost := costs.frame_cost(frame, catalogue)
		print("  %-26s Gen %d %-7s target %5.1f / frame %5.1f   %s" % [frame.display_name, frame.generation, frame.tier, costs.mech_target(frame), cost, ", ".join(items)])
	print("WEAPONS")
	for weapon: WeaponData in catalogue.weapons.values():
		print("  %-26s %5.1f   %d × %d %s AP %d aim %+d %s%s" % ["%s (%s)" % [weapon.display_name, weapon.size], costs.weapon_cost(weapon), weapon.shots, weapon.damage, weapon.damage_type, weapon.armour_piercing, int(weapon.aim_bonus), "melee " if weapon.melee else "", "heavy" if weapon.heavy else ""])
	print("UNITS  (mech = frame + weapons; pilot separate)")
	for side in [0, 1]:
		var side_total := 0.0
		for loadout in catalogue.loadouts:
			if loadout.faction != side:
				continue
			var mech := costs.mech_cost(loadout, catalogue)
			var pilot := costs.pilot_cost(loadout.pilot)
			side_total += mech + pilot
			var target := costs.mech_target(loadout.frame)
			print("  %-14s %-26s mech %6.1f vs target %5.1f (%+3.0f%%) + pilot %5.1f = %6.1f" % [loadout.callsign, loadout.frame.display_name, mech, target, 100.0 * (mech - target) / target, pilot, mech + pilot])
		print("  %s TOTAL %.1f" % ["BLUE" if side == 0 else "RED", side_total])
	quit()
