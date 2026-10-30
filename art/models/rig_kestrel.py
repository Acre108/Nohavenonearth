"""Kestrel rigid mechanical animation: editable controls and sampled glTF nodes."""
import math
import json
import struct
import bpy
from mathutils import Vector, Matrix, Euler
import build_gen2 as g

FPS=30
CLIPS={'idle':72,'walk':36,'turn_left':24,'turn_right':24,'ready':24,
    'fire_rifle':30,'fire_missiles':39,'rifle_reload':60,
    'knife_deploy':24,'knife_ready':48,'knife_stow':24,'fire_knife':36,'melee':30,
    'hover':60,'flight':48,'takeoff':36,'land':39,'evade_left':30,'evade_right':30}
LOOPS={'idle','walk','hover','flight','knife_ready'}

def finalise_export(path):
    """Keep authored clips and make the imported static pose exactly idle frame 0.

    Blender 3.2 can leave default node transforms at the last sampled air pose
    even when NLA extrapolation is disabled. glTF animation samples are already
    in export coordinates, so reuse the idle samples rather than converting twice.
    """
    binary=path.read_bytes(); length=struct.unpack_from('<I',binary,12)[0]
    doc=json.loads(binary[20:20+length]); remainder=binary[20+length:]
    doc['animations']=[a for a in doc.get('animations',[]) if a.get('name') in CLIPS]
    idle=next(a for a in doc['animations'] if a['name']=='idle')
    payload=remainder[8:]
    for channel in idle['channels']:
        sampler=idle['samplers'][channel['sampler']]
        accessor=doc['accessors'][sampler['output']]
        view=doc['bufferViews'][accessor['bufferView']]
        assert accessor['componentType']==5126
        count={'VEC3':3,'VEC4':4}[accessor['type']]
        offset=view.get('byteOffset',0)+accessor.get('byteOffset',0)
        values=struct.unpack_from('<'+'f'*count,payload,offset)
        node=doc['nodes'][channel['target']['node']]
        node.pop('matrix',None)
        node[channel['target']['path']]=list(values)
    encoded=json.dumps(doc,separators=(',',':')).encode(); encoded+=b' '*((-len(encoded))%4)
    path.write_bytes(struct.pack('<4sII',b'glTF',2,20+len(encoded)+len(remainder))+
        struct.pack('<I4s',len(encoded),b'JSON')+encoded+remainder)

def parent_keep(obj,parent):
    world=obj.matrix_world.copy(); obj.parent=parent; obj.matrix_world=world
    bpy.context.view_layer.update()

def prepare(root):
    regions={name[7:]:obj for name,obj in g.groups.items() if name.startswith('Region_')}
    scene=bpy.context.scene; scene.render.fps=FPS
    # Previous generated actions can remain after an in-place MCP rebuild.
    for action in list(bpy.data.actions):
        if action.get('frame_id')=='hx7_kestrel': bpy.data.actions.remove(action)
    joints={}
    def joint(name,pos,parent):
        node=g.group('Joint_'+name,pos,parent)
        node['mechanical_joint']=name
        joints[name]=node
        return node
    pelvis=joint('pelvis',(0,.81,0),root)
    torso=joint('torso',(0,.91,0),pelvis)
    for key in ['torso','power','backpack']: parent_keep(regions[key],torso)
    head=joint('head',(0,1.245,.006),torso)
    parent_keep(regions['head'],head)
    for side,s in [('left',-1),('right',1)]:
        shoulder=joint(side+'_shoulder',(s*.275,1.075,0),torso)
        parent_keep(regions[side+'_arm'],shoulder)
        for kind in ['actuator','armour']:
            comp=g.groups['Component_'+side+'_arm_'+kind]
            elbow=joint(side+'_elbow_'+kind,(s*.275,.87,-.0186),comp)
            wrist=joint(side+'_wrist_'+kind,(s*.275,.605,-.093),elbow)
            for obj in list(comp.children):
                if obj==elbow: continue
                name=obj.name.lower()
                centre=sum((obj.matrix_world @ Vector(v) for v in obj.bound_box),Vector())/8
                if name.startswith('lr3_') or any(word in name for word in ['_palm','_finger','_knuckle','_thumb','_wrist']):
                    parent_keep(obj,wrist)
                elif obj.type=='MESH' and centre.z<.91:
                    parent_keep(obj,elbow)
        hip=joint(side+'_hip',(s*.153,.81,.0088),pelvis)
        parent_keep(regions[side+'_leg'],hip)
        for kind in ['drive','armour']:
            comp=g.groups['Component_'+side+'_leg_'+kind]
            knee=joint(side+'_knee_'+kind,(s*.153,.47,-.0132),comp)
            ankle=joint(side+'_ankle_'+kind,(s*.153,.105,0),knee)
            for obj in list(comp.children):
                if obj==knee: continue
                name=obj.name.lower()
                centre=sum((obj.matrix_world @ Vector(v) for v in obj.bound_box),Vector())/8
                foot=any(word in name for word in ['_instep','_sole','_toe_claw','_heel_fan','_fan_'])
                if foot or centre.z<.13: parent_keep(obj,ankle)
                elif centre.z<.515: parent_keep(obj,knee)
        binder=g.groups[('L' if s<0 else 'R')+'_Wing_binder']
        wing=joint(side+'_wing',(s*.176,1.10,.19),binder.parent)
        parent_keep(binder,wing)
        for j in range(2):
            # Each store keeps its own socket, so launches alternate across both binders.
            idx=(0 if s<0 else 2)+j
            y=1.085+j*.065; x=s*(.43+j*.18)*.98
            hardpoint=g.groups[('L' if s<0 else 'R')+'_Hardpoint_'+str(j+1)]
            g.group('Socket_missile_'+str(idx),(x,y,-.055),hardpoint)
    # Knife is a separate rigid blade, folded along the outboard right forearm.
    blade=joint('knife_hinge',(.333,.651,-.0744),joints['right_elbow_armour'])
    parent_keep(g.groups['VB2_Folding_knife'],blade)
    gun=g.groups['LR3_Linear_Rifle']
    magazine=joint('rifle_magazine',(.275,.535,-.2604),gun)
    parent_keep(bpy.data.objects['LR3_Magazine'],magazine)
    # These source matrices are also the neutral channels in every exported clip.
    rest={n:o.matrix_basis.copy() for n,o in joints.items()}
    rest_world={n:o.matrix_world.copy() for n,o in joints.items()}

    def pulse(t,c,w): return max(0,1-abs(t-c)/w)
    def ease(t): return t*t*(3-2*t)
    def arm_pose(values,side,target,weight=1,weapon_rotation=None):
        """Two-link solve to fixed grip targets, keeping the rifle in a stable aim plane."""
        s=-1 if side=='left' else 1
        shoulder=Vector((s*.275,1.075,0))
        upper=Vector((0,-.205,-.0186)); lower=Vector((0,-.265,-.0744))
        l1,l2=upper.length,lower.length
        direction=Vector(target)-shoulder; distance=min(direction.length,l1+l2-.002)
        direction.normalize()
        a=(l1*l1-l2*l2+distance*distance)/(2*distance)
        h=math.sqrt(max(0,l1*l1-a*a))
        hint=Vector((s,-.5,.15)); bend=(hint-direction*hint.dot(direction)).normalized()
        elbow=shoulder+direction*a+bend*h
        q1=g.pt(upper).rotation_difference(g.pt(elbow-shoulder))
        q2=g.pt(lower).rotation_difference(g.pt(Vector(target)-elbow))
        ident=Euler((0,0,0)).to_quaternion()
        values[side+'_shoulder']=(tuple(ident.slerp(q1,weight).to_euler()),(0,0,0))
        for kind in ['actuator','armour']:
            values[side+'_elbow_'+kind]=(tuple(ident.slerp(q1.inverted()@q2,weight).to_euler()),(0,0,0))
            if weapon_rotation is not None:
                wrist=q2.inverted()@Euler(weapon_rotation).to_quaternion()
                values[side+'_wrist_'+kind]=(tuple(ident.slerp(wrist,weight).to_euler()),(0,0,0))

    def pose(clip,frame,end):
        t=frame/end; phase=t*math.tau; v={}
        def setp(n,r=(0,0,0),p=(0,0,0)): v[n]=(r,p)
        def air(weight=1,cruise=False):
            setp('pelvis',(0,0,0),(0,0,weight*(.025+.010*math.sin(phase))))
            setp('torso',(-.11*weight if cruise else -.025*weight,0,0))
            for side,s in [('left',-1),('right',1)]:
                setp(side+'_hip',(-.34*weight if cruise else .22*weight,0,s*.03*weight))
                for kind in ['drive','armour']:
                    setp(side+'_knee_'+kind,(-.70*weight if cruise else -.46*weight,0,0))
                    setp(side+'_ankle_'+kind,(.30*weight,0,0))
                setp(side+'_wing',(0,s*.16*weight,s*.10*weight))
            arm_pose(v,'right',(.13,.91,-.23),weight,(0,0,0))
        if clip=='idle':
            setp('torso',(.004*math.sin(phase),0,.006*math.sin(phase)))
            setp('head',(0,0,.022*math.sin(phase)))
            for side,s in [('left',-1),('right',1)]: setp(side+'_wing',(0,s*.008*math.sin(phase),0))
        elif clip=='walk':
            bob=-.025+.005*math.cos(2*phase)
            setp('pelvis',(0,0,.012*math.sin(phase)),(0,0,bob))
            setp('torso',(-.025,0,-.018*math.sin(phase)))
            l1=math.hypot(.34,.022); l2=math.hypot(.365,.0132)
            for side,offset in [('left',0),('right',math.pi)]:
                p=phase+offset
                forward=-.12*math.cos(p)
                down=.81+bob-(.105+.072*max(0,math.sin(p)))
                knee=-math.acos(max(-1,min(1,(down*down+forward*forward-l1*l1-l2*l2)/(2*l1*l2))))
                hip=math.atan2(forward,down)-math.atan2(l2*math.sin(knee),l1+l2*math.cos(knee))
                hd=hip-math.atan2(.022,.34)
                kd=knee+math.atan2(.022,.34)+math.atan2(.0132,.365)
                setp(side+'_hip',(hd,0,0))
                for kind in ['drive','armour']:
                    setp(side+'_knee_'+kind,(kd,0,0))
                    setp(side+'_ankle_'+kind,(-hd-kd,0,0))
                setp(side+'_shoulder',(-.08*math.cos(p),0,0))
        elif clip.startswith('turn_'):
            s=1 if clip=='turn_left' else -1; w=math.sin(math.pi*t)**2
            setp('torso',(0,0,s*.12*w)); setp('head',(0,0,s*.15*w))
            for side in ['left','right']:
                setp(side+'_hip',(.04*w,0,-s*.08*w))
                for kind in ['drive','armour']:
                    setp(side+'_knee_'+kind,(-.08*w,0,0)); setp(side+'_ankle_'+kind,(.04*w,0,0))
        elif clip in ['ready','fire_rifle','rifle_reload']:
            envelope=math.sin(math.pi*t)**2
            w=min(1,envelope*3)
            if clip=='fire_rifle': w=min(1,frame/4,(end-frame)/5)
            kick=max(pulse(frame,c,2) for c in [5,15]) if clip=='fire_rifle' else 0
            reload=math.sin(math.pi*t)**4 if clip=='rifle_reload' else 0
            arm_pose(v,'right',(.015,.94-.04*reload,-.14+.035*kick),w,(0,0,0))
            arm_pose(v,'left',(.015,.91-.12*reload,-.29+.08*reload),w,(0,0,0))
            setp('head',(-.025*w,0,-.035*w))
            setp('torso',(.018*kick,0,-.025*w))
            setp('rifle_magazine',(0,0,.12*reload),(0,0,-.07*reload))
        elif clip=='fire_missiles':
            w=math.sin(math.pi*t)**2
            kick=max(pulse(frame,c,2) for c in [5,11,17,23])
            setp('torso',(.012*kick,0,.008*kick))
            for side,s in [('left',-1),('right',1)]: setp(side+'_wing',(.012*kick,s*.08*w,0))
        elif clip in ['knife_deploy','knife_ready','knife_stow','fire_knife','melee']:
            if clip=='knife_ready': w=1
            elif clip=='knife_deploy': w=ease(t)
            elif clip=='knife_stow': w=1-ease(t)
            else: w=math.sin(math.pi*t)**2
            slash=math.sin(math.pi*t)**4 if clip in ['fire_knife','melee'] else 0
            setp('right_shoulder',(.22*w+.40*slash,0,-.18*w-.16*slash))
            for kind in ['actuator','armour']:
                setp('right_elbow_'+kind,(.36*w-.24*slash,0,0))
                setp('right_wrist_'+kind,(-.45*w,0,-.45*w))
            setp('left_shoulder',(.12*w,0,.10*w))
            setp('torso',(-.025*slash,0,-.12*slash))
            if clip!='melee': setp('knife_hinge',(-math.pi/2*w,0,0))
        elif clip in ['hover','flight']: air(1,clip=='flight')
        elif clip in ['takeoff','land']:
            w=ease(t) if clip=='takeoff' else 1-ease(t)
            air(w)
            crouch=math.sin(math.pi*t)**2*.13
            setp('pelvis',(0,0,0),(0,0,.025*w-.045*crouch))
        elif clip.startswith('evade_'):
            air()
            s=-1 if clip=='evade_left' else 1; w=math.sin(math.pi*t)**2
            setp('torso',(0,s*.20*w,-s*.10*w))
            setp('pelvis',(0,s*.12*w,0),(s*.018*w,0,.025))
        return v

    # Anatomical bones drive world-space targets in the editable source. Export
    # keeps only sampled rigid nodes, so armour is never skinned or bent.
    data=bpy.data.armatures.new('Kestrel_control_skeleton')
    rig=bpy.data.objects.new('Kestrel_Control_Rig',data); bpy.context.collection.objects.link(rig)
    rig.show_in_front=True; rig.hide_render=True
    rig['usage']='Choose a Controls_* action to edit; rebuild bakes the rigid game clips.'
    bpy.context.view_layer.objects.active=rig; rig.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bone_map={}
    for name in joints:
        canonical=name.replace('_armour','_actuator') if 'elbow_' in name or 'wrist_' in name else name.replace('_armour','_drive')
        bone_map[name]=canonical
        if canonical in data.edit_bones: continue
        bone=data.edit_bones.new(canonical); bone.head=rest_world[canonical].translation
        nxt=None
        if canonical=='pelvis': nxt='torso'
        elif canonical=='torso': nxt='head'
        elif canonical.endswith('_shoulder'): nxt=canonical.replace('_shoulder','_elbow_actuator')
        elif '_elbow_' in canonical: nxt=canonical.replace('_elbow_','_wrist_')
        elif canonical.endswith('_hip'): nxt=canonical.replace('_hip','_knee_drive')
        elif '_knee_' in canonical: nxt=canonical.replace('_knee_','_ankle_')
        bone.tail=rest_world[nxt].translation if nxt else bone.head+Vector((0,.06,0))
        ancestor=joints[canonical].parent
        while ancestor and ancestor!=root:
            if ancestor.name.startswith('Joint_'):
                parent_name=bone_map.get(ancestor.name[6:],ancestor.name[6:])
                if parent_name in data.edit_bones:
                    bone.parent=data.edit_bones[parent_name]; break
            ancestor=ancestor.parent
    bpy.ops.object.mode_set(mode='OBJECT')
    node_actions={clip:{} for clip in CLIPS}; controls={}
    for clip,end in CLIPS.items():
        controls[clip]=bpy.data.actions.new('Controls_'+clip)
        controls[clip].use_fake_user=True
        controls[clip]['frame_id']='hx7_kestrel'
        rig.animation_data_create(); rig.animation_data.action=controls[clip]
        for name,node in joints.items():
            node.animation_data_create(); node.rotation_mode='QUATERNION'
            action=bpy.data.actions.new(clip+'__'+name)
            action['frame_id']='hx7_kestrel'
            node.animation_data.action=action; node_actions[clip][name]=action
        for frame in range(end+1):
            scene.frame_set(frame); values=pose(clip,frame,end)
            for name,node in joints.items():
                r,p=values.get(name,((0,0,0),(0,0,0)))
                node.matrix_basis=rest[name] @ Matrix.Translation(Vector(p)) @ Euler(r,'XYZ').to_matrix().to_4x4()
                for prop in ['location','rotation_quaternion','scale']: node.keyframe_insert(data_path=prop,frame=frame)
            bpy.context.view_layer.update()
            for name,pb in rig.pose.bones.items():
                pb.rotation_mode='QUATERNION'
                pb.matrix=joints[name].matrix_world @ rest_world[name].inverted() @ data.bones[name].matrix_local
                for prop in ['location','rotation_quaternion','scale']: pb.keyframe_insert(data_path=prop,frame=frame)
            bpy.context.view_layer.update()
        for action in list(node_actions[clip].values())+[controls[clip]]:
            for curve in action.fcurves:
                for key in curve.keyframe_points: key.interpolation='LINEAR'
    rig.animation_data.action=None
    for name,node in joints.items():
        node.animation_data.action=None
        for clip in CLIPS:
            track=node.animation_data.nla_tracks.new(); track.name=clip
            strip=track.strips.new(clip,0,node_actions[clip][name])
            strip.blend_type='REPLACE'; strip.extrapolation='NOTHING'
        node.matrix_basis=rest[name]
    scene.frame_set(-1)
    for pb in rig.pose.bones: pb.matrix_basis=Matrix.Identity(4)
    bpy.context.view_layer.update()

    def restore():
        finalise_export(g.OUT/'hx7_kestrel.glb')
        for name,node in joints.items():
            for track in node.animation_data.nla_tracks: track.mute=True
            node.matrix_basis=rest[name]
        scene.frame_set(0)
        for pb in rig.pose.bones: pb.matrix_basis=Matrix.Identity(4)
        bpy.context.view_layer.update()
        for name,node in joints.items():
            target=bpy.data.objects.new('ControlTarget_'+name,None); bpy.context.collection.objects.link(target)
            target.parent=rig; target.parent_type='BONE'; target.parent_bone=bone_map[name]
            bpy.context.view_layer.update(); target.matrix_world=rest_world[name]
            target.hide_render=True; target.hide_set(True)
            constraint=node.constraints.new('COPY_TRANSFORMS'); constraint.name='Editable bone control (baked for export)'
            constraint.target=target; constraint.owner_space='WORLD'; constraint.target_space='WORLD'
        rig.animation_data.action=controls['idle']; scene.frame_start=0; scene.frame_end=72; scene.frame_set(0)
        rig['control_actions']=json.dumps({clip:action.name for clip,action in controls.items()})
        bpy.context.view_layer.update()
        report={'clips':{n:{'seconds':end/FPS,'loop':n in LOOPS} for n,end in CLIPS.items()},
            'rigid_joints':len(joints),'control_bones':len(data.bones),'root_motion':False,
            'deformation':'rigid transforms only','source':'art/source/hx7_kestrel.blend'}
        (g.QA/'kestrel_animation_checks.json').write_text(json.dumps(report,indent=2))
    return restore
