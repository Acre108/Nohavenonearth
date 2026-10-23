class_name BattleTelemetry
extends BattleUISection

var log_text: RichTextLabel

func log_bbcode(lines: Array) -> String:
	var tags := {}
	for unit in controller.manager.battle.units:
		tags[unit.loadout.callsign] = "[color=#%s]%s[/color]" % [(BLUE if unit.loadout.faction == 0 else RED).to_html(false), unit.loadout.callsign]
	var out: PackedStringArray = []
	for line in lines:
		var text: String = line.replace("[", "[lb]")
		for callsign in tags:
			text = text.replace(callsign, tags[callsign])
		text = text.replace("DESTROYED", "[b][color=#%s]DESTROYED[/color][/b]" % GOLD.to_html(false))
		if text.begins_with("ROUND ") or "VICTORY" in text or text.begins_with("DRAW"):
			text = "[b]%s[/b]" % text
		elif text.begins_with(TurnManager.HOLD_PREFIX) or text.begins_with(TurnManager.NO_ACTION_PREFIX) or text.begins_with("End of round"):
			text = "[color=#%s]%s[/color]" % [MUTED.to_html(false), text]
		out.append(text)
	return "\n".join(out)
