"""Teamster service model, revision 2. Eight regions, fourteen component pivots.

Run with Blender --background --factory-startup --python art/models/build_teamster.py.
All geometry is authored here using the project's existing hard-surface helpers.
Reference: Gen2 brief + output/imagegen/04-m9-teamster-technical-profile.png.
"""
from pathlib import Path
import sys
import math
import json
import bpy
sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_gen2 as g

REGIONS = {}

def component(region, slot, pivot):
    obj = g.group('Component_' + slot.replace('.', '_'), pivot, region)
    obj['slot_id'] = slot
    return obj

def bolts(name, positions, parent, radius=.009, direction=(0, 0, -.01)):
    for i, p in enumerate(positions):
        q = tuple(p[j] + direction[j] for j in range(3))
        g.rod(name + '_%02d' % i, p, q, radius, 5, parent, 6)

def handle(name, x, y, z, parent, width=.075):
    g.rod(name, (x-width/2,y,z-.025),(x+width/2,y,z-.025),.006,5,parent,8)
    for dx in [-width/2,width/2]:
        g.rod(name+'_leg',(x+dx,y,z),(x+dx,y,z-.025),.006,5,parent,8)

def ring(name, centre, major, minor, parent, slot=5, axis='X'):
    from mathutils import Vector
    bpy.ops.mesh.primitive_torus_add(major_segments=16, minor_segments=6, location=g.pt(centre), major_radius=major, minor_radius=minor)
    obj=bpy.context.object
    if axis == 'X': obj.rotation_euler.y=math.pi/2
    elif axis == 'Z': obj.rotation_euler.x=math.pi/2
    return g.finish(obj,name,slot,parent)

def teamster_v2():
    REGIONS.clear()
    root=g.group('m9_teamster',(0,0,0))
    root['revision']='workshop_v2'
    root['manufacturer']='brannock_hale'
    root['size_class']='medium'
    root['triangle_budget']=20000
    pivots={'head':(0,1.13,0),'torso':(0,.79,0),'left_arm':(-.44,.94,0),
            'right_arm':(.44,.94,0),'left_leg':(-.23,.51,0),'right_leg':(.23,.51,0),
            'power':(0,.85,.26),'backpack':(0,.94,.38)}
    for key,pivot in pivots.items():
        region=g.group('Region_'+key,pivot,root)
        region['region_id']=key
        REGIONS[key]=region
    cage=component(REGIONS['torso'],'torso.structure',(0,.75,0))
    armour=component(REGIONS['torso'],'torso.armour',(0,.86,-.15))
    g.box('Crew_cell',(.48,.35,.33),(0,.84,.015),3,cage,.035)
    g.box('Hip_crossmember',(.47,.15,.30),(0,.51,.015),3,cage,.025)
    g.rod('Waist_turntable',(0,.53,0),(0,.66,0),.18,5,cage,16)
    for side in [-1,1]:
        g.rod('Chest_frame_rail',(side*.22,.59,.12),(side*.25,.99,.12),.033,3,cage,10)
        g.rod('Waist_hose',(side*.19,.55,-.08),(side*.23,.67,-.10),.018,5,cage,8)
        g.box('Hip_toolbox',(.16,.13,.14),(side*.24,.56,-.17),0,cage,.012)
        handle('Toolbox_latch',side*.24,.58,-.245,cage,.05)
        g.poly('Front_hip_skirt',[(side*.04,.59),(side*.24,.57),(side*.26,.42),(side*.06,.43)],-.23,-.17,0,armour,.009)
        g.box('Flank_armour',(.12,.30,.35),(side*.29,.80,.0),0,armour,.022)
    # Cross section of the chest: a genuine sloped glacis, not a flat decorated box.
    g.poly('Sloped_glacis',[(-.30,.66),(.30,.66),(.32,.92),(.24,1.08),(-.24,1.08),(-.32,.92)],-.275,.14,0,armour,.022)
    # Applied plates sit at a visibly different depth and leave a seam around the cage.
    g.poly('Chest_centre_applique',[(-.16,.72),(.16,.72),(.17,.99),(-.17,.99)],-.301,-.278,1,armour,.008)
    g.box('Hatch_coaming',(.29,.035,.24),(0,1.095,-.015),3,armour,.014)
    g.box('Crew_hatch',(.25,.025,.20),(0,1.12,-.02),0,armour,.013)
    handle('Hatch_handle',0,1.12,-.13,armour)
    for x in [-.205,.205]:
        handle('Glacis_grab',x,.99,-.276,armour,.095)
        for y in [.78,.84,.90]:
            g.box('Spare_track_link',(.075,.042,.025),(x,y,-.302),5,armour,.004)
            g.box('Track_link_slot',(.036,.012,.012),(x,y,-.319),3,armour,.001)
    bolts('Glacis_fastener',[(x,y,-.292) for x in [-.27,.27] for y in [.72,.90]],armour)
    g.number_mark('02',(0,.80,-.317),.08,armour)
    for s in [-1,1]:
        g.poly('Disruptive_chest_panel',[(s*.18,1.015),(s*.245,1.015),(s*.30,.94),(s*.245,.94)],-.30,-.284,1,armour,.002)
    head=component(REGIONS['head'],'head.sensor',(0,1.16,-.02))
    g.box('Cupola_base',(.31,.045,.27),(0,1.15,-.005),3,head,.013)
    g.box('Cupola_cast_shell',(.29,.105,.25),(0,1.205,-.005),0,head,.027)
    for x in [-.085,.085]:
        g.box('Recessed_camera_well',(.075,.068,.025),(x,1.21,-.139),3,head,.008)
        g.lens('Cupola_camera',x,1.21,-.158,.023,head)
    for s in [-1,1]:
        for z in [-.07,.03]:
            g.box('Side_vision_block',(.014,.027,.05),(s*.151,1.21,z),4,head,.003)
    g.box('Periscope_stalk',(.065,.045,.052),(.04,1.278,.015),3,head,.005)
    g.box('Periscope_glass',(.048,.025,.012),(.04,1.284,-.017),4,head,.002)
    bolts('Cupola_bolt',[(x,1.23,-.14) for x in [-.13,.13]],head,.006)
    # Each limb has exactly two component roots: drive and replaceable protection.
    for s,side in [(-1,'left'),(1,'right')]:
        x=s*.235
        drive=component(REGIONS[side+'_leg'],side+'_leg.drive',(x,.51,0))
        shell=component(REGIONS[side+'_leg'],side+'_leg.armour',(x,.29,-.03))
        for y,z,r in [(.50,.015,.080),(.315,-.055,.074),(.115,.015,.065)]:
            g.rod(side+'_Leg_joint',(x-.105,y,z),(x+.105,y,z),r,3,drive,16)
            for dx in [-.11,.11]:
                ring(side+'_Joint_collar',(x+dx,y,z),r*.82,.008,drive)
        g.box('Angled_thigh_core',(.16,.22,.16),(x,.415,.015),3,drive,.009,tilt=-.19)
        g.box('Shin_core',(.15,.21,.16),(x,.20,.015),3,drive,.009,tilt=.11)
        for dx in [-.09,.09]:
            g.rod('Calf_ram',(x+dx,.13,.105),(x+dx,.30,.09),.019,5,drive,10)
            g.rod('Polished_piston',(x+dx,.30,.09),(x+dx,.43,.06),.010,2,drive,10)
        g.poly('Thigh_plate',[(x-.105,.51),(x+.105,.51),(x+.10,.35),(x-.09,.34)],-.12,.12,0,shell,.016)
        g.box('Knee_shield',(.25,.14,.12),(x,.31,-.145),1,shell,.025)
        g.poly('Shin_plate',[(x-.12,.255),(x+.12,.255),(x+.14,.105),(x-.14,.105)],-.145,.125,0,shell,.018)
        g.box('Boot_armour',(.32,.12,.43),(x,.075,-.085),0,shell,.022)
        g.box('Boot_sole',(.33,.025,.44),(x,.0125,-.085),3,shell,.006)
        for dx in [-.105,0,.105]:
            g.box('Toe_tread',(.065,.035,.018),(x+dx,.045,-.31),5,shell,.003)
        bolts('Leg_plate_bolt',[(x+dx,y,-.162) for dx in [-.085,.085] for y in [.17,.25]],shell,.007)
        ring('Ankle_tie_down',(x+s*.17,.12,-.05),.025,.007,shell,axis='Z')
        g.box('Shin_disruptive_patch',(.08,.12,.012),(x-s*.04,.18,-.164),1,shell,.002)
        x=s*.445
        actuator=component(REGIONS[side+'_arm'],side+'_arm.actuator',(x,.96,0))
        plate=component(REGIONS[side+'_arm'],side+'_arm.armour',(x,.84,-.015))
        g.rod('Shoulder_coupling',(s*.29,.97,0),(s*.49,.97,0),.112,3,actuator,16)
        ring('Shoulder_seal',(s*.345,.97,0),.104,.013,actuator)
        g.box('Upper_arm_drive',(.16,.19,.18),(x,.82,.0),3,actuator,.014)
        g.rod('Elbow_pin',(x-.10,.705,-.045),(x+.10,.705,-.045),.068,5,actuator,16)
        g.rod('Arm_ram',(x+s*.09,.75,.08),(x+s*.09,.9,.10),.018,5,actuator,10)
        g.rod('Arm_piston',(x+s*.09,.9,.10),(x+s*.09,1.0,.10),.010,2,actuator,10)
        g.box('Shoulder_armour',(.29,.22,.33),(x,1.0,0),0,plate,.040)
        g.box('Forearm_armour',(.235,.235,.29),(x,.64,-.10),0,plate,.025)
        g.box('Shoulder_camo',(.17,.11,.016),(x,1.01,-.176),1,plate,.004)
        bolts('Shoulder_rivet',[(x+dx,y,-.18) for dx in [-.10,.10] for y in [.95,1.06]],plate,.008)
        g.box('Wrist_cuff',(.17,.04,.17),(x,.505,-.13),3,actuator,.008)
        g.box('Hand_palm',(.15,.09,.14),(x,.47,-.16),3,actuator,.012)
        for finger in [-1,0,1]:
            g.box('Grip_finger',(.034,.075,.05),(x+finger*.043,.46,-.245),5,actuator,.006)
        if side == 'right':
            g.rifle('AR40_Longhorn',x,.54,actuator)
            g.box('Rifle_handguard',(.16,.11,.26),(x,.54,-.49),0,actuator,.012)
            for z in [-.40,-.45,-.50,-.55]:
                g.box('Rifle_cooling_slot',(.164,.025,.018),(x,.56,z),3,actuator,.002)
            g.rod('Rifle_optic',(x,.655,-.24),(x,.655,-.40),.026,3,actuator,10)
            for z in [-.25,-.37]: ring('Optic_clamp',(x,.655,z),.03,.006,actuator,axis='Z')
        else:
            stake=g.group('PB4_Stake_driver',(x,.58,-.22),actuator)
            g.box('Stake_support',(.19,.12,.17),(x,.60,-.22),0,stake,.015)
            g.rod('PB4_Revolver',(x,.58,-.24),(x,.58,-.37),.10,5,stake,16)
            for i in range(6):
                a=i*math.tau/6
                g.rod('PB4_Charge',(x+.067*math.cos(a),.58+.067*math.sin(a),-.371),(x+.067*math.cos(a),.58+.067*math.sin(a),-.391),.021,3,stake,8)
            g.rod('PB4_Stake',(x,.58,-.385),(x,.58,-.63),.032,5,stake,12,end_radius=0)
    power=component(REGIONS['power'],'power.plant',(0,.84,.26))
    g.box('HT12_Armoured_battery',(.39,.26,.20),(0,.79,.27),0,power,.022)
    g.box('HT12_Turbine_casing',(.35,.18,.19),(0,.99,.25),5,power,.020)
    for x in [-.125,.125]:
        g.rod('Turbine_mount',(x,.67,.20),(x,.99,.20),.016,3,power,10)
        g.rod('Fuel_hose',(x,.70,.37),(x,.97,.37),.014,3,power,8)
    bolts('Battery_service_bolt',[(x,y,.381) for x in [-.15,.15] for y in [.70,.86]],power,.008,(0,0,.012))
    service=component(REGIONS['backpack'],'backpack.service',(0,.92,.39))
    module=component(REGIONS['backpack'],'backpack.module',(.445,1.20,.02))
    g.box('Cooling_frame',(.46,.35,.075),(0,.85,.405),3,service,.010)
    g.vent('Turbine_louvres',(0,.88,.455),.35,.25,service,7)
    for s in [-1,1]:
        x=s*.275
        g.box('Jerrycan',(.105,.17,.09),(x,.76,.33),0,service,.012)
        g.box('Jerrycan_handle',(.055,.02,.04),(x,.855,.33),5,service,.003)
        g.rod('Antenna_base',(x,1.02,.22),(x,1.10,.22),.019,5,service,10)
        g.rod('Whip_antenna',(x,1.10,.22),(x+s*.025,1.46,.25),.004,3,service,8)
    # A cable reel and two tools read clearly in rear/region inspection.
    for y in [.66,.69,.72]:
        g.rod('Tow_cable',(-.23,y,.45),(.23,y,.45),.010,5,service,8)
    g.rod('Tool_shaft',(-.20,.65,.49),(-.20,1.03,.49),.012,2,service,8)
    g.box('Tool_head',(.15,.035,.035),(-.20,1.03,.49),5,service,.003)
    pod=g.group('Hornet_12_cell_pod',(.445,1.21,.015),module)
    g.rod('Pod_mount',(.36,1.04,.10),(.445,1.17,.10),.047,3,pod,12)
    g.box('Hornet_housing',(.32,.27,.39),(.445,1.235,-.015),0,pod,.026)
    g.box('Hornet_face',(.29,.24,.020),(.445,1.235,-.218),5,pod,.006)
    for row in range(3):
        for col in range(4):
            g.lens('Hornet_cell_%02d'%(row*4+col),.445+(col-1.5)*.065,1.235+(row-1)*.070,-.233,.024,pod,3)
    for x in [.29,.60]:
        g.box('Pod_strap',(.018,.285,.31),(x,1.235,.015),5,pod,.003)
    g.number_mark('09',(.445,1.23,-.261),.052,pod)
    # Angle the front plate and all its fittings together; the top recedes toward the crew cell.
    sloped = ('Sloped_glacis','Chest_centre','Glacis_','Spare_track','Track_link','Disruptive_chest','Tactical_number_02')
    for obj in g.parts:
        if obj.parent == armour and obj.name.startswith(sloped):
            world = obj.matrix_world.copy()
            inverse = world.inverted()
            for vertex in obj.data.vertices:
                point = world @ vertex.co
                point.y -= max(0, point.z - .66) * .35
                vertex.co = inverse @ point
    return root

def export_regions():
    destination=g.OUT/'teamster_regions'
    destination.mkdir(exist_ok=True)
    report={}
    for region_id, region in REGIONS.items():
        bpy.ops.object.select_all(action='DESELECT')
        region.select_set(True)
        for obj in region.children_recursive: obj.select_set(True)
        # Preserve assembly coordinates so separate exports snap together at the same origin.
        bpy.ops.export_scene.gltf(filepath=str(destination/(region_id+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_colors=True,export_extras=True,export_animations=False)
        report[region_id]={'file':str(destination/(region_id+'.glb')),'components':[c.get('slot_id') for c in region.children], 'origin':'shared assembly coordinates'}
    (g.QA/'teamster_regions.json').write_text(json.dumps(report,indent=2))

if __name__ == '__main__':
    from rig_teamster import prepare
    # Make the executing module available under its import name for the rig's region map.
    sys.modules['build_teamster'] = sys.modules[__name__]
    g.build('m9_teamster',teamster_v2,prepare)
    export_regions()
