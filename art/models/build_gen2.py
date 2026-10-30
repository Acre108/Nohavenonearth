"""Repeatable Gen 2 demo models. Blender 3.2+, no external assets required.

blender --background --factory-startup --python art/models/build_gen2.py
Coordinates in this file: Godot metres, Y up, -Z forward. Runtime scale is
tabletop scale (18m Kestrel = 1.46 units). Reference art lives in output/imagegen.
"""
from pathlib import Path
import json
import math
import bpy
import bmesh
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'art/models'
QA = ROOT / 'artifacts/gen2'
QA.mkdir(parents=True, exist_ok=True)
bpy.context.preferences.filepaths.save_version = 0
SLOTS = ['armour_primary', 'armour_secondary', 'accent', 'frame', 'sensor', 'weapon']
PALETTES = {
    'hx7_kestrel': ['263c56', 'c9ceca', 'c47b3e', '303943', 'c6974b', '46515b'],
    'm9_teamster': ['656a4a', '3e4939', 'c2bda4', '303937', '6e9d9d', '454b43'],
    'ob12_medved': ['c7cbc5', '777f82', '404a50', '30373e', 'b5594f', '4c555b'],
    'type09_tieshan': ['4e5d47', '885749', 'cbc7ad', '303a35', '81a5a1', '495044'],
}
parts = []
groups = {}
materials = []

def pt(v):
    return Vector((v[0], -v[2], v[1]))

def linear(c):
    return c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4

def group(name, pivot, parent=None):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.location = pt(pivot)
    bpy.context.view_layer.update()
    if parent:
        world = obj.matrix_world.copy()
        obj.parent = parent
        obj.matrix_world = world
    bpy.context.view_layer.update()
    groups[name] = obj
    return obj

def finish(obj, name, slot, parent, bevel=0):
    obj.name = name
    if bevel:
        mod = obj.modifiers.new('Machined_edges', 'BEVEL')
        mod.width = bevel
        mod.segments = 1
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    for mat in materials:
        obj.data.materials.append(mat)
    for face in obj.data.polygons:
        face.material_index = slot
    # Move geometry into a useful local pivot without changing its world pose.
    bpy.context.view_layer.update()
    world = obj.matrix_world.copy()
    if parent:
        obj.parent = parent
        obj.matrix_world = world
    parts.append(obj)
    return obj

def box(name, size, pos, slot=0, parent=None, bevel=.012, tilt=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pt(pos))
    obj = bpy.context.object
    obj.scale = (size[0], size[2], size[1])
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.rotation_euler.x = tilt
    return finish(obj, name, slot, parent, bevel)

def poly(name, xy, front, back, slot=0, parent=None, bevel=.008):
    n = len(xy)
    vertices = [pt((x,y,z)) for z in [front, back] for x,y in xy]
    faces = [tuple(reversed(range(n))), tuple(range(n,n*2))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    return finish(obj, name, slot, parent, bevel)

def rod(name, a, b, radius, slot=3, parent=None, vertices=10, end_radius=None):
    av, bv = pt(a), pt(b)
    if end_radius is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=(bv-av).length, location=(av+bv)/2)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius, radius2=end_radius, depth=(bv-av).length, location=(av+bv)/2)
    obj = bpy.context.object
    obj.rotation_euler = (bv-av).to_track_quat('Z','Y').to_euler()
    return finish(obj, name, slot, parent)

def ellipsoid(name, size, pos, slot=0, parent=None, segments=12, rings=6):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1, location=pt(pos))
    obj = bpy.context.object
    obj.scale = (size[0]/2,size[2]/2,size[1]/2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, name, slot, parent)

def vent(name, pos, width, height, parent, count=5):
    x,y,z = pos
    box(name+'_well', (width,height,.025), pos, 3, parent, .003)
    for i in range(count):
        box(name+'_slat_%02d'%i, (width*.87,.009,.022), (x,y-height*.4+i*height*.8/(count-1),z+.018), 5,parent,.001)

def lens(name,x,y,z,r,parent,slot=4):
    rod(name+'_rim',(x,y,z+.012),(x,y,z-.008),r*1.3,5,parent,8)
    rod(name,(x,y,z-.01),(x,y,z-.016),r,slot,parent,8)

def number_mark(text, pos, size, parent, slot=2):
    bpy.ops.object.text_add(location=pt(pos))
    obj = bpy.context.object
    obj.data.body = text
    obj.data.size = size
    obj.data.align_x = 'CENTER'
    obj.data.extrude = .0003
    obj.rotation_euler = (math.pi/2,0,math.pi)
    bpy.ops.object.convert(target='MESH')
    return finish(bpy.context.object,'Tactical_number_'+text,slot,parent)

def core(frame, width, chest_y, head_y, round_hull=False):
    root = group(frame, (0,0,0))
    torso = group('Torso',(0,chest_y,0),root)
    waist = group('Pelvis',(0,.57,0),root)
    box('Waist_coupling',(.28,.14,.24),(0,.62,0),3,waist)
    box('Hip_crossmember',(width*.72,.14,.28),(0,.53,0),1,waist)
    if round_hull:
        ellipsoid('Cast_egg_hull',(width,.53,.49),(0,chest_y,-.01),0,torso,16,8)
    else:
        poly('Glacis_chest',[(-width*.42,chest_y+.22),(width*.42,chest_y+.22),(width*.5,chest_y-.04),(width*.30,chest_y-.25),(-width*.30,chest_y-.25),(-width*.5,chest_y-.04)],-.235,.19,0,torso,.025)
    head = group('Head',(0,head_y,0),torso)
    return root, torso, waist, head

def limbs(root, torso, waist, stance, shoulder, top, heavy=False, rounded=False):
    arms = {}
    for s, tag in [(-1,'L'),(1,'R')]:
        x = s*stance
        leg = group(tag+'_Leg',(x,.52,0),waist)
        rod(tag+'_Hip_axle',(x-.09,.51,0),(x+.09,.51,0),.08,3,leg)
        box(tag+'_Thigh',(.17 if not heavy else .23,.23,.22),(x,.43,.035),0,leg,.025,tilt=-.16)
        rod(tag+'_Knee_axle',(x-.12,.31,-.025),(x+.12,.31,-.025),.075,3,leg)
        if rounded:
            ellipsoid(tag+'_Round_kneecap',(.24,.20,.13),(x,.32,-.15),1,leg)
        else:
            box(tag+'_Knee_plate',(.23 if heavy else .18,.14,.11),(x,.33,-.14),1,leg,.02)
        box(tag+'_Shin',(.24 if heavy else .19,.25,.24),(x,.19,.02),0,leg,.022,tilt=.10)
        box(tag+'_Foot',(.31 if heavy else .25,.12,.4),(x,.06,-.095),0,leg,.018)
        box(tag+'_Sole',(.32 if heavy else .26,.026,.41),(x,.014,-.095),3,leg,.004)
        poly(tag+'_Shin_facet',[(x-.075,.26),(x+.075,.26),(x+.055,.10),(x-.055,.10)],-.112,-.101,1,leg,.002)
        box(tag+'_Toe_seam',(.012,.035,.012),(x,.075,-.297),3,leg,.001)
        rod(tag+'_Hydraulic_ram',(x+s*.105,.12,.10),(x+s*.105,.34,.09),.018,5,leg,8)
        rod(tag+'_Piston',(x+s*.105,.34,.09),(x+s*.105,.45,.045),.009,2,leg,8)
        arm = group(tag+'_Arm',(s*shoulder,top,0),torso)
        rod(tag+'_Shoulder_axle',(s*(shoulder-.10),top,0),(s*(shoulder+.10),top,0),.095,3,arm)
        if rounded:
            ellipsoid(tag+'_Pauldron',(.30,.25,.32),(s*shoulder,top+.02,0),1,arm)
        else:
            box(tag+'_Pauldron',(.30 if heavy else .24,.22,.31),(s*shoulder,top+.02,0),0,arm,.025)
        box(tag+'_Upper_arm',(.18,.19,.20),(s*shoulder,top-.16,.01),3,arm,.02)
        rod(tag+'_Elbow',(s*shoulder-.10,top-.25,-.035),(s*shoulder+.10,top-.25,-.035),.067,5,arm)
        box(tag+'_Forearm',(.24 if heavy else .19,.22,.28),(s*shoulder,top-.32,-.095),0,arm,.022)
        box(tag+'_Grip',(.15,.10,.13),(s*shoulder,top-.40,-.16),3,arm,.014)
        arms[tag] = arm
    return arms

def rifle(name, x,y,parent,long=False):
    gun = group(name,(x,y,-.19),parent)
    box(name+'_Receiver',(.145,.14,.33),(x,y,-.26),5,gun)
    box(name+'_Stock',(.11,.12,.18),(x,y,.00),5,gun)
    box(name+'_Magazine',(.10,.17,.12),(x,y-.12,-.26),5,gun,.007)
    box(name+'_Sight',(.048,.035,.20),(x,y+.095,-.29),3,gun,.003)
    if long:
        for s in [-1,1]:
            box('LR3_Linear_rail',(.030,.065,.65),(x+s*.05,y,-.69),5,gun,.004)
        box('LR3_Capacitor_stock',(.16,.16,.19),(x,y,.025),1,gun)
        for z in [-.86,-.92,-.98]:
            box('LR3_Cooling_fin',(.15,.09,.022),(x,y,z),3,gun,.002)
    else:
        rod('AR40_Barrel',(x,y,-.41),(x,y,-.84),.032,5,gun)
        rod('AR40_Muzzle',(x,y,-.82),(x,y,-.91),.047,5,gun)
        rod('AR40_Grenade_launcher',(x,y-.075,-.36),(x,y-.075,-.68),.043,5,gun)
        for z in [-.45,-.50,-.55,-.60]:
            rod('AR40_Launcher_rib',(x,y-.075,z),(x,y-.075,z-.012),.049,3,gun)
    return gun

def kestrel():
    root,torso,waist,head = core('hx7_kestrel',.43, .96,1.27)
    # Aircraft chest, single wedge visor, no Gundam crest or shield.
    poly('Canopy',[(-.13,1.10),(.13,1.10),(.09,.91),(0,.84),(-.09,.91)],-.25,-.235,3,torso)
    poly('Canopy_glass',[(-.09,1.075),(.09,1.075),(.065,.95),(0,.90),(-.065,.95)],-.26,-.255,5,torso,.001)
    poly('Wedge_helmet',[(-.105,1.24),(-.09,1.37),(.08,1.37),(.14,1.26),(0,1.21)],-.13,.09,0,head)
    box('Single_amber_slit',(.18,.022,.015),(0,1.275,-.14),4,head,.002)
    poly('Blade_antenna',[(.03,1.36),(.05,1.46),(.065,1.35)],-.015,.015,1,head,.001)
    for s,tag in [(-1,'L'),(1,'R')]:
        leg = group(tag+'_Leg',(s*.145,.62,0),waist)
        box(tag+'_Thigh',(.125,.30,.15),(s*.145,.56,.01),0,leg)
        poly(tag+'_Thigh_facet',[(s*.145-.05,.68),(s*.145+.05,.65),(s*.145+.04,.46),(s*.145-.04,.49)],-.076,-.067,1,leg,.002)
        rod(tag+'_Knee',(s*.145-.07,.42,0),(s*.145+.07,.42,0),.055,3,leg)
        poly(tag+'_Nacelle',[(s*.145-.08,.39),(s*.145+.08,.39),(s*.145+.10,.12),(s*.145-.09,.10)],-.06,.14,1,leg)
        rod(tag+'_Heel_nozzle',(s*.145,.105,.09),(s*.145,.105,.18),.059,5,leg)
        rod(tag+'_Nozzle_dark',(s*.145,.105,.175),(s*.145,.105,.183),.043,3,leg)
        box(tag+'_Toe',(.15,.075,.27),(s*.145,.038,-.08),1,leg,.01)
        poly(tag+'_Toe_claw',[(s*.145-.04,.025),(s*.145+.04,.025),(s*.145+.025,.09)],-.26,-.16,3,leg,.002)
        box(tag+'_Calf_orange',(.055,.055,.012),(s*.145,.20,-.068),2,leg,.002)
        arm=group(tag+'_Arm',(s*.29,1.05,0),torso)
        box(tag+'_Shoulder',(.18,.19,.24),(s*.29,1.07,0),0,arm,.025)
        box(tag+'_Upper_arm',(.11,.20,.12),(s*.30,.88,0),3,arm)
        box(tag+'_Forearm',(.14,.25,.17),(s*.32,.69,-.06),1,arm)
        poly(tag+'_Forearm_facet',[(s*.32-.065,.79),(s*.32+.065,.79),(s*.32+.045,.60),(s*.32-.03,.58)],-.15,-.143,0,arm,.001)
        box(tag+'_Hand',(.11,.10,.12),(s*.32,.53,-.09),3,arm)
        box(tag+'_Intake',(.095,.15,.07),(s*.19,1.01,-.19),1,torso,.01)
        box(tag+'_Intake_dark',(.065,.10,.015),(s*.19,1.02,-.235),3,torso,.002)
        wing = group(tag+'_Wing_binder',(s*.15,1.05,.20),torso)
        poly(tag+'_Swept_wing',[(s*.17,.93),(s*.27,1.28),(s*.95,1.49),(s*.78,1.22),(s*.41,1.10)],.20,.25,0,wing,.006)
        poly(tag+'_White_control_surface',[(s*.29,1.17),(s*.80,1.37),(s*.75,1.23),(s*.40,1.12)],.19,.202,1,wing,.002)
        poly(tag+'_Orange_wingtip',[(s*.81,1.445),(s*.95,1.49),(s*.87,1.36),(s*.77,1.32)],.19,.26,2,wing,.002)
        for j in range(2):
            x=s*(.43+j*.17)
            box(tag+'_AGMM_Pylon_'+str(j),(.035,.12,.08),(x,1.16,.22),3,wing,.002)
            rod(tag+'_AGMM_Body_'+str(j),(x,1.08,.36),(x,1.08,.02),.033,1,wing)
            rod(tag+'_AGMM_Nose_'+str(j),(x,1.08,.02),(x,1.08,-.08),.033,2,wing,end_radius=0)
            box(tag+'_AGMM_Tailfin_'+str(j),(.11,.012,.07),(x,1.08,.32),1,wing,.001)
        if tag=='R':
            rifle('LR3_Linear_Rifle',s*.32,.62,arm,True)
            box('VB2_Folding_knife_seam',(.015,.20,.025),(s*.32+.078,.69,-.13),5,arm,.001)
    box('QX_Battery_spine',(.17,.43,.17),(0,1.02,.27),3,torso)
    for y in [.86,1.02,1.18]:
        box('Battery_module',(.19,.10,.05),(0,y,.38),5,torso,.006)
    for x in [-.11,.11]:
        rod('Yellow_lifting_handle',(x,.88,.37),(x,1.24,.37),.012,2,torso,8)
    number_mark('01',(-.145,.27,-.072),.075,groups['L_Leg'],1)
    return root

def teamster():
    root,torso,waist,head=core('m9_teamster',.62,.82,1.075)
    arms=limbs(root,torso,waist,.23,.43,.93,True)
    box('Cupola',(.28,.12,.25),(0,1.09,-.015),0,head,.025)
    for x in [-.08,.08]: lens('Cupola_camera',x,1.10,-.15,.026,head)
    box('Periscope',(.055,.065,.055),(.07,1.18,.015),3,head,.004)
    box('Periscope_glass',(.04,.025,.01),(.07,1.19,-.018),4,head,.001)
    for x in [-.12,.12]:
        for y in [.78,.87,.96]: box('Spare_track_link',(.065,.045,.025),(x,y,-.25),5,torso,.003)
    number_mark('02',(0,.87,-.262),.085,torso)
    for s in [-1,1]:
        poly('Disruptive_glacis_patch',[(s*.16,1.00),(s*.24,1.00),(s*.27,.86),(s*.19,.76)],-.253,-.246,1,torso,.001)
        rod('Glacis_grab_handle',(s*.21,.92,-.274),(s*.21,.99,-.274),.008,5,torso,6)
        box('Shoulder_camo',(.13,.09,.012),(s*.43,.97,-.162),1,arms['L' if s<0 else 'R'],.002)
    pod=group('Hornet_12_cell_pod',(.43,1.15,0),torso)
    box('Hornet_housing',(.30,.25,.37),(.43,1.16,-.02),0,pod)
    box('Hornet_face',(.27,.22,.016),(.43,1.16,-.212),5,pod,.003)
    for row in range(3):
        for col in range(4):
            lens('Hornet_cell_%02d'%(row*4+col),.43+(col-1.5)*.063,1.16+(row-1)*.066,-.225,.023,pod,3)
    rifle('AR40_Longhorn',.43,.60,arms['R'])
    stake=group('PB4_Stake_driver',(-.43,.58,-.22),arms['L'])
    rod('PB4_Revolver',(-.43,.58,-.18),(-.43,.58,-.31),.10,5,stake,12)
    for i in range(6):
        a=i*math.tau/6
        rod('PB4_Charge',(-.43+.067*math.cos(a),.58+.067*math.sin(a),-.31),(-.43+.067*math.cos(a),.58+.067*math.sin(a),-.325),.022,3,stake,8)
    rod('PB4_Stake',(-.43,.58,-.30),(-.43,.58,-.53),.035,5,stake,end_radius=0)
    box('HT12_Powerpack',(.40,.33,.21),(0,.85,.29),0,torso)
    vent('Turbine_louvres',(0,.87,.405),.30,.21,torso)
    for x in [-.25,.25]:
        box('Jerrycan',(.10,.17,.085),(x,.78,.30),0,torso,.009)
        box('Jerrycan_handle',(.055,.02,.04),(x,.875,.30),5,torso,.002)
        rod('Whip_antenna',(x,1.0,.20),(x*1.05,1.40,.23),.006,3,torso,6)
    return root

def medved():
    root,torso,waist,head=core('ob12_medved',.78,.87,1.08,True)
    arms=limbs(root,torso,waist,.27,.52,1.03,True)
    poly('Angular_breastplate',[(-.32,1.07),(.32,1.07),(.38,.85),(.19,.65),(-.19,.65),(-.38,.85)],-.29,-.23,0,torso,.02)
    for s in [-1,1]:
        poly('Winter_splinter',[(s*.06,1.055),(s*.29,1.055),(s*.35,.88),(s*.14,.91)],-.313,-.308,1,torso,.001)
    box('Recessed_helmet',(.28,.13,.23),(0,1.115,-.045),1,head,.025)
    box('Red_sensor_slit',(.22,.022,.015),(0,1.125,-.17),4,head,.002)
    box('Twin_diesel_powerplant',(.55,.32,.18),(0,.87,.31),1,torso,.015)
    vent('Heavy_radiator',(0,.88,.41),.43,.22,torso,4)
    for s,tag in [(-1,'L'),(1,'R')]:
        arm=arms[tag]
        poly(tag+'_Hunched_mantle',[(s*.34,1.17),(s*.62,1.12),(s*.71,.86),(s*.48,.90)],-.19,.20,0,arm,.015)
        gun=group(tag+'_GSh6M_Rotary', (s*.52,.66,-.19),arm)
        rod(tag+'_Cannon_receiver',(s*.52,.66,-.08),(s*.52,.66,-.31),.115,5,gun,12)
        for i in range(6):
            a=i*math.tau/6
            x=s*.52+.065*math.cos(a); y=.66+.065*math.sin(a)
            rod(tag+'_GSh6M_Barrel_%d'%i,(x,y,-.28),(x,y,-.69),.021,5,gun,8)
            rod(tag+'_GSh6M_Bore_%d'%i,(x,y,-.691),(x,y,-.696),.013,3,gun,8)
        for z in [-.35,-.59]: rod(tag+'_Barrel_collar',(s*.52,.66,z),(s*.52,.66,z-.025),.092,1,gun,12)
        # Cleats give the heavy feet a visibly different contact patch.
        for dx in [-.105,0,.105]:
            box(tag+'_Ice_cleat',(.045,.05,.08),(s*.27+dx,.032,-.28),5,groups[tag+'_Leg'],.004)
        for j in range(2):
            x=s*(.23+j*.11)
            rod(tag+'_Diesel_stack_%d'%j,(x,.85,.32),(x,1.43,.32),.043,5,torso)
            rod(tag+'_Stack_cap_%d'%j,(x,1.38,.32),(x,1.40,.32),.054,1,torso)
            rod(tag+'_Soot_tip_%d'%j,(x,1.43,.32),(x,1.435,.32),.034,3,torso)
    battery=group('GradM_40_tube_battery',(0,1.35,.18),torso)
    box('GradM_Elevation_cradle',(.33,.18,.17),(0,1.18,.24),5,battery)
    for s in [-1,1]:
        x=s*.205
        box('GradM_20_tube_housing',(.39,.31,.42),(x,1.40,.15),0,battery)
        box('GradM_Dark_face',(.36,.28,.015),(x,1.40,-.07),3,battery,.002)
        for row in range(4):
            for col in range(5):
                lens('GradM_tube_%d_%d_%d'%(s,row,col),x+(col-2)*.069,1.40+(row-1.5)*.067,-.088,.026,battery,3)
    number_mark('04',(0,.85,-.32),.10,torso,2)
    return root

def tieshan():
    root,torso,waist,head=core('type09_tieshan',.69,.80,1.055,True)
    arms=limbs(root,torso,waist,.23,.43,.87,False,True)
    ellipsoid('Small_dome',(.29,.17,.26),(0,1.075,0),0,head)
    for i,x in enumerate([-.078,0,.078]): lens('Three_lens_cluster_%d'%i,x,1.08,-.14,.028,head)
    for s,tag in [(-1,'L'),(1,'R')]:
        rod(tag+'_Diesel_stack',(s*.19,.73,.29),(s*.19,1.28,.29),.045,5,torso)
        rod(tag+'_Stack_soot',(s*.19,1.28,.29),(s*.19,1.29,.29),.036,3,torso)
        rod(tag+'_Stack_collar',(s*.19,1.23,.29),(s*.19,1.25,.29),.055,1,torso)
        for finger in range(3):
            box(tag+'_Three_finger_grip_%d'%finger,(.032,.07,.075),(s*.43+(finger-1)*.043,.45,-.21),5,arms[tag],.005)
    rod('Short_antenna',(-.10,1.12,.06),(-.13,1.32,.08),.006,3,head,6)
    box('Type06_Diesel',(.38,.26,.19),(0,.81,.29),0,torso)
    vent('Diesel_grille',(0,.82,.395),.29,.18,torso)
    # Hull welds are sparse and bold enough for the tactical camera.
    for s in [-1,1]:
        rod('Hull_weld_seam',(s*.12,.68,-.237),(s*.16,.94,-.24),.006,5,torso,6)
    number_mark('05',(0,.80,-.263),.12,torso)
    cannon=group('Type09_Long_Cannon',(.26,.54,-.20),arms['R'])
    box('Cannon_breech',(.18,.16,.34),(.26,.54,-.25),5,cannon)
    rod('Cannon_barrel',(.26,.54,-.40),(.26,.54,-1.07),.039,0,cannon,12)
    rod('Barrel_sleeve',(.26,.54,-.39),(.26,.54,-.53),.055,5,cannon,12)
    box('Large_muzzle_brake',(.15,.11,.18),(.26,.54,-1.13),5,cannon,.009)
    box('Muzzle_bore',(.068,.052,.008),(.26,.54,-1.225),3,cannon,.002)
    for s in [-1,1]:
        for z in [-1.09,-1.15]: box('Brake_port',(.008,.065,.032),(.26+s*.077,.54,z),3,cannon,.001)
        rod('Folded_bipod',(.26+s*.05,.49,-.65),(.26+s*.085,.37,-.95),.014,5,cannon,8)
    # Left grip crosses inward to support the long cannon beneath the breech.
    rod('Support_wrist',(-.40,.49,-.18),(.12,.49,-.35),.048,3,arms['L'],10)
    box('Support_fingers',(.15,.075,.13),(.13,.49,-.36),3,arms['L'],.009)
    drum=group('Type07_Drum_Rifle_stowed',(-.35,.65,.23),torso)
    box('Type07_Receiver',(.12,.25,.12),(-.39,.70,.23),5,drum)
    rod('Type07_Stowed_barrel',(-.39,.80,.23),(-.39,1.08,.23),.025,5,drum)
    rod('Type07_Drum',(-.47,.62,.23),(-.31,.62,.23),.095,5,drum,12)
    box('Type07_Stock',(.10,.16,.085),(-.39,.49,.23),0,drum)
    return root

def bake_vertex_tones():
    """Bake deterministic short-range AO by ray casting against the entire model.
    Add broad foot dirt and restrained edge wear; export as linear COLOR_0.
    """
    bpy.context.view_layer.update()
    vertices=[]; faces=[]
    for obj in parts:
        offset=len(vertices)
        vertices += [obj.matrix_world @ v.co for v in obj.data.vertices]
        faces += [tuple(offset+i for i in f.vertices) for f in obj.data.polygons]
    tree=BVHTree.FromPolygons(vertices,faces)
    rays=[Vector((math.cos(i*2.39996),math.sin(i*2.39996),.65)).normalized() for i in range(8)]
    for obj in parts:
        mesh=obj.data
        colors=mesh.vertex_colors.new(name='Col')
        values={}
        adjacent=[[] for _ in mesh.vertices]
        for face in mesh.polygons:
            for idx in face.vertices: adjacent[idx].append(face.normal)
        normal_matrix=obj.matrix_world.to_3x3().inverted().transposed()
        for v in mesh.vertices:
            p=obj.matrix_world @ v.co
            n=(normal_matrix @ v.normal).normalized()
            rot=Vector((0,0,1)).rotation_difference(n)
            occlusion=sum(tree.ray_cast(p+n*.002,rot @ r,.16)[0] is not None for r in rays)/len(rays)
            curvature=1-min((v.normal.dot(fn) for fn in adjacent[v.index]),default=1)
            dirt=max(0,1-p.z/.25)*.14
            tone=min(1,.96-.20*occlusion-dirt+.08*curvature)
            values[v.index]=(tone,tone,tone,1)
        for loop in mesh.loops: colors.data[loop.index].color=values[loop.vertex_index]

def preview(root, frame):
    scene=bpy.context.scene
    scene.render.engine='BLENDER_WORKBENCH'
    scene.display.shading.light='STUDIO'
    scene.display.shading.color_type='MATERIAL'
    scene.display.shading.show_shadows=True
    scene.display.shading.show_cavity=True
    scene.display.shading.cavity_type='BOTH'
    scene.display.shading.show_specular_highlight=False
    scene.display.shading.background_type='WORLD'
    scene.world.color=(.19,.22,.26)
    scene.render.resolution_x=960
    scene.render.resolution_y=960
    scene.render.resolution_percentage=100
    data=bpy.data.cameras.new('Review_camera')
    camera=bpy.data.objects.new('Review_camera',data)
    bpy.context.collection.objects.link(camera)
    scene.camera=camera
    data.type='ORTHO'; data.ortho_scale=2.45
    target=pt((0,.75,-.10))
    views=[('beauty',(2.8,2.0,-4)),('front',(0,.8,-5)),('back',(0,.8,5)),('side',(5,.8,0)),('tactical',(0,6,7))]
    black=bpy.data.materials.new('QA_black'); black.diffuse_color=(0,0,0,1)
    saved=[list(obj.data.materials) for obj in parts]
    for name,position in views:
        camera.location=pt(position)
        camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(QA/(frame+'_'+name+'.png'))
        bpy.ops.render.render(write_still=True)
        if name != 'beauty':
            for obj in parts:
                for i in range(len(obj.data.materials)): obj.data.materials[i]=black
            scene.display.shading.light='FLAT'
            scene.display.shading.show_shadows=False
            scene.display.shading.show_cavity=False
            scene.render.filepath=str(QA/(frame+'_'+name+'_silhouette.png'))
            bpy.ops.render.render(write_still=True)
            for obj,mats in zip(parts,saved):
                for i,mat in enumerate(mats): obj.data.materials[i]=mat
            scene.display.shading.light='STUDIO'
            scene.display.shading.show_shadows=True
            scene.display.shading.show_cavity=True

def build(frame, builder, prepare_export=None):
    global parts,groups,materials
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    for mat in list(bpy.data.materials): bpy.data.materials.remove(mat)
    parts=[]; groups={}; materials=[]
    for name,rgb in zip(SLOTS,PALETTES[frame]):
        mat=bpy.data.materials.new(name)
        mat.diffuse_color=tuple(linear(int(rgb[i:i+2],16)/255) for i in [0,2,4])+(1,)
        mat.use_nodes=True
        bsdf=mat.node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value=mat.diffuse_color
        bsdf.inputs['Roughness'].default_value=.9
        materials.append(mat)
    root=builder()
    root['forward_godot']='-Z'; root['origin']='ground centre'; root['reference']='Gen2-Frame-Art-Briefs.md'
    bake_vertex_tones()
    bpy.context.view_layer.update()
    tris=sum(len(p.vertices)-2 for obj in parts for p in obj.data.polygons)
    coords=[obj.matrix_world @ v.co for obj in parts for v in obj.data.vertices]
    report={'frame':frame,'triangles':tris,'rigid_meshes':len(parts),'materials':SLOTS,
            'height':max(v.z for v in coords),'ground_min':min(v.z for v in coords),
            'origin':list(root.location),'godot_forward':'-Z','blender_forward':'+Y',
            'vertex_colors':'Col: ray-cast AO, edge wear, foot dirt','textures':0,
            'bounds_min':[min(v[i] for v in coords) for i in range(3)],
            'bounds_max':[max(v[i] for v in coords) for i in range(3)]}
    assert 3000 <= tris <= int(root.get('triangle_budget', 8000)), report
    assert abs(report['ground_min'])<.002, report
    assert root.location.length==0
    (QA/(frame+'_checks.json')).write_text(json.dumps(report,indent=2))
    restore_controls = prepare_export(root) if prepare_export else None
    bpy.ops.object.select_all(action='DESELECT')
    root.select_set(True)
    for obj in root.children_recursive: obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(frame+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_colors=True,export_extras=True)
    if restore_controls: restore_controls()
    preview(root,frame)
    # Keep the useful review camera, restore all authored materials before save.
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source'/(frame+'.blend')))
    print('GEN2_MODEL_COMPLETE',json.dumps(report),flush=True)

if __name__ == '__main__':
    import sys
    sys.modules['build_gen2'] = sys.modules[__name__]
    for frame,builder in [('hx7_kestrel',kestrel),('m9_teamster',teamster),('ob12_medved',medved),('type09_tieshan',tieshan)]:
        if frame == 'hx7_kestrel':
            from build_kestrel import build as build_kestrel
            build_kestrel()
            continue
        if frame == 'm9_teamster':
            from build_teamster import teamster_v2
            builder = teamster_v2
        if frame == 'm9_teamster':
            from rig_teamster import prepare
            build(frame,builder,prepare)
        else:
            build(frame,builder)
