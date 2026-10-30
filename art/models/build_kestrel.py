"""HX-7 Kestrel revision 4: long-legged airframe, swept head and rigid components.

Blender --background --factory-startup --python art/models/build_kestrel.py
Coordinates follow build_gen2: Y up, -Z forward, tabletop metres.
"""
from pathlib import Path
import sys
import math
import bpy
import bmesh
from mathutils import Vector
sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_gen2 as g

REGIONS = {}

def mesh_part(name, vertices, faces, slot, parent, bevel=0):
    mesh=bpy.data.meshes.new(name)
    mesh.from_pydata([g.pt(v) for v in vertices],[],faces)
    bm=bmesh.new(); bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(mesh); bm.free()
    obj=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(obj)
    return g.finish(obj,name,slot,parent,bevel)

def shell_panel(name, outline, thickness, slot, parent):
    """Closed cheek or fin, with its inner surface offset towards the centreline."""
    n=len(outline)
    inner=[(x-thickness if x>0 else x+thickness,y,z) for x,y,z in outline]
    return mesh_part(name,outline+inner,
        [tuple(range(n)),tuple(reversed(range(n,n*2)))]+
        [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)],slot,parent,.0008)

def swept_head(head):
    """Avian aircraft nose: thin cambered brow, wraparound slit and swept cheeks."""
    g.rod('Neck_gimbal',(0,1.16,.016),(0,1.255,.016),.027,3,head,16)
    g.rod('Neck_collar',(0,1.177,.016),(0,1.197,.016),.041,5,head,16)
    g.rod('Neck_pitch_axle',(-.050,1.245,.006),(.050,1.245,.006),.026,3,head,16)
    g.ellipsoid('Head_avionics_core',(.118,.070,.132),(0,1.266,.013),3,head,16,8)
    # Fore/aft stations, rather than rings around a vertical sphere. The nose
    # projects forward while the cambered crown sweeps up into the rear spine.
    stations=[(-.216,.006,1.298,1.285),(-.182,.033,1.318,1.287),
        (-.125,.069,1.345,1.293),(-.045,.086,1.361,1.301),
        (.025,.078,1.356,1.298),(.080,.052,1.334,1.283),
        (.096,.018,1.312,1.281)]
    verts=[]
    for z,w,top,lower in stations:
        depth=top-lower
        verts += [(0,top,z),(.50*w,top-depth*.10,z),(.88*w,top-depth*.35,z),
            (w,top-depth*.70,z),(.94*w,lower+depth*.10,z),(0,lower,z),
            (-.94*w,lower+depth*.10,z),(-w,top-depth*.70,z),(-.88*w,top-depth*.35,z),
            (-.50*w,top-depth*.10,z)]
    n=10
    faces=[tuple(reversed(range(n)))]
    for j in range(len(stations)-1):
        faces += [(j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i) for i in range(n)]
    faces += [tuple(range((len(stations)-1)*n,len(stations)*n))]
    crown=mesh_part('Swept_wedge_crown',verts,faces,0,head)
    crown['trim_projection']='top'
    for p in crown.data.polygons:
        p.use_smooth=len(p.vertices)==4
    crown.data.use_auto_smooth=True
    crown.data.auto_smooth_angle=math.radians(32)
    # The visor follows the planform, not a flat bar across the front of a dome.
    path=[(-.071,1.291,-.112),(-.052,1.286,-.160),(-.025,1.282,-.193),
          (0,1.281,-.207),(.025,1.282,-.193),(.052,1.286,-.160),(.071,1.291,-.112)]
    def band(name,height,slot,offset):
        v=[(x,y+dy-.012,z+offset) for dy in [0,height] for x,y,z in path]
        faces=[(i,i+1,i+1+len(path),i+len(path)) for i in range(len(path)-1)]
        return mesh_part(name,v,faces,slot,head)
    band('Visor_recess_gasket',.017,3,.002)
    # Keep a dark border above and below the luminous strip.
    lens=band('Single_amber_slit',.007,4,-.001)
    for v in lens.data.vertices: v.co.z+=.004
    for s,tag in [(-1,'L'),(1,'R')]:
        outline=[(s*.053,1.288,-.161),(s*.080,1.300,-.075),
            (s*.076,1.286,.035),(s*.064,1.247,.026),
            (s*.034,1.209,-.088),(s*.035,1.251,-.128)]
        shell_panel(tag+'_Swept_white_cheek',outline,.008,1,head)
        shell_panel(tag+'_Pointed_face_chine',[(s*.005,1.276,-.188),
            (s*.032,1.274,-.169),(s*.026,1.235,-.151),
            (s*.003,1.219,-.164)],.002,1,head)
        # Layered upper cheek insert and cheek vent, rather than human eye sockets.
        shell_panel(tag+'_Cheek_service_inset',[(s*.081,1.279,-.066),
            (s*.078,1.282,-.013),(s*.075,1.265,-.005),
            (s*.073,1.254,-.055)],.002,5,head)
        for j in range(3):
            z=-.047+j*.012
            g.rod(tag+'_Cheek_vent',(s*.080,1.263,z),
                (s*.083,1.277,z+.005),.0022,3,head,5)
        g.rod(tag+'_Temple_pivot',(s*.064,1.277,.025),(s*.081,1.277,.025),.013,3,head,12)
        g.rod(tag+'_Temple_hub',(s*.081,1.277,.025),(s*.084,1.277,.025),.007,5,head,10)
        for y,z in [(1.285,-.087),(1.277,-.018)]:
            g.rod(tag+'_Cheek_fastener',(s*.075,y,z),(s*.080,y,z),.0028,5,head,6)
        tube(tag+'_Neck_cable',[(s*.025,1.188,.035),(s*.038,1.218,.057),
            (s*.038,1.264,.061)],.005,5,head)
    # Fine dorsal fin leans aft in side view. A shallow root fairing seats it.
    g.rod('Antenna_root',(0,1.340,.042),(0,1.365,.052),.008,5,head,8)
    mesh_part('Swept_blade_antenna',
        [(-.0025,1.35,.039),(-.0025,1.462,.092),(-.0025,1.365,.062),
         (.0025,1.35,.039),(.0025,1.462,.092),(.0025,1.365,.062)],
        [(0,1,2),(5,4,3),(0,3,4,1),(1,4,5,2),(2,5,3,0)],1,head)

def head_reviews(label):
    """Head-only front/profile/three-quarter evidence at the same review scale."""
    scene=bpy.context.scene; camera=scene.camera
    saved=(camera.matrix_world.copy(),camera.data.ortho_scale,
           scene.render.resolution_x,scene.render.resolution_y,scene.render.filepath)
    head=bpy.data.objects.get('Region_head')
    descendants=set(head.children_recursive)
    meshes=[o for o in scene.objects if o.type=='MESH']
    hidden=[o.hide_render for o in meshes]
    for obj in meshes: obj.hide_render=obj not in descendants
    camera.data.ortho_scale=.42
    scene.render.resolution_x=1100; scene.render.resolution_y=1100
    target=g.pt((0,1.305,-.046))
    folder=g.ROOT/'artifacts/kestrel-head'; folder.mkdir(exist_ok=True)
    for name,pos in [('front',(0,1.305,-2)),('side',(2,1.305,-.046)),
                     ('three-quarter',(.9,1.53,-1.6))]:
        camera.location=g.pt(pos)
        camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(folder/(label+'_'+name+'.png'))
        bpy.ops.render.render(write_still=True)
    for obj,hide in zip(meshes,hidden): obj.hide_render=hide
    camera.matrix_world=saved[0]; camera.data.ortho_scale=saved[1]
    scene.render.resolution_x=saved[2]; scene.render.resolution_y=saved[3]
    scene.render.filepath=saved[4]

def loft(name, sections, slot, parent, sides=16):
    """Elliptical transverse stations: (height, centre_x, centre_z, halfwidth, depth).
    Shared smooth rings produce actual compound curvature, rather than bevelled boxes.
    """
    verts = [g.pt((x+rx*math.cos(i*math.tau/sides), y,
                   z+rz*math.sin(i*math.tau/sides)))
             for y,x,z,rx,rz in sections for i in range(sides)]
    faces = [tuple(reversed(range(sides)))]
    for j in range(len(sections)-1):
        for i in range(sides):
            a=j*sides+i; b=j*sides+(i+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.append(tuple(range((len(sections)-1)*sides,len(sections)*sides)))
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces)
    bm=bmesh.new(); bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(mesh); bm.free()
    obj=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(obj)
    for p in mesh.polygons: p.use_smooth=len(p.vertices)==4
    return g.finish(obj,name,slot,parent)

def fairing(name,x,z,stations,slot,parent):
    return loft(name,[(y,x+dx,z+dz,w,d) for y,dx,dz,w,d in stations],slot,parent)

def tube(name, points, radius, slot, parent):
    # Polygonal hydraulic lines stay inexpensive and editable.
    for i in range(len(points)-1):
        g.rod(name+'_%02d'%i,points[i],points[i+1],radius,slot,parent,8)

def ring(name,centre,radius,parent,axis='X',slot=5):
    bpy.ops.mesh.primitive_torus_add(major_segments=16,minor_segments=4,
        major_radius=radius,minor_radius=.006,location=g.pt(centre))
    obj=bpy.context.object
    if axis=='X': obj.rotation_euler.y=math.pi/2
    elif axis=='Z': obj.rotation_euler.x=math.pi/2
    return g.finish(obj,name,slot,parent)

def fasteners(name,points,parent):
    for i,(x,y,z) in enumerate(points):
        g.rod(name+'_%02d'%i,(x,y,z),(x,y,z-.005),.0045,5,parent,6)

def component(region,slot,pivot):
    obj=g.group('Component_'+slot.replace('.','_'),pivot,region)
    obj['slot_id']=slot
    return obj

def linear_map(value, knots):
    for (a,b),(c,d) in zip(knots,knots[1:]):
        if value <= c: return b+(value-a)*(d-b)/(c-a)
    a,b=knots[-2]; c,d=knots[-1]
    return d+(value-c)*(d-b)/(c-a)

def proportions(root):
    """Move the skeleton and its surfaces together, keeping ground and head fixed.

    Bone stations, mesh fittings and component pivots share one coordinate map;
    this prevents a long-leg pass from leaving joints or inspection roots behind.
    """
    bpy.context.view_layer.update()
    objects=[root]+list(root.children_recursive)
    def depth(obj):
        count=0
        while obj.parent is not None: count+=1; obj=obj.parent
        return count
    objects.sort(key=depth)
    matrices={o:o.matrix_world.copy() for o in objects}
    vertices={o:[o.matrix_world @ v.co for v in o.data.vertices] for o in g.parts}
    def region(obj):
        while obj is not None:
            if obj.name.startswith('Region_'): return obj.name[7:]
            obj=obj.parent
        return ''
    def point(p,key):
        x,y,z=p.x,p.z,-p.y
        if key.endswith('_leg'):
            side=-1 if key.startswith('left') else 1
            x=side*.153+(x-side*.145)*.90
            y=linear_map(y,[(0,0),(.11,.11),(.425,.47),(.67,.81),(.75,.89)])
            z*=.88
        elif key.endswith('_arm'):
            side=-1 if key.startswith('left') else 1
            x=side*.275+(x-side*.30)*.86
            y=linear_map(y,[(.40,.455),(.535,.59),(.835,.87),(1.075,1.075),(1.20,1.20)])
            z*=.93
        elif key=='torso':
            x*=.84; z*=.88
            y=linear_map(y,[(.60,.735),(.67,.81),(.75,.885),(.96,1.025),(1.17,1.17)])
        elif key=='power':
            x*=.94
            y=linear_map(y,[(.75,.84),(1.0,1.045),(1.25,1.25)])
        elif key=='backpack': x*=.98
        return g.pt((x,y,z))
    # Preserve all world transforms while updating the authored mount positions.
    for obj in objects:
        world=matrices[obj].copy(); world.translation=point(world.translation,region(obj))
        obj.matrix_world=world
        bpy.context.view_layer.update()
    joints=('Leg_axle','Axle_collar','Heel_fan','Fan_','Elbow_pin','Shoulder_gimbal','Shoulder_seal')
    for obj,coords in vertices.items():
        key=region(obj); inverse=obj.matrix_world.inverted()
        centre=sum(coords,Vector())/len(coords)
        mapped_centre=point(centre,key)
        preserve_joint=key.endswith(('_leg','_arm')) and any(n in obj.name for n in joints)
        for vertex,old in zip(obj.data.vertices,coords):
            mapped=point(old,key)
            if preserve_joint: mapped.z=mapped_centre.z+(old.z-centre.z)*.90
            vertex.co=inverse @ mapped
        obj.data.update()
    root['revision']='airframe_proportions_v4'
    root['hip_height']=.81

def linear_rifle(x,y,parent):
    gun=g.group('LR3_Linear_Rifle',(x,y,-.19),parent)
    g.box('LR3_Receiver',(.084,.080,.28),(x,y,-.28),5,gun,.006)
    g.box('LR3_Capacitor_stock',(.082,.090,.13),(x,y,-.025),1,gun,.007)
    for dx in [-.032,.032]:
        g.rod('LR3_Stock_strut',(x+dx,y-.032,-.09),(x+dx,y-.040,.035),.009,5,gun,8)
    g.box('LR3_Magazine',(.061,.105,.085),(x,y-.082,-.28),5,gun,.004)
    g.box('LR3_Sight_rail',(.026,.018,.18),(x,y+.052,-.28),3,gun,.002)
    # Long independent rails with a clear channel. Narrow braces leave negative space.
    for dy in [-.026,.026]:
        g.box('LR3_Linear_rail',(.027,.014,.63),(x,y+dy,-.725),5,gun,.002)
        g.box('LR3_Rail_tip',(.034,.018,.05),(x,y+dy,-1.025),3,gun,.002)
    for z in [-.43,-.71,-.985]:
        g.box('LR3_Rail_bridge',(.014,.077,.014),(x,y,z),3,gun,.001)
    for z in [-.91,-.945,-.98]:
        for dy in [-.034,.034]:
            g.box('LR3_Cooling_fin',(.052,.006,.012),(x,y+dy,z),3,gun,.001)
    g.rod('LR3_Optic',(x,y+.076,-.24),(x,y+.076,-.36),.012,3,gun,12)
    g.lens('LR3_Optic_glass',x,y+.076,-.365,.009,gun)
    g.box('LR3_Trigger_guard',(.014,.055,.065),(x,y-.055,-.17),5,gun,.003)
    muzzle=g.group('Socket_rifle_muzzle',(x,y,-1.05),gun)
    muzzle['socket_id']='rifle_muzzle'
    return gun

def kestrel_v2():
    REGIONS.clear()
    root=g.group('hx7_kestrel',(0,0,0))
    root['revision']='swept_head_v3'; root['triangle_budget']=20000
    root['manufacturer']='halcyon_aeronautics'
    root['configuration']='walking; four AGM-M stores; stowed VB-2'
    pivots={'torso':(0,.96,0),'head':(0,1.27,0),
            'left_arm':(-.29,1.075,0),'right_arm':(.29,1.075,0),
            'left_leg':(-.145,.69,0),'right_leg':(.145,.69,0),
            'power':(0,1,.24),'backpack':(0,1.07,.20)}
    for key,pos in pivots.items():
        REGIONS[key]=g.group('Region_'+key,pos,root)
        REGIONS[key]['region_id']=key
    frame=component(REGIONS['torso'],'torso.structure',(0,.9,0))
    armour=component(REGIONS['torso'],'torso.armour',(0,.99,-.10))
    g.rod('Waist_turntable',(0,.67,0),(0,.79,0),.10,3,frame,16)
    fairing('Pelvic_fuselage',0,0,[(.62,0,0,.08,.07),(.66,0,0,.15,.09),
        (.70,0,0,.155,.09),(.72,0,0,.09,.065)],0,frame)
    fairing('Chest_fuselage',0,0,[(.76,0,-.08,.035,.05),(.84,0,-.04,.12,.13),
        (.94,0,-.01,.19,.14), (1.04,0,.0,.20,.12),
        (1.12,0,.015,.16,.085),(1.17,0,.02,.09,.05)],0,armour)
    # Canopy follows the changing chest section, giving a bowed nose in profile.
    fairing('Canopy_pressure_shell',0,0,[(.79,0,-.145,.018,.075),
        (.85,0,-.125,.055,.100),(.96,0,-.105,.074,.105),
        (1.055,0,-.060,.062,.075),(1.095,0,-.040,.035,.055)],3,armour)
    fairing('Canopy_seal',0,-.165,[(.775,0,-.080,.010,.008),
        (.84,0,-.070,.055,.015),(.96,0,-.035,.079,.023),
        (1.055,0,.020,.072,.017),(1.095,0,.050,.045,.008)],1,armour)
    fairing('Tinted_canopy',0,-.176,[(.80,0,-.073,.010,.004),
        (.85,0,-.065,.043,.008),(.96,0,-.035,.061,.013),
        (1.05,0,.016,.056,.009),(1.075,0,.039,.032,.004)],5,armour)
    for s in [-1,1]:
        g.rod('Chest_frame_spar',(s*.12,.78,.04),(s*.18,1.08,.06),.020,3,frame,10)
        fairing('Flank_intake_lip',s*.183,-.085,[(.92,0,0,.035,.048),
            (.97,s*.012,-.015,.055,.075),(1.06,0,0,.055,.070),
            (1.10,-s*.012,.02,.03,.04)],1,armour)
        g.poly('Intake_recess',[(s*.16,.965),(s*.215,.96),(s*.225,1.055),(s*.17,1.075)],-.174,-.165,3,armour,.002)
        for y in [.982,1.002,1.022,1.042]:
            g.box('Intake_vane',(.044,.006,.009),(s*.193,y,-.181),5,armour,.001)
        shell_panel('White_chest_cheek',[(s*.027,.78,-.24),(s*.115,.83,-.205),
            (s*.18,.96,-.137),(s*.135,.835,-.185),(s*.06,.765,-.217)],.008,1,armour)
        tube('Waist_flexible_line',[(s*.09,.72,.09),(s*.12,.76,.12),(s*.15,.86,.10)],.009,5,frame)
        fasteners('Chest_quarter_turn',[(s*.125,.88,-.183),(s*.15,1.08,-.088)],armour)
    g.poly('Rescue_arrow',[(.105,.93),(.128,.945),(.116,.945),(.116,.98),(.106,.98)],-.183,-.180,2,armour,.0005)
    head=component(REGIONS['head'],'head.sensor',(0,1.28,0))
    swept_head(head)
    for s,tag,side in [(-1,'L','left'),(1,'R','right')]:
        x=s*.145
        drive=component(REGIONS[side+'_leg'],side+'_leg.drive',(x,.68,0))
        shell=component(REGIONS[side+'_leg'],side+'_leg.armour',(x,.40,0))
        for y,z,r in [(.67,.01,.062),(.425,-.015,.058),(.105,.0,.045)]:
            g.rod(tag+'_Leg_axle',(x-.081,y,z),(x+.081,y,z),r,3,drive,16)
            ring(tag+'_Axle_collar',(x+s*.084,y,z),r*.8,drive)
        fairing(tag+'_Thigh_shell',x,.015,[(.44,0,0,.043,.054),
            (.50,0,.01,.055,.059),(.61,0,.005,.067,.068),
            (.69,0,0,.055,.055),(.71,0,0,.04,.04)],0,shell)
        fairing(tag+'_White_thigh_inlay',x-s*.02,-.059,[(.475,0,0,.017,.008),
            (.53,0,-.002,.030,.014),(.65,0,-.005,.034,.012),(.68,0,.003,.02,.008)],1,shell)
        fairing(tag+'_Knee_guard',x,-.069,[(.379,0,0,.03,.015),
            (.413,0,-.012,.065,.034),(.45,0,0,.055,.025),(.47,0,.01,.027,.012)],0,shell)
        fairing(tag+'_Calf_nacelle',x,.035,[(.10,0,-.02,.035,.045),
            (.16,0,-.015,.052,.065),(.28,0,0,.073,.085),
            (.365,0,.015,.062,.065),(.41,0,.01,.040,.040)],1,shell)
        fairing(tag+'_Nacelle_cowling',x+s*.043,.11,[(.13,0,.005,.025,.03),
            (.19,0,.015,.043,.04),(.28,0,.025,.046,.047),
            (.35,0,.015,.038,.036),(.38,0,0,.015,.015)],0,shell)
        g.poly(tag+'_Calf_orange',[(x-.025,.19),(x+.026,.19),(x+.035,.25),(x-.025,.265)],-.054,-.046,2,shell,.002)
        g.rod(tag+'_Heel_fan_shroud',(x,.12,.105),(x,.12,.195),.061,5,drive,20)
        g.rod(tag+'_Fan_dark_interior',(x,.12,.193),(x,.12,.198),.049,3,drive,20)
        ring(tag+'_Fan_lip',(x,.12,.20),.053,drive,'Z',1)
        g.rod(tag+'_Fan_hub',(x,.12,.197),(x,.12,.207),.014,5,drive,10)
        for i in range(8):
            a=i*math.tau/8
            g.rod(tag+'_Fan_stator',(x+.018*math.cos(a),.12+.018*math.sin(a),.201),
                (x+.045*math.cos(a+.22),.12+.045*math.sin(a+.22),.201),.004,5,drive,5)
        for dx in [-.075,.075]:
            g.rod(tag+'_Calf_ram',(x+dx,.16,.08),(x+dx,.32,.10),.012,5,drive,10)
            g.rod(tag+'_Calf_piston',(x+dx,.32,.10),(x+dx,.43,.04),.007,2,drive,8)
        fairing(tag+'_Instep',x,-.060,[(.016,0,-.015,.052,.115),
            (.04,0,0,.056,.120),(.075,0,.025,.045,.090),(.11,0,.045,.029,.050)],1,shell)
        g.box(tag+'_Sole',(.112,.016,.25),(x,.008,-.075),3,shell,.003)
        for dx in [-.042,.042]:
            g.poly(tag+'_Toe_claw',[(x+dx-.014,.018),(x+dx+.014,.018),(x+dx+.012,.065)],-.258,-.193,5,drive,.002)
        fasteners(tag+'_Nacelle_latch',[(x-.025,.18,-.045),(x+.025,.32,-.040)],shell)
        g.vent(tag+'_Calf_service_vent',(x,.335,-.044),.054,.047,shell,4)
        g.box(tag+'_Thigh_access_panel',(.045,.068,.010),(x,.60,-.051),0,shell,.007)
        fasteners(tag+'_Thigh_access_screw',[(x-.015,.619,-.058),(x+.015,.579,-.058)],shell)
        if tag=='L': g.number_mark('01',(x,.30,-.064),.043,shell,0)
        ax=s*.30
        actuator=component(REGIONS[side+'_arm'],side+'_arm.actuator',(ax,1.07,0))
        plate=component(REGIONS[side+'_arm'],side+'_arm.armour',(ax,.82,-.02))
        g.rod(tag+'_Shoulder_gimbal',(s*.20,1.075,0),(s*.36,1.075,0),.067,3,actuator,16)
        ring(tag+'_Shoulder_seal',(s*.255,1.075,0),.066,actuator)
        fairing(tag+'_Shoulder_fairing',ax,0,[(.975,0,-.01,.045,.065),
            (1.015,s*.01,0,.085,.105),(1.09,0,.01,.100,.113),
            (1.15,-s*.014,.018,.066,.078),(1.17,-s*.02,.018,.027,.036)],0,plate)
        g.poly(tag+'_Shoulder_white',[(ax-s*.06,1.03),(ax+s*.06,.995),(ax+s*.065,1.12),(ax-s*.015,1.15)],-.098,-.091,1,plate,.004)
        g.rod(tag+'_Humerus',(ax,.86,0),(ax,1.025,0),.035,3,actuator,12)
        g.rod(tag+'_Elbow_pin',(ax-.06,.835,-.02),(ax+.06,.835,-.02),.047,5,actuator,16)
        fairing(tag+'_Forearm_fairing',ax,-.055,[(.595,0,-.025,.032,.046),
            (.64,s*.005,-.025,.052,.066),(.74,0,-.01,.068,.080),
            (.80,0,0,.056,.065),(.815,0,.005,.034,.035)],1,plate)
        fairing(tag+'_Forearm_navy_inlay',ax,-.117,[(.62,0,-.005,.017,.008),
            (.70,0,-.008,.037,.015),(.77,0,.005,.039,.012),(.79,0,.013,.02,.006)],0,plate)
        g.box(tag+'_Orange_cuff',(.047,.026,.012),(ax,.636,-.144),2,plate,.003)
        fasteners(tag+'_Forearm_latch',[(ax-.032,.74,-.135),(ax+.032,.68,-.139)],plate)
        tube(tag+'_Upper_arm_cable',[(ax+s*.036,.87,.024),
            (ax+s*.047,.93,.041),(ax+s*.038,1.025,.035)],.007,5,actuator)
        g.rod(tag+'_Wrist',(ax,.54,-.10),(ax,.605,-.085),.034,3,actuator,12)
        g.box(tag+'_Palm',(.087,.072,.082),(ax,.535,-.11),3,actuator,.010)
        for dx in [-.028,0,.028]:
            g.box(tag+'_Finger',(.020,.063,.032),(ax+dx,.525,-.163),5,actuator,.004)
            g.box(tag+'_Knuckle',(.021,.023,.035),(ax+dx,.550,-.167),1,actuator,.004)
        g.box(tag+'_Thumb',(.026,.045,.036),(ax-s*.058,.535,-.14),5,actuator,.005)
        if tag=='R':
            g.box('VB2_stowed_knife_seam',(.012,.17,.017),(ax+.067,.711,-.08),5,plate,.002)
            g.box('VB2_hinge',(.022,.025,.03),(ax+.065,.793,-.08),3,plate,.003)
            linear_rifle(ax,.55,actuator)
    power=component(REGIONS['power'],'power.plant',(0,1,.25))
    g.box('QX_battery_spine',(.15,.42,.13),(0,1.0,.235),3,power,.014)
    for y in [.85,.965,1.08,1.195]:
        g.box('QX_swap_cell',(.165,.09,.07),(0,y,.32),5,power,.009)
        g.box('QX_latch',(.033,.024,.012),(0,y,.364),2,power,.003)
    for s in [-1,1]:
        tube('QX_lifting_handle',[(s*.095,.84,.30),(s*.12,.87,.35),
            (s*.12,1.22,.35),(s*.095,1.25,.30)],.010,2,power)
    service=component(REGIONS['backpack'],'backpack.service',(0,1.02,.19))
    wings=component(REGIONS['backpack'],'backpack.module',(0,1.12,.20))
    for s,tag in [(-1,'L'),(1,'R')]:
        wing=g.group(tag+'_Wing_binder',(s*.18,1.10,.19),wings)
        g.rod(tag+'_Binder_hinge',(s*.10,1.09,.19),(s*.27,1.09,.19),.047,5,service,16)
        g.rod(tag+'_Wing_actuator',(s*.10,.97,.24),(s*.36,1.20,.24),.016,5,service,10)
        g.poly(tag+'_Swept_wing',[(s*.18,1.00),(s*.27,1.27),(s*.95,1.49),
            (s*.84,1.30),(s*.45,1.12),(s*.25,.99)],.185,.228,0,wing,.009)
        g.poly(tag+'_White_wing_underside',[(s*.25,1.04),(s*.38,1.20),(s*.88,1.43),
            (s*.79,1.30),(s*.44,1.14)],.175,.183,1,wing,.003)
        g.poly(tag+'_Orange_wingtip',[(s*.84,1.454),(s*.95,1.49),(s*.89,1.38),
            (s*.80,1.35)],.170,.235,2,wing,.003)
        tube(tag+'_Aileron_seam',[(s*.40,1.15,.17),(s*.60,1.25,.17),(s*.79,1.33,.17)],.003,3,wing)
        for j in range(2):
            x=s*(.43+j*.18); y=1.085+j*.065
            pylon=g.group(tag+'_Hardpoint_%d'%(j+1),(x,y+.07,.22),wing)
            g.box(tag+'_Store_pylon',(.031,.13,.075),(x,y+.06,.23),3,pylon,.004)
            g.rod(tag+'_AGMM_body',(x,y,.36),(x,y,.035),.025,1,pylon,12)
            g.rod(tag+'_AGMM_nose',(x,y,.035),(x,y,-.05),.025,2,pylon,12,end_radius=0)
            g.rod(tag+'_AGMM_motor',(x,y,.36),(x,y,.375),.018,3,pylon,12)
            for axis in [0,1]:
                size=(.083,.006,.065) if axis==0 else (.006,.083,.065)
                g.box(tag+'_AGMM_tail_fin',size,(x,y,.31),1,pylon,.001)
        fasteners(tag+'_Wing_fastener',[(s*.30,1.13,.17),(s*.47,1.24,.17),
            (s*.65,1.32,.17)],wing)
    proportions(root)
    # Authored before AO/export checks; the rig adds only a folding hinge.
    knife=g.group('VB2_Folding_knife',(.333,.651,-.0744),g.groups['Component_right_arm_armour'])
    x,y,z=.333,.651,-.0744
    g.poly('VB2_Folding_blade',[(x-.010,y+.014),(x+.010,y+.014),
        (x+.014,y+.140),(x,y+.205),(x-.013,y+.145)],z-.004,z+.004,5,knife,.0008)
    g.group('Socket_knife_tip',(x,y+.205,z),knife)
    return root

def export_regions():
    dest=g.OUT/'kestrel_regions'; dest.mkdir(exist_ok=True)
    for key,region in REGIONS.items():
        bpy.ops.object.select_all(action='DESELECT'); region.select_set(True)
        for child in region.children_recursive: child.select_set(True)
        bpy.ops.export_scene.gltf(filepath=str(dest/(key+'.glb')),export_format='GLB',
            use_selection=True,export_yup=True,export_colors=True,export_extras=True,
            export_animations=False)

def build():
    from rig_kestrel import prepare
    g.build('hx7_kestrel',kestrel_v2,prepare)
    export_regions()
    head_reviews('after')
    # Open the editable asset in a useful three-quarter review pose.
    scene=bpy.context.scene; cam=scene.camera
    cam.location=g.pt((2.8,2,-4))
    cam.rotation_euler=(g.pt((0,.75,-.10))-cam.location).to_track_quat('-Z','Y').to_euler()
    bpy.ops.object.select_all(action='DESELECT')
    root=bpy.data.objects['hx7_kestrel']; root.select_set(True)
    bpy.context.view_layer.objects.active=root
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type=='VIEW_3D':
                area.spaces.active.region_3d.view_rotation=cam.rotation_euler.to_quaternion()
                area.spaces.active.region_3d.view_distance=2.8
                area.spaces.active.region_3d.view_location=g.pt((0,.75,0))
                area.spaces.active.shading.color_type='MATERIAL'
    bpy.ops.wm.save_as_mainfile(filepath=str(g.ROOT/'art/source/hx7_kestrel.blend'))

if __name__=='__main__': build()
