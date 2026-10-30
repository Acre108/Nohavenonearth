class_name KestrelAnimator
extends TeamsterAnimator
## Airframe-specific clips. All displacement stays inside the visual model.
const KESTREL_CLIPS := ["idle", "walk", "turn_left", "turn_right", "ready", "fire_rifle", "fire_missiles", "rifle_reload", "knife_deploy", "knife_ready", "knife_stow", "fire_knife", "melee", "hover", "flight", "takeoff", "land", "evade_left", "evade_right"]
const MENU := [["idle","Idle"],["walk","Walk"],["turn_left","Turn left"],["turn_right","Turn right"],
	["ready","Weapon ready"],["fire_rifle","Fire LR-3"],["fire_missiles","Fire AGM-M"],["rifle_reload","Rifle reload"],
	["knife_deploy","Deploy knife"],["knife_ready","Knife ready"],["knife_stow","Stow knife"],["fire_knife","Knife strike"],
	["melee","Melee"],["hover","Hover"],["flight","Forward flight"],["takeoff","Takeoff"],["land","Landing"],
	["evade_left","Evade left"],["evade_right","Evade right"]]
var airborne: bool = false
var movement_speed: float = 1.0

func _init() -> void:
	clips = KESTREL_CLIPS
	loop_clips = ["idle", "walk", "knife_ready", "hover", "flight"]
	weapon_clips = {"lr3_rifle":"fire_rifle", "agm_stores":"fire_missiles", "vb2_knife":"fire_knife"}
	shot_times = {"fire_rifle":[5.0/30.0,15.0/30.0], "fire_missiles":[5.0/30.0,11.0/30.0,17.0/30.0,23.0/30.0]}
	socket_names = {"lr3_rifle":"Socket_rifle_muzzle", "agm_stores":"Socket_missile_0", "vb2_knife":"Socket_knife_tip", "hands_medium":"Joint_right_wrist_actuator"}

func play(clip: String, blend: float = .10, speed: float = 1.0) -> void:
	if clip in ["hover", "flight", "takeoff"]: airborne = true
	elif clip in ["idle", "walk", "land"]: airborne = false
	super.play(clip, blend, speed)

func walk(speed: float) -> void:
	walking = true
	movement_speed = speed
	play("flight" if airborne else "walk", 0, speed)

func idle() -> void:
	walking = false
	play("hover" if airborne else "idle", 0)

func turn(angle: float) -> void:
	walking = false
	if airborne: play("evade_left" if angle < 0 else "evade_right")
	else: super.turn(angle)

func move(speed: float, in_air: bool) -> void:
	var changed := airborne != in_air
	movement_speed = speed
	airborne = in_air
	walking = true
	if changed: play("takeoff" if airborne else "land")
	else: walk(speed)

func socket(weapon_id: String) -> Node3D:
	if weapon_id == "agm_stores" and model != null:
		# Launch order alternates left/right, then the second store on each side.
		var order := [0,2,1,3]
		return model.find_child("Socket_missile_" + str(order[mini(cue_index,3)]), true, false) as Node3D
	return super.socket(weapon_id)

func _finished(clip: StringName) -> void:
	firing_clip = ""
	if clip == &"knife_deploy":
		play("knife_ready")
	elif clip == &"takeoff" or clip == &"land":
		airborne = clip == &"takeoff"
		if walking: walk(movement_speed)
		else: idle()
	elif not walking:
		idle()
