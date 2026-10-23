"""Visible Teamster alternate kits and arm weapons, authored in assembly coordinates.

Each asset contains Upper/Elbow/Wrist or Knee/Ankle mount groups. Godot attaches
these groups to the existing rigid joints, preserving the two-component limit.
"""
from pathlib import Path
import sys
import math
import bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
import build_gen2 as g

OUT=g.OUT/'teamster_parts'
OUT.mkdir(exist_ok=True)

def materials():
    g.materials=[]
    for name,rgb in zip(g.SLOTS,g.PALETTES['m9_teamster']):
        mat=bpy.data.materials.new(name)
        mat.diffuse_color=tuple(g.linear(int(rgb[i:i+2],16)/255) for i in [0,2,4])+(1,)
        mat.use_nodes=True
        mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=mat.diffuse_color
        g.materials.append(mat)

def build(asset, builder, index):
    g.parts=[]
    root=g.group(asset,(0,0,0))
    root['assembly_coordinates']=True
    builder(root)
    g.bake_vertex_tones()
    bpy.ops.object.select_all(action='DESELECT')
    root.select_set(True)
    for obj in root.children_recursive: obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(asset+'.glb')),export_format='GLB',use_selection=True,
        export_yup=True,export_colors=True,export_extras=True,export_animations=False)
    # Lay out the editable parts on a workbench after exporting aligned assets.
    root.location.x += (index%4)*1.7
    root.location.y += (index//4)*1.8
    return {'asset':asset,'triangles':sum(len(p.vertices)-2 for obj in g.parts for p in obj.data.polygons)}

def mount(root,name='Upper'): return g.group('Mount_'+name,(0,0,0),root)

def head(root):
    p=mount(root)
    g.box('Rangefinder_bridge',(.43,.065,.14),(0,1.245,-.01),1,p,.014)
    for s in [-1,1]:
        g.box('Optical_bunker',(.10,.09,.18),(s*.19,1.23,-.04),0,p,.016)
        g.lens('Long_range_lens',s*.19,1.235,-.145,.033,p)
    g.box('Survey_antenna',(.018,.13,.05),(0,1.33,.05),5,p,.003)

def cage(root):
    p=mount(root)
    for s in [-1,1]:
        g.rod('Recovery_cage_rail',(s*.30,.54,.17),(s*.34,1.06,.17),.027,5,p,10)
        g.box('Braced_hip_socket',(.09,.14,.19),(s*.29,.53,.10),1,p,.012)
    g.rod('Upper_cage_tie',(-.34,1.06,.17),(.34,1.06,.17),.023,5,p,10)
    g.box('Recovery_lifting_eye',(.20,.08,.07),(0,1.105,.17),2,p,.012)

def torso(root):
    p=mount(root)
    for s in [-1,1]:
        g.poly('Assault_cheek',[(s*.17,.72),(s*.34,.70),(s*.37,.95),(s*.22,1.06)],-.34,-.26,0,p,.015)
        for y in [.78,.91]:
            g.rod('Armour_bolt',(s*.28,y,-.346),(s*.28,y,-.36),.012,5,p,6)
    g.box('Chest_stand_off',(.29,.16,.045),(0,.88,-.33),1,p,.015)
    g.box('Lower_glacis_strip',(.51,.07,.045),(0,.68,-.31),0,p,.008)

def arm_servo(root,s):
    p=mount(root,'Elbow')
    for dx in [-.11,.11]:
        g.rod('Fine_control_rail',(s*.445+dx,.53,-.05),(s*.445+dx,.70,-.03),.014,2,p,10)
    g.box('Servo_encoder',(.12,.07,.07),(s*.445,.64,.07),1,p,.009)
    p=mount(root,'Wrist')
    g.box('Wrist_feedback_cuff',(.20,.04,.19),(s*.445,.51,-.13),5,p,.009)

def arm_shell(root,s):
    p=mount(root)
    g.box('Reinforced_pauldron',(.34,.10,.37),(s*.445,1.12,.0),1,p,.027)
    for z in [-.10,.09]: g.box('Shoulder_rib',(.35,.035,.035),(s*.445,1.15,z),5,p,.004)
    p=mount(root,'Elbow')
    g.poly('Forearm_bulwark',[(s*.445-.14,.74),(s*.445+.14,.74),(s*.445+.13,.53),(s*.445-.13,.53)],-.275,-.23,0,p,.014)

def leg_drive(root,s):
    p=mount(root)
    g.box('March_pump',(.10,.18,.13),(s*.355,.43,.12),5,p,.013)
    p=mount(root,'Knee')
    for dx in [-.105,.105]:
        g.rod('High_flow_leg_ram',(s*.235+dx,.12,.12),(s*.235+dx,.29,.10),.025,2,p,10)
    g.box('Drive_manifold',(.16,.08,.08),(s*.235,.22,.16),1,p,.009)

def leg_shell(root,s):
    p=mount(root,'Knee')
    g.box('Reinforced_knee',(.29,.09,.08),(s*.235,.31,-.23),0,p,.018)
    for dx in [-.13,.13]:
        g.box('Shin_bracing',(.055,.18,.22),(s*.235+dx,.18,.01),1,p,.011)
    p=mount(root,'Ankle')
    g.box('Wide_heel_spade',(.37,.10,.14),(s*.235,.07,.17),5,p,.012)
    g.box('Toe_applique',(.35,.055,.16),(s*.235,.11,-.23),0,p,.012)

def power(root):
    p=mount(root)
    for s in [-1,1]:
        g.box('Buffered_capacitor_canister',(.12,.30,.18),(s*.245,.86,.30),1,p,.024)
        for y in [.75,.96]: g.box('Capacitor_clamp',(.14,.025,.20),(s*.245,y,.30),5,p,.003)
    g.box('Protected_busbar',(.46,.06,.06),(0,.69,.37),2,p,.008)

def cooling(root):
    p=mount(root)
    for s in [-1,1]:
        g.box('High_flow_cooling_tower',(.11,.33,.15),(s*.24,.98,.46),1,p,.014)
        g.vent('Tower_fins',(s*.24,.98,.54),.085,.27,p,7)
    g.box('Cooling_plenum',(.36,.09,.11),(0,1.11,.44),0,p,.012)

def recovery(root):
    p=mount(root)
    g.box('Winch_frame',(.43,.24,.16),(0,1.0,.44),1,p,.015)
    g.rod('Winch_drum',(-.16,1.0,.55),(.16,1.0,.55),.085,5,p,16)
    for x in [-.17,.17]: g.rod('Winch_flange',(x,1.0,.55),(x+.015,1.0,.55),.105,2,p,16)
    for x in [-.12,-.08,-.04,0,.04,.08,.12]:
        g.box('Cable_wrap',(.015,.16,.16),(x,1.0,.55),3,p,.012)
    g.box('Folded_recovery_boom',(.14,.10,.38),(.34,1.18,.18),0,p,.015)
    g.rod('Boom_pivot',(.26,1.13,.27),(.43,1.13,.27),.06,5,p,12)

def support(root):
    p=mount(root,'Elbow')
    # Extended travelling rails, with a sliding wrist collar on the separate wrist mount.
    for dx in [-.095,.095]:
        g.rod('Support_extension_rail',(-.445+dx,.28,-.24),(-.445+dx,.69,-.05),.018,5,p,10)
    g.box('Extended_support_sleeve',(.18,.14,.16),(-.445,.59,-.10),1,p,.015)
    p=mount(root,'Wrist')
    g.box('Support_grip_cuff',(.21,.065,.20),(-.445,.505,-.13),2,p,.010)

def marksman(root):
    p=mount(root,'Elbow')
    for dx in [-.095,.095]:
        g.rod('Marksman_wrist_rail',(.445+dx,.43,-.16),(.445+dx,.70,-.05),.014,5,p,10)
    p=mount(root,'Wrist')
    x=.445
    g.box('BR90_receiver',(.16,.16,.34),(x,.55,-.30),0,p,.016)
    g.box('BR90_stock',(.12,.13,.25),(x,.55,-.035),1,p,.012)
    g.box('BR90_butt',(.18,.19,.055),(x,.55,.09),3,p,.009)
    g.box('BR90_fore_end',(.17,.12,.30),(x,.55,-.61),1,p,.015)
    g.rod('BR90_barrel',(x,.57,-.74),(x,.57,-1.13),.033,5,p,12)
    g.box('BR90_muzzle_brake',(.11,.075,.12),(x,.57,-1.15),5,p,.009)
    for z in [-1.12,-1.16,-1.20]: g.box('Brake_slot',(.115,.03,.012),(x,.57,z),3,p,.001)
    g.box('Moving_br90_magazine',(.095,.20,.13),(x,.37,-.32),5,p,.009,tilt=-.12)
    g.box('Trigger_grip',(.075,.11,.075),(x,.45,-.215),3,p,.009)
    g.box('Support_foregrip',(.085,.11,.075),(x,.45,-.415),3,p,.009)
    g.rod('BR90_scope',(x,.67,-.22),(x,.67,-.52),.035,3,p,12)
    for z in [-.24,-.48]: g.box('Scope_mount',(.08,.05,.025),(x,.63,z),5,p,.004)
    for z in [-.55,-.60,-.65]: g.box('Fore_end_vent',(.175,.027,.025),(x,.56,z),3,p,.002)
    g.group('Socket_br90_muzzle',(x,.57,-1.225),p)

def cannon(root):
    p=mount(root,'Wrist')
    x=.445
    g.box('AC30_arm_cradle',(.23,.18,.24),(x,.55,-.22),0,p,.018)
    g.rod('AC30_receiver',(x,.55,-.23),(x,.55,-.43),.115,5,p,16)
    barrels=g.group('Moving_cannon_barrels',(x,.55,-.43),p)
    for i in range(5):
        angle=i*math.tau/5
        dx=.065*math.cos(angle); dy=.065*math.sin(angle)
        g.rod('AC30_barrel',(x+dx,.55+dy,-.40),(x+dx,.55+dy,-.87),.022,5,barrels,10)
    for z in [-.48,-.79]: g.rod('AC30_barrel_clamp',(x,.55,z),(x,.55,z-.03),.10,1,barrels,16)
    g.box('Cannon_ammo_box',(.16,.23,.25),(x+.18,.54,-.23),1,p,.016)
    g.group('Socket_ac30_muzzle',(x,.55,-.89),p)

def breacher(root):
    p=mount(root,'Wrist')
    x=-.445
    g.box('SG12_receiver',(.19,.15,.26),(x,.55,-.26),0,p,.016)
    for dx in [-.042,.042]:
        g.rod('SG12_twin_barrel',(x+dx,.55,-.36),(x+dx,.55,-.72),.032,5,p,12)
    g.rod('SG12_drum',(x-.13,.49,-.27),(x+.13,.49,-.27),.10,1,p,16)
    g.box('Moving_breacher_pump',(.20,.07,.19),(x,.475,-.52),5,p,.012)
    g.box('SG12_muzzle_shield',(.20,.10,.045),(x,.55,-.72),1,p,.009)
    g.group('Socket_sg12_muzzle',(x,.55,-.755),p)

if __name__=='__main__':
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    materials()
    definitions=[('sensor_precision',head),('structure_braced',cage),('torso_heavy',torso),
        ('power_buffered',power),('service_upgraded',cooling),('module_recovery',recovery),
        ('arm_support_left',support),('arm_marksman_right',marksman),('arm_cannon_right',cannon),('arm_breacher_left',breacher)]
    for side,s in [('left',-1),('right',1)]:
        definitions += [('arm_precision_'+side,lambda r,s=s: arm_servo(r,s)),
            ('arm_reinforced_'+side,lambda r,s=s: arm_shell(r,s)),
            ('leg_fast_'+side,lambda r,s=s: leg_drive(r,s)),
            ('leg_braced_'+side,lambda r,s=s: leg_shell(r,s))]
    report=[build(name,builder,i) for i,(name,builder) in enumerate(definitions)]
    import json
    (g.QA/'teamster_parts_checks.json').write_text(json.dumps(report,indent=2))
    bpy.ops.wm.save_as_mainfile(filepath=str(g.ROOT/'art/source/teamster_parts.blend'))
    print('TEAMSTER_PARTS_COMPLETE',len(report),flush=True)
