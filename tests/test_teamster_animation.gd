extends "res://tests/test_suite.gd"

var holder: Node3D
var animator: TeamsterAnimator

func sample(clip: String, at: float) -> void:
	animator.play(clip, 0)
	animator.player.seek(at, true)

func joint(name: String) -> Node3D:
	return holder.find_child("Joint_" + name, true, false) as Node3D

func run() -> void:
	holder = Node3D.new()
	root.add_child(holder)
	UnitModelFactory.build_model(holder, "ground", ArtPalette.FRIEND, "m9_teamster")
	animator = TeamsterAnimator.new()
	holder.add_child(animator)
	animator.setup(holder)
	check(animator.player != null, "Teamster imports an AnimationPlayer")
	if animator.player == null:
		quit(1)
		return
	for clip in TeamsterAnimator.CLIPS:
		check(animator.player.has_animation(clip), clip + " imports")
		var animation := animator.player.get_animation(clip)
		check(animation.length > 0.3 and animation.get_track_count() >= 26, clip + " contains a full joint pose")
	check(holder.find_children("Region_*", "Node3D", true, false).size() == 8, "Rig preserves eight workshop regions")
	for mesh in holder.find_children("*", "MeshInstance3D", true, false):
		check(mesh.skin == null, String(mesh.name) + " remains rigid")
	var rest := joint("left_knee_drive").transform
	sample("walk",0.3)
	check(not joint("left_knee_drive").transform.is_equal_approx(rest), "Walk bends the knee")
	check(joint("left_knee_drive").rotation.is_equal_approx(joint("left_knee_armour").rotation), "Armour hinge follows drive hinge")
	var left_ankle := joint("left_ankle_drive").global_position
	var right_ankle := joint("right_ankle_drive").global_position
	check(absf(left_ankle.y - right_ankle.y) > 0.025, "Swing foot lifts separately from planted foot")
	sample("walk",0)
	var loop_start := joint("left_hip").transform
	sample("walk",1.2)
	check(loop_start.is_equal_approx(joint("left_hip").transform), "Walk closes without a pose jump")
	sample("idle",0)
	var rifle_rest := animator.socket("ar40_rifle").global_position
	var slide_rest := joint("stake_slide").position
	sample("fire_rifle",2.0/30.0)
	check(animator.socket("ar40_rifle").global_position.distance_to(rifle_rest) > 0.01, "Rifle recoils at its actual muzzle")
	sample("fire_stake",9.0/30.0)
	check(joint("stake_slide").position.distance_to(slide_rest) > 0.10, "Stake piston extends during firing")
	sample("fire_missiles",8.0/30.0)
	check(joint("missile_cradle").rotation.length() > 0.001, "Missile cradle reacts to launch")
	sample("idle",0)
	check(joint("stake_slide").position.is_equal_approx(slide_rest), "Interrupting firing restores the piston")
	animator.fire("ar40_rifle")
	check(animator.player.current_animation == "fire_rifle", "Rifle weapon ID selects its firing clip")
	animator.fire("hornet_pod")
	check(animator.player.current_animation == "fire_missiles", "Missile weapon ID selects its firing clip")
	animator.fire("pb4_stake")
	check(animator.player.current_animation == "fire_stake", "Stake weapon ID selects its firing clip")
	animator.fire("hands_medium")
	check(animator.player.current_animation == "melee", "Hands select a melee clip")
	animator.walk(1.2)
	check(animator.player.current_animation == "walk", "Movement selects locomotion")
	animator.turn(-0.5)
	check(animator.player.current_animation == "turn_left", "Turning chooses the matching pivot clip")
	animator.rest()
	check(not animator.player.is_playing(), "Rest freezes a neutral inspection pose")
	holder.free()
	finish()
