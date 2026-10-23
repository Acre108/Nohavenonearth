extends SceneTree

## AI-vs-AI balance sweep: `--script res://tests/balance_run.gd -- --seeds 150 --start 1`.
## Prints Blue's win rate, average rounds, and damage dealt per weapon.

func _initialize() -> void:
	run.call_deferred()

func arg(name: String, fallback: int) -> int:
	var args := OS.get_cmdline_user_args()
	var index := args.find(name)
	return int(args[index + 1]) if index >= 0 and index + 1 < args.size() else fallback

func run() -> void:
	var seeds := arg("--seeds", 60)
	var start := arg("--start", 1)
	var wins := [0, 0, 0]
	var rounds := 0
	var weapons := {}
	var first_kill_rounds := 0
	var incomplete := 0
	for seed_value in range(start, start + seeds):
		var manager := TurnManager.new()
		root.add_child(manager)
		manager.paused = true
		manager.auto_blue = true
		var first_kill := [0]
		manager.attack_resolved.connect(func(result: AttackResult) -> void:
			var entry: Dictionary = weapons.get(result.weapon_name, {"attacks": 0, "damage": 0})
			entry.attacks += 1
			entry.damage += result.damage
			weapons[result.weapon_name] = entry
			if result.destroyed and first_kill[0] == 0:
				first_kill[0] = manager.battle.round_number)
		manager.setup(seed_value)
		var ticks := 0
		while manager.phase != TurnManager.Phase.BATTLE_OVER and ticks < 6000:
			ticks += 1
			if manager.phase == TurnManager.Phase.PLANNING:
				for unit in manager.battle.living(0).filter(manager.needs_order):
					manager.confirm_order(unit, TacticalAI.choose_order(manager.battle, unit))
			manager.advance()
		if manager.phase != TurnManager.Phase.BATTLE_OVER:
			incomplete += 1
		else:
			wins[manager.battle.winner()] += 1
		rounds += manager.battle.round_number
		first_kill_rounds += first_kill[0]
		manager.free()
	print("BALANCE / %d seeds from %d / Blue %d%% / Red %d%% / draws %d / incomplete %d / avg %.1f rounds / first kill round %.1f" % [seeds, start, roundi(100.0 * wins[0] / seeds), roundi(100.0 * wins[1] / seeds), wins[2], incomplete, float(rounds) / seeds, float(first_kill_rounds) / seeds])
	var names := weapons.keys()
	names.sort()
	for weapon_name in names:
		var entry: Dictionary = weapons[weapon_name]
		print("WEAPON / %-24s %5d attacks / %.1f damage each" % [weapon_name, entry.attacks, float(entry.damage) / entry.attacks])
	quit()
