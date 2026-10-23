class_name AttackResult
extends RefCounted

enum Shot { MISS, GLANCE, HIT, CRIT }

var attacker_id: String = ""
var defender_id: String = ""
var weapon_name: String = ""
## Final outcome per shot, and the outcome before any reroll.
var shots: Array[int] = []
var initial_shots: Array[int] = []
var rerolled_indices: Array[int] = []
var hit_chance: float = 0.0
var crit_chance: float = 0.0
var glance_chance: float = 0.0
var weapon_damage: int = 0
var damage: int = 0
var cover: int = 0
var armour: int = 0
var destroyed: bool = false
var will_spent: int = 0
var lock_used: bool = false
var pushed: bool = false
## A foe's attack taken early, at +20%, against a unit breaking off from melee.
var parting: bool = false
var charged: bool = false

func count(outcome: int) -> int:
	return shots.count(outcome)

## Shots that connected in any way, including glancing hits.
func connected() -> int:
	return shots.size() - count(Shot.MISS)

## Plain-language log line; the exact rule numbers are in the unit's Full stats window.
func summary() -> String:
	var parts: PackedStringArray = ["%d/%d shot%s hit" % [count(Shot.HIT) + count(Shot.CRIT), shots.size(), "" if shots.size() == 1 else "s"]]
	if count(Shot.CRIT) > 0:
		parts.append("%d crit" % count(Shot.CRIT))
	if count(Shot.GLANCE) > 0:
		parts.append("%d glancing" % count(Shot.GLANCE))
	var text := "%s: %s → %d damage" % [weapon_name, ", ".join(parts), damage]
	var notes: PackedStringArray = []
	if cover > 0:
		notes.append("target in cover")
	if armour > 0 and connected() > count(Shot.CRIT):
		notes.append("armour −%d per hit" % armour)
	if not notes.is_empty():
		text += " (%s)" % ", ".join(notes)
	return text + (". DESTROYED." if destroyed else ".")
