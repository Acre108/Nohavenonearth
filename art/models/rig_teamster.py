"""Editable Blender control armature + baked rigid-joint glTF clips.

No skin deformation: rigid armour and workshop component roots stay separate.
Source bones drive world-space target empties after export; exported nodes carry
sampled local transforms grouped into clips by matching NLA track names.
"""
import math
import json
import bpy
from mathutils import Matrix, Vector, Euler
import build_gen2 as g

FPS = 30
CLIPS = {'idle':72, 'walk':36, 'turn_left':24, 'turn_right':24, 'ready':18,
         'fire_rifle':27, 'fire_missiles':33, 'fire_stake':27, 'melee':24,
         'twohand_idle':72,'twohand_walk':36,'twohand_ready':30,'twohand_fire':36,
         'twohand_reload':60,'twohand_turn_left':24,'twohand_turn_right':24,'fire_cannon':33,'fire_breacher':30}

def parent_keep(obj, parent):
    world = obj.matrix_world.copy()
    obj.parent = parent
    obj.matrix_world = world
    bpy.context.view_layer.update()

def prepare(root):
    from build_teamster import REGIONS
    scene = bpy.context.scene
    scene.render.fps = FPS
    joints = {}
    parents = {}

    def joint(name, position, parent):
        node = g.group('Joint_' + name, position, parent)
        node['mechanical_joint'] = name
        joints[name] = node
        parents[name] = parent
        return node

    pelvis = joint('pelvis', (0,.53,0), root)
    torso = joint('torso', (0,.66,0), pelvis)
    for key in ['torso','power','backpack']:
        parent_keep(REGIONS[key], torso)
    head = joint('head', (0,1.15,0), torso)
    parent_keep(REGIONS['head'], head)
    for side,s in [('left',-1),('right',1)]:
        arm = joint(side+'_shoulder', (s*.445,.97,0), torso)
        parent_keep(REGIONS[side+'_arm'], arm)
        for kind in ['actuator','armour']:
            comp = g.groups['Component_'+side+'_arm_'+kind]
            elbow = joint(side+'_elbow_'+kind, (s*.445,.705,-.045), comp)
            wrist = joint(side+'_wrist_'+kind, (s*.445,.505,-.13), elbow)
            for obj in list(comp.children):
                if obj == elbow: continue
                if obj.type == 'MESH':
                    centre = sum((obj.matrix_world @ Vector(v) for v in obj.bound_box), Vector()) / 8
                    y = centre.z
                    name = obj.name.lower()
                    if 'rifle' in name or 'optic' in name or 'hand_' in name or 'grip_' in name or 'wrist_' in name:
                        parent_keep(obj, wrist)
                    elif y < .745:
                        parent_keep(obj, elbow)
                elif obj.name.startswith(('AR40_', 'PB4_')):
                    parent_keep(obj, wrist)
        hip = joint(side+'_hip', (s*.235,.51,.015), pelvis)
        parent_keep(REGIONS[side+'_leg'], hip)
        for kind in ['drive','armour']:
            comp = g.groups['Component_'+side+'_leg_'+kind]
            knee = joint(side+'_knee_'+kind, (s*.235,.315,-.055), comp)
            ankle = joint(side+'_ankle_'+kind, (s*.235,.115,.015), knee)
            for obj in list(comp.children):
                if obj == knee: continue
                centre = sum((obj.matrix_world @ Vector(v) for v in obj.bound_box), Vector()) / 8
                if centre.z < .13 or obj.name.startswith(('Boot_', 'Toe_', 'Ankle_')):
                    parent_keep(obj, ankle)
                elif centre.z < .36:
                    parent_keep(obj, knee)
    pod = g.groups['Hornet_12_cell_pod']
    pod_joint = joint('missile_cradle', (.445,1.14,.10), pod.parent)
    parent_keep(pod, pod_joint)
    stake_group = g.groups['PB4_Stake_driver']
    slide = joint('stake_slide', (-.445,.58,-.39), stake_group)
    drum = joint('stake_drum', (-.445,.58,-.30), stake_group)
    for obj in list(stake_group.children):
        if obj.name == 'PB4_Stake': parent_keep(obj, slide)
        elif obj.name.startswith(('PB4_Revolver','PB4_Charge')): parent_keep(obj, drum)
    for name,pos,parent in [
        ('Socket_rifle_muzzle',(.445,.54,-.93),joints['right_wrist_actuator']),
        ('Socket_missile_muzzle',(.445,1.235,-.27),pod),
        ('Socket_stake_tip',(-.445,.58,-.63),slide)]:
        g.group(name,pos,parent)
    g.group('Socket_twohand_support',(.445,.505,-.33),joints['right_wrist_actuator'])

    rest = {name:node.matrix_basis.copy() for name,node in joints.items()}
    rest_world = {name:node.matrix_world.copy() for name,node in joints.items()}

    # Anatomical control bones. Duplicated shell hinges follow their drive bones.
    armature_data = bpy.data.armatures.new('Teamster_control_skeleton')
    armature = bpy.data.objects.new('Teamster_Control_Rig', armature_data)
    bpy.context.collection.objects.link(armature)
    armature.show_in_front = True
    armature.hide_render = True
    armature['usage'] = 'Select an action on this armature to edit the mechanical animation. Exported node tracks are baked from these controls.'
    bpy.context.view_layer.objects.active = armature
    armature.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bone_map = {}
    for name in joints:
        canonical = name.replace('_armour','_actuator') if 'elbow_' in name or 'wrist_' in name else name.replace('_armour','_drive')
        bone_map[name] = canonical
        if canonical in armature_data.edit_bones: continue
        bone = armature_data.edit_bones.new(canonical)
        bone.head = rest_world[canonical].translation
        next_name = None
        if canonical == 'pelvis': next_name = 'torso'
        elif canonical == 'torso': next_name = 'head'
        elif canonical.endswith('_shoulder'): next_name = canonical.replace('_shoulder','_elbow_actuator')
        elif '_elbow_' in canonical: next_name = canonical.replace('_elbow_','_wrist_')
        elif canonical.endswith('_hip'): next_name = canonical.replace('_hip','_knee_drive')
        elif '_knee_' in canonical: next_name = canonical.replace('_knee_','_ankle_')
        bone.tail = rest_world[next_name].translation if next_name else bone.head + Vector((0,.075,0))
        # Find the nearest already-created controlling ancestor through component nodes.
        ancestor = joints[canonical].parent
        while ancestor and ancestor != root:
            if ancestor.name.startswith('Joint_'):
                parent_name = bone_map.get(ancestor.name[6:], ancestor.name[6:])
                if parent_name in armature_data.edit_bones:
                    bone.parent = armature_data.edit_bones[parent_name]
                    break
            ancestor = ancestor.parent
    bpy.ops.object.mode_set(mode='OBJECT')
    node_actions = {name:{} for name in CLIPS}
    control_actions = {}

    def pulse(frame, centre, width=3):
        return max(0.0, 1 - abs(frame-centre)/width)

    def pose(clip, frame, end):
        phase = frame/end*math.tau
        values = {}
        def set_pose(name, rot=(0,0,0), loc=(0,0,0)):
            values[name] = (rot,loc)
        if clip == 'idle':
            set_pose('torso',(.004*math.sin(phase),0,.006*math.sin(phase)),(0,0,.002*math.sin(phase)))
            set_pose('head',(0,0,.025*math.sin(phase)))
        elif clip == 'walk':
            bob = -.025 + .005*math.cos(phase*2)
            set_pose('pelvis',(0,0,.015*math.sin(phase)),(.012*math.sin(phase),0,bob))
            set_pose('torso',(.025,0,-.025*math.sin(phase)))
            for side,offset in [('left',0),('right',math.pi)]:
                p=phase+offset
                forward=-.145*math.cos(p)
                down=.51+bob-(.115+.065*max(0,math.sin(p)))
                l1=math.hypot(.195,.07); l2=math.hypot(.20,.07)
                knee=-math.acos(max(-1,min(1,(down*down+forward*forward-l1*l1-l2*l2)/(2*l1*l2))))
                hip=math.atan2(forward,down)-math.atan2(l2*math.sin(knee),l1+l2*math.cos(knee))
                hip_delta=hip-math.atan2(.07,.195)
                knee_delta=knee-(-math.atan2(.07,.20)-math.atan2(.07,.195))
                set_pose(side+'_hip',(hip_delta,0,0))
                for kind in ['drive','armour']:
                    set_pose(side+'_knee_'+kind,(knee_delta,0,0))
                    set_pose(side+'_ankle_'+kind,(-hip_delta-knee_delta,0,0))
                set_pose(side+'_shoulder',(-.07*math.cos(p),0,0))
        elif clip.startswith('twohand_'):
            base='walk' if clip=='twohand_walk' else clip.removeprefix('twohand_') if 'turn_' in clip else 'idle'
            values=pose(base,frame,end)
            recoil=max(pulse(frame,c,3) for c in [3,12]) if clip=='twohand_fire' else 0
            lift=.025*math.sin(frame/end*math.pi)**2 if clip=='twohand_ready' else 0
            reload=math.sin(frame/end*math.pi)**2 if clip=='twohand_reload' else 0
            # Solve both arm chains to fixed weapon-space grip targets. The extended
            # support actuator supplies the extra reach; armour and drive hinges agree.
            for side,s in [('left',-1),('right',1)]:
                shoulder=Vector((s*.445,.97,0))
                target=Vector((.05,.77+lift,-.40 if side=='left' else -.20))
                target.z += .035*recoil
                if side=='left': target=target.lerp(Vector((.05,.61,-.27)),reload)
                upper=Vector((0,-.265,-.045))
                lower=Vector((0,-.20,-.085))
                extension=.23 if side=='left' else .08
                l1=upper.length; l2=lower.length+extension
                direction=(target-shoulder).normalized()
                distance=(target-shoulder).length
                assert distance<l1+l2, (side,distance,l1+l2)
                a=(l1*l1-l2*l2+distance*distance)/(2*distance)
                h=math.sqrt(max(0,l1*l1-a*a))
                hint=Vector((s,-.8,.1))
                bend=(hint-direction*hint.dot(direction)).normalized()
                elbow=shoulder+direction*a+bend*h
                q_upper=g.pt(upper).rotation_difference(g.pt(elbow-shoulder))
                q_lower=g.pt(lower).rotation_difference(g.pt(target-elbow))
                set_pose(side+'_shoulder',tuple(q_upper.to_euler()))
                for kind in ['actuator','armour']:
                    set_pose(side+'_elbow_'+kind,tuple((q_upper.inverted()@q_lower).to_euler()))
                    set_pose(side+'_wrist_'+kind,tuple(q_lower.inverted().to_euler()),tuple(g.pt(lower)*(extension/lower.length)))
            if recoil: set_pose('torso',(-.035*recoil,0,-.02*recoil))
        elif clip.startswith('turn_'):
            direction=1 if clip == 'turn_left' else -1
            weight=math.sin(frame/end*math.pi)**2
            set_pose('torso',(0,0,direction*.10*weight))
            set_pose('head',(0,0,direction*.12*weight))
            for side,s in [('left',-1),('right',1)]:
                set_pose(side+'_hip',(.05*weight,0,-direction*.09*weight))
                for kind in ['drive','armour']:
                    set_pose(side+'_knee_'+kind,(-.10*weight,0,0))
                    set_pose(side+'_ankle_'+kind,(.05*weight,0,0))
        elif clip == 'ready':
            weight=math.sin(frame/end*math.pi)**2
            for kind in ['actuator','armour']:
                set_pose('right_elbow_'+kind,(.12*weight,0,0))
            set_pose('head',(-.03*weight,0,-.035*weight))
        elif clip in ['fire_rifle','fire_cannon']:
            kick=max(pulse(frame,c,2) for c in [2,7,12])
            if clip=='fire_cannon': kick*=1.5
            settle=math.sin(frame/end*math.pi)**2
            set_pose('torso',(-.025*kick,0,-.02*settle))
            for kind in ['actuator','armour']:
                set_pose('right_elbow_'+kind,(-.045*kick,0,0))
                set_pose('right_wrist_'+kind,(.065*kick,0,0),(0,-.025*kick,0))
        elif clip == 'fire_missiles':
            kick=max(pulse(frame,c,2) for c in [3,8,13,18])
            brace=math.sin(frame/end*math.pi)**2
            set_pose('missile_cradle',(.04*brace-.025*kick,0,0),(0,-.015*kick,0))
            set_pose('torso',(-.014*kick,0,.012*kick))
        elif clip=='fire_breacher':
            kick=pulse(frame,3,3)
            set_pose('torso',(-.025*kick,0,.015*kick))
            for kind in ['actuator','armour']:
                set_pose('left_elbow_'+kind,(-.06*kick,0,0))
                set_pose('left_wrist_'+kind,(.06*kick,0,0),(0,-.035*kick,0))
        elif clip in ['fire_stake','melee']:
            thrust=pulse(frame,8,5)
            set_pose('torso',(.055*thrust,0,.055*thrust))
            for kind in ['actuator','armour']:
                set_pose('left_elbow_'+kind,(.13*thrust,0,0))
                set_pose('left_wrist_'+kind,(0,0,0),(0,.045*thrust,0))
            if clip == 'fire_stake':
                set_pose('stake_slide',(0,0,0),(0,.13*pulse(frame,9,2),0))
                # Reindex then return to neutral: six identical charge chambers make the reset invisible.
                set_pose('stake_drum',(0,math.tau/6*math.sin(frame/end*math.pi)**2,0))
        return values

    # Bake every joint every frame, including neutral channels, so interrupting a clip
    # can never leave an elbow, piston or missile cradle in the preceding pose.
    for clip,end in CLIPS.items():
        control_actions[clip] = bpy.data.actions.new('Controls_'+clip)
        armature.animation_data_create()
        armature.animation_data.action=control_actions[clip]
        for name,node in joints.items():
            node.animation_data_create()
            action=bpy.data.actions.new(clip+'__'+name)
            node.animation_data.action=action
            node.rotation_mode='QUATERNION'
            node_actions[clip][name]=action
        for frame in range(end+1):
            scene.frame_set(frame)
            values=pose(clip,frame,end)
            for name,node in joints.items():
                rotation,location=values.get(name,((0,0,0),(0,0,0)))
                transform=rest[name] @ Matrix.Translation(Vector(location)) @ Euler(rotation,'XYZ').to_matrix().to_4x4()
                node.matrix_basis=transform
                for prop in ['location','rotation_quaternion','scale']:
                    node.keyframe_insert(data_path=prop,frame=frame)
            bpy.context.view_layer.update()
            for name,pb in armature.pose.bones.items():
                pb.rotation_mode='QUATERNION'
                pb.matrix=joints[name].matrix_world @ rest_world[name].inverted() @ armature_data.bones[name].matrix_local
                for prop in ['location','rotation_quaternion','scale']:
                    pb.keyframe_insert(data_path=prop,frame=frame)
            bpy.context.view_layer.update()
        for action in list(node_actions[clip].values())+[control_actions[clip]]:
            for curve in action.fcurves:
                for key in curve.keyframe_points: key.interpolation='LINEAR'
    armature.animation_data.action=None
    for node in joints.values():
        node.animation_data.action=None
        for clip,end in CLIPS.items():
            track=node.animation_data.nla_tracks.new()
            track.name=clip
            strip=track.strips.new(clip,0,node_actions[clip][node.name[6:]])
            strip.blend_type='REPLACE'
            strip.extrapolation='NOTHING'
        node.matrix_basis=rest[node.name[6:]]
    # Keep the default exported pose at rest; exporters evaluate each NLA action in isolation.
    scene.frame_set(-1)
    for pb in armature.pose.bones: pb.matrix_basis=Matrix.Identity(4)
    bpy.context.view_layer.update()
    report={'clips':{name:{'seconds':end/FPS,'frames':end+1,'loop':name in ['idle','walk','twohand_idle','twohand_walk']} for name,end in CLIPS.items()},
            'control_bones':len(armature_data.bones),'rigid_joints':len(joints),'deformation':'rigid node transforms; editable source armature',
            'root_motion':False,'source':'art/source/m9_teamster.blend'}
    (g.QA/'teamster_animation_checks.json').write_text(json.dumps(report,indent=2))

    def restore_source_controls():
        # Blender 3.2 also emits static sampling clips for non-animated descendants.
        # Keep the nine authored clips; binary buffers and channel indices stay intact.
        import struct
        path=g.OUT/'m9_teamster.glb'
        data=path.read_bytes()
        length=struct.unpack_from('<I',data,12)[0]
        document=json.loads(data[20:20+length])
        document['animations']=[a for a in document.get('animations',[]) if a.get('name') in CLIPS]
        encoded=json.dumps(document,separators=(',',':')).encode('utf8')
        encoded+=b' '*((-len(encoded))%4)
        remainder=data[20+length:]
        path.write_bytes(struct.pack('<4sII',b'glTF',2,20+len(encoded)+len(remainder))+struct.pack('<I4s',len(encoded),b'JSON')+encoded+remainder)
        for name,node in joints.items():
            for track in node.animation_data.nla_tracks: track.mute=True
            node.matrix_basis=rest[name]
        scene.frame_set(0)
        for pb in armature.pose.bones: pb.matrix_basis=Matrix.Identity(4)
        bpy.context.view_layer.update()
        # Bone-parented targets retain each rigid joint's rest orientation. World-space
        # Copy Transforms avoids double-applying a moving mechanical parent.
        for name,node in joints.items():
            target=bpy.data.objects.new('ControlTarget_'+name,None)
            bpy.context.collection.objects.link(target)
            target.parent=armature
            target.parent_type='BONE'
            target.parent_bone=bone_map[name]
            bpy.context.view_layer.update()
            target.matrix_world=rest_world[name]
            target.hide_render=True
            target.hide_set(True)
            constraint=node.constraints.new('COPY_TRANSFORMS')
            constraint.name='Editable bone control (baked for game export)'
            constraint.target=target
            constraint.owner_space='WORLD'
            constraint.target_space='WORLD'
        armature.animation_data.action=control_actions['idle']
        scene.frame_start=0
        scene.frame_end=72
        scene.frame_set(0)
        bpy.context.view_layer.update()
    return restore_source_controls
