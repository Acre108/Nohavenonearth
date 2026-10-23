class_name TeamsterParts
extends RefCounted
## Add-on mount groups share the base assembly coordinates and follow its rigid joints.
const ASSET_DIR := "res://art/models/teamster_parts/"
## Parts modelled once per side; the asset name gains _left or _right.
const SIDED_PARTS := ["arm_precision", "arm_reinforced", "leg_fast", "leg_braced"]
## Parts modelled for one side only.
const ONE_SIDED_ASSETS := {"arm_support":"arm_support_left", "arm_marksman":"arm_marksman_right", "arm_cannon":"arm_cannon_right", "arm_breacher":"arm_breacher_left"}
## Base-model geometry each replacement weapon arm hides.
const RIFLE_PREFIXES := ["AR40_", "Rifle_", "Optic_"]
const REPLACES_RIFLE := ["arm_marksman", "arm_cannon"]
const REPLACES_STAKE := ["arm_support", "arm_breacher"]
static var scenes: Dictionary = {}

static func visual_asset(part: String, slot: String) -> String:
	if part in SIDED_PARTS:
		return part + ("_left" if slot.begins_with("left_") else "_right")
	return ONE_SIDED_ASSETS.get(part, part)

static func apply(root: Node3D, fit: Dictionary) -> void:
	for slot in fit:
		var part: String = fit[slot]
		var path := ASSET_DIR + visual_asset(part, slot) + ".glb"
		if not ResourceLoader.exists(path): continue
		var component := root.find_child("Component_" + String(slot).replace(".", "_"), true, false) as Node3D
		if component == null: continue
		hide_replaced_weapon(component, part)
		if not scenes.has(path): scenes[path] = load(path)
		var assembly: Node3D = scenes[path].instantiate()
		root.add_child(assembly)
		for mount in assembly.find_children("Mount_*", "Node3D", true, false):
			var kind := String(mount.name).trim_prefix("Mount_").to_lower()
			mount.reparent(mount_parent(component, slot, kind), false)
			mount.global_transform = root.global_transform
			mount.name = "Variant_" + part + "_" + kind
		assembly.queue_free()

static func hide_replaced_weapon(component: Node3D, part: String) -> void:
	if part in REPLACES_RIFLE:
		for node in component.find_children("*", "Node3D", true, false):
			if RIFLE_PREFIXES.any(func(prefix: String) -> bool: return String(node.name).begins_with(prefix)):
				node.visible = false
	if part in REPLACES_STAKE:
		var stake := component.find_child("PB4_Stake_driver", true, false)
		if stake != null: stake.visible = false

## Upper mounts ride the component itself; others follow the matching joint, e.g. Joint_left_lower_actuator.
static func mount_parent(component: Node3D, slot: String, kind: String) -> Node3D:
	if kind == "upper":
		return component
	var side := String(slot).get_slice("_", 0)
	var suffix := String(slot).get_slice(".", 1)
	var joint := component.find_child("Joint_" + side + "_" + kind + "_" + suffix, true, false) as Node3D
	return joint if joint != null else component

static func two_handed(fit: Dictionary) -> bool:
	return fit.get("right_arm.actuator") == "arm_marksman" and fit.get("left_arm.actuator") == "arm_support"
