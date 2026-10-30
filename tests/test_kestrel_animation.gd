extends "res://tests/test_suite.gd"

var holder: Node3D
var animator: KestrelAnimator

func joint(name: String) -> Node3D:
	return holder.find_child("Joint_"+name,true,false) as Node3D

func sample(clip: String, at: float) -> void:
	animator.play(clip,0)
	animator.player.seek(at,true)

func sole_height(side: String) -> float:
	var mesh := holder.find_child(("L" if side == "left" else "R")+"_Sole",true,false) as MeshInstance3D
	var height := INF
	for corner in range(8): height = minf(height,(mesh.global_transform*mesh.get_aabb().get_endpoint(corner)).y)
	return height

func run() -> void:
	holder = Node3D.new()
	root.add_child(holder)
	UnitModelFactory.build_model(holder,"flying",ArtPalette.FRIEND,"hx7_kestrel")
	animator = KestrelAnimator.new()
	holder.add_child(animator)
	animator.setup(holder,false)
	animator.flashes_enabled = false
	check(animator.player != null,"Kestrel imports its AnimationPlayer")
	if animator.player == null:
		quit(1)
		return
	for clip in KestrelAnimator.KESTREL_CLIPS:
		check(animator.player.has_animation(clip),clip+" imports")
		if animator.player.has_animation(clip):
			var animation := animator.player.get_animation(clip)
			check(animation.length >= 0.79 and animation.get_track_count() >= 27,clip+" contains a full mechanical pose")
	check(holder.find_children("Region_*","Node3D",true,false).size() == 8,"Rig retains all workshop regions")
	check(holder.find_children("Component_*","Node3D",true,false).size() == 14,"Rig retains all workshop component roots")
	for mesh in holder.find_children("*","MeshInstance3D",true,false):
		check(mesh.skin == null,String(mesh.name)+" remains rigid")
	sample("idle",0)
	var knee_rest := joint("left_knee_drive").transform
	var blade_rest := joint("knife_hinge").transform
	var magazine_rest := joint("rifle_magazine").transform
	var muzzle_rest := animator.socket("lr3_rifle").global_position
	var rifle := holder.find_child("LR3_Receiver",true,false) as MeshInstance3D
	var rigid_basis := rifle.global_basis.determinant()
	for at in [0.0,0.3,0.6,0.9]:
		sample("walk",at)
		check(joint("left_knee_drive").rotation.is_equal_approx(joint("left_knee_armour").rotation),"Leg armour follows the drive hinge")
		var left := sole_height("left")
		var right := sole_height("right")
		check(minf(left,right) >= -.008,"Walk soles do not penetrate the floor")
		if at in [0.3,0.9]: check(absf(left-right) > .035,"Swing foot lifts above the planted foot")
	check(not joint("left_knee_drive").transform.is_equal_approx(knee_rest),"Walk articulates the knee")
	for clip in animator.loop_clips:
		sample(clip,0)
		var transforms: Array[Transform3D] = []
		var joints := holder.find_children("Joint_*","Node3D",true,false)
		for node in joints: transforms.append(node.transform)
		sample(clip,animator.player.get_animation(clip).length)
		var continuous := true
		for i in joints.size(): continuous = continuous and joints[i].transform.is_equal_approx(transforms[i])
		check(continuous,clip+" loops without a pose discontinuity")
	sample("fire_rifle",5.0/30.0)
	var muzzle_aim := animator.socket("lr3_rifle").global_position
	sample("fire_rifle",7.0/30.0)
	check(animator.socket("lr3_rifle").global_position.distance_to(muzzle_aim) > .01,"LR-3 muzzle recoils during the shot pulse")
	check(animator.socket("lr3_rifle").global_position.distance_to(muzzle_rest) > .1,"Weapon raises into an aiming pose")
	check(is_equal_approx(rifle.global_basis.determinant(),rigid_basis),"Weapon animation preserves rigid scale")
	sample("rifle_reload",1)
	check(joint("rifle_magazine").transform.origin.distance_to(magazine_rest.origin) > .05,"Reload moves the magazine out of its well")
	sample("knife_deploy",.8)
	check(joint("knife_hinge").rotation.length() > 1.5,"Knife folds fully out of the forearm")
	var tip := animator.socket("vb2_knife").global_position
	sample("fire_knife",.6)
	check(animator.socket("vb2_knife").global_position.distance_to(tip) > .05,"Knife strike travels through a separate attack arc")
	sample("idle",0)
	check(joint("knife_hinge").transform.is_equal_approx(blade_rest),"Interrupting knife playback restores the stowed blade")
	check(joint("rifle_magazine").transform.is_equal_approx(magazine_rest),"Interrupting reload restores the magazine")
	var sockets: Array[Vector3] = []
	for i in range(4):
		var socket := holder.find_child("Socket_missile_"+str(i),true,false) as Node3D
		check(socket != null,"Wing hardpoint "+str(i)+" has a muzzle socket")
		if socket != null: sockets.append(socket.global_position)
	check(sockets.size() == 4 and sockets[0].distance_to(sockets[2]) > .6,"Missile origins span both binders")
	sample("fire_missiles",.4)
	check(joint("left_wing").rotation.length() > .01 and joint("right_wing").rotation.length() > .01,"Both binders react to launch")
	sample("hover",.5)
	check(sole_height("left") > .04,"Hover folds the legs clear of standing contact")
	sample("flight",.4)
	check(joint("left_wing").rotation.length() > .1,"Forward flight sweeps the binders")
	animator.fire("lr3_rifle")
	check(animator.player.current_animation == "fire_rifle","LR-3 selects its own firing clip")
	animator._process(.60)
	check(animator.cue_index == 2,"Rifle schedules two visual shot cues")
	animator.fire("agm_stores")
	animator._process(.81)
	check(animator.cue_index == 4,"Missile burst schedules four visual launch cues")
	animator.fire("vb2_knife")
	check(animator.player.current_animation == "fire_knife","VB-2 selects the knife strike")
	animator.airborne = true
	animator.idle()
	check(animator.player.current_animation == "hover","Airborne idle selects hover")
	animator.walk(1)
	check(animator.player.current_animation == "flight","Airborne movement selects forward flight")
	animator.airborne = false
	animator.walk(1)
	check(animator.player.current_animation == "walk","Ground movement selects the walking gait")
	animator.move(1.3,true)
	check(animator.player.current_animation == "takeoff","Altitude change starts the takeoff transition")
	animator._finished(&"takeoff")
	check(animator.player.current_animation == "flight" and is_equal_approx(animator.clip_speed,1.3),"Takeoff preserves the requested flight cadence")
	animator.play("knife_deploy")
	animator._finished(&"knife_deploy")
	check(animator.player.current_animation == "knife_ready","Deploy transitions to the held knife-ready loop")
	animator.rest()
	check(not animator.player.is_playing() and joint("knife_hinge").transform.is_equal_approx(blade_rest),"Workshop Rest freezes the neutral stowed pose")
	holder.free()
	finish()
