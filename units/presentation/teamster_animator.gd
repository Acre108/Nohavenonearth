class_name TeamsterAnimator
extends Node
## Presentation only. Never changes UnitState, attack outcomes, or movement orders.
const CLIPS := ["idle", "walk", "turn_left", "turn_right", "ready", "fire_rifle", "fire_missiles", "fire_stake", "melee", "twohand_idle", "twohand_walk", "twohand_ready", "twohand_fire", "twohand_reload", "twohand_turn_left", "twohand_turn_right", "fire_cannon", "fire_breacher"]
## Firing clip for each weapon; unlisted weapons use the melee swing.
const WEAPON_CLIPS := {"ar40_rifle":"fire_rifle", "hornet_pod":"fire_missiles", "pb4_stake":"fire_stake", "br90_rifle":"twohand_fire", "ac30_cannon":"fire_cannon", "sg12_breacher":"fire_breacher"}
const SHOT_TIMES := {"fire_rifle":[0.0, 0.17, 0.34], "fire_missiles":[0.03,0.20,0.37,0.54], "fire_stake":[0.26], "twohand_fire":[0.03,0.33], "fire_cannon":[0.0,0.08,0.17,0.25,0.34,0.42], "fire_breacher":[0.03]}
var player: AnimationPlayer
var model: Node3D
var walking: bool = false
var paused: bool = false
var elapsed: float = -1.0
var cue_index: int = 0
var firing_clip: String = ""
var flashes_enabled: bool = true
var two_handed: bool = false
const CEL_FRAME := 1.0 / 12.0
var pose_accumulator: float = 0.0
var clip_speed: float = 1.0
## Frame profiles share playback and cel timing; equipment cues remain frame-specific.
var clips: Array = CLIPS
var loop_clips: Array = ["idle", "walk", "twohand_idle", "twohand_walk"]
var weapon_clips: Dictionary = WEAPON_CLIPS
var shot_times: Dictionary = SHOT_TIMES
var socket_names: Dictionary = {"ar40_rifle":"Socket_rifle_muzzle", "hornet_pod":"Socket_missile_muzzle", "pb4_stake":"Socket_stake_tip", "br90_rifle":"Socket_br90_muzzle", "ac30_cannon":"Socket_ac30_muzzle", "sg12_breacher":"Socket_sg12_muzzle"}

func setup(root: Node3D, start_idle: bool = true) -> void:
	model = root
	player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null or not player.has_animation("idle"):
		player = null
		return
	for clip in clips:
		if player.has_animation(clip):
			player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR if clip in loop_clips else Animation.LOOP_NONE
	player.animation_finished.connect(_finished)
	# Advance only mech poses at 12 Hz. Cameras, UI and game clocks stay smooth.
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	if start_idle: play("idle", 0.0)

func play(clip: String, _blend: float = 0.10, speed: float = 1.0) -> void:
	if two_handed:
		clip = {"idle":"twohand_idle", "walk":"twohand_walk", "ready":"twohand_ready", "fire_rifle":"twohand_fire", "turn_left":"twohand_turn_left", "turn_right":"twohand_turn_right"}.get(clip, clip)
	if player == null or not player.has_animation(clip): return
	paused = false
	firing_clip = clip if shot_times.has(clip) else ""
	elapsed = -0.001
	cue_index = 0
	pose_accumulator = 0.0
	clip_speed = speed
	# Cross-fading would interpolate the held cels.
	player.play(clip, 0.0, speed)
	player.advance(0)

func walk(speed: float) -> void:
	walking = true
	play("walk", 0.12, speed)

func idle() -> void:
	walking = false
	play("idle", 0.12)

func turn(angle: float) -> void:
	walking = false
	play("turn_left" if angle < 0 else "turn_right")

func fire(weapon_id: String) -> void:
	walking = false
	play(weapon_clips.get(weapon_id, "melee"), 0.03)

func weapon_for_animation(clip: String) -> String:
	for weapon in weapon_clips:
		if weapon_clips[weapon] == clip: return weapon
	return ""

## The weapon whose firing clip this is, or "" for non-firing clips.
static func weapon_for_clip(clip: String) -> String:
	for weapon in WEAPON_CLIPS:
		if WEAPON_CLIPS[weapon] == clip:
			return weapon
	return ""

func socket(weapon_id: String) -> Node3D:
	if model == null: return null
	var name: String = socket_names.get(weapon_id, "Socket_stake_tip")
	return model.find_child(name, true, false) as Node3D

func rest(neutral: bool = false) -> void:
	walking = false
	firing_clip = ""
	if player == null: return
	player.play("twohand_idle" if two_handed and not neutral else "idle", 0)
	player.advance(0)
	player.seek(0, true)
	player.pause()
	paused = true

func set_paused(value: bool) -> void:
	paused = value
	if player == null: return
	if value: player.pause()
	else: player.play(player.assigned_animation, 0.0, clip_speed)

func _finished(_clip: StringName) -> void:
	firing_clip = ""
	if not walking: play("idle")

func _process(delta: float) -> void:
	if player == null or paused: return
	pose_accumulator += delta
	if pose_accumulator >= CEL_FRAME:
		var held_delta := floorf(pose_accumulator / CEL_FRAME) * CEL_FRAME
		pose_accumulator -= held_delta
		player.advance(held_delta)
		_animate_accessories(held_delta)
	if firing_clip.is_empty(): return
	elapsed += delta * absf(player.speed_scale * clip_speed)
	var times: Array = shot_times[firing_clip]
	while cue_index < times.size() and elapsed >= float(times[cue_index]):
		if flashes_enabled: _flash(firing_clip)
		cue_index += 1

func _flash(clip: String) -> void:
	var muzzle := socket(weapon_for_animation(clip))
	if muzzle == null or not muzzle.is_visible_in_tree(): return
	var flash := CelEffects.burst(muzzle, Vector3.ZERO, 0.16 if clip != "fire_stake" else 0.1)
	flash.name = "WeaponFlash"
	if clip == "fire_missiles":
		var smoke := CelEffects.burst(model, model.to_local(muzzle.global_position), 0.24, true)
		var fade := create_tween().set_parallel(true)
		fade.tween_property(smoke, "position:y", smoke.position.y + 0.12, 0.22)
		fade.tween_property(smoke, "modulate:a", 0.0, 0.22)

func _animate_accessories(delta: float) -> void:
	var barrel := model.find_child("Moving_cannon_barrels", true, false) as Node3D
	if barrel != null and player.current_animation == "fire_cannon": barrel.rotation.z -= delta * 30.0
	for pair in [["Moving_br90_magazine", "twohand_reload"], ["Moving_breacher_pump", "fire_breacher"]]:
		var item := model.find_child(pair[0], true, false) as Node3D
		if item == null: continue
		if not item.has_meta("accessory_rest"): item.set_meta("accessory_rest", item.position)
		var offset := Vector3.ZERO
		if player.current_animation == pair[1]:
			var phase := player.current_animation_position / maxf(0.01, player.current_animation_length)
			if pair[1] == "twohand_reload": offset.y = -0.11 * pow(sin(phase * PI), 2)
			else: offset.z = 0.09 * pow(sin(phase * PI), 2)
		item.position = item.get_meta("accessory_rest") + offset
