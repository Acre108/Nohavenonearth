"""Editable assembled examples for the modular parts and control rig.
Run after build_teamster.py and build_teamster_parts.py. Does not alter the stock source.
"""
from pathlib import Path
import json
import bpy
from mathutils import Matrix
ROOT=Path(__file__).resolve().parents[2]
FIT={'head.sensor':'sensor_precision','torso.structure':'structure_braced','torso.armour':'torso_heavy',
    'left_arm.actuator':'arm_support','right_arm.actuator':'arm_marksman','left_arm.armour':'arm_reinforced','right_arm.armour':'arm_reinforced',
    'left_leg.drive':'leg_fast','right_leg.drive':'leg_fast','left_leg.armour':'leg_braced','right_leg.armour':'leg_braced',
    'power.plant':'power_buffered','backpack.service':'service_upgraded','backpack.module':'module_recovery'}

def asset_name(part,slot):
    if part in ['arm_precision','arm_reinforced','leg_fast','leg_braced']:
        return part+('_left' if slot.startswith('left_') else '_right')
    return {'arm_support':'arm_support_left','arm_marksman':'arm_marksman_right',
        'arm_cannon':'arm_cannon_right','arm_breacher':'arm_breacher_left'}.get(part,part)

def hide(obj):
    for item in [obj]+list(obj.children_recursive):
        item.hide_render=True
        item.hide_set(True)

for label in ['marksman','assault']:
    bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/source/m9_teamster.blend'))
    rig=bpy.data.objects['Teamster_Control_Rig']
    rig.animation_data.action=None
    for bone in rig.pose.bones: bone.matrix_basis=Matrix.Identity(4)
    bpy.context.scene.frame_set(0)
    bpy.context.view_layer.update()
    fit=dict(FIT)
    if label=='assault': fit.update({'left_arm.actuator':'arm_breacher','right_arm.actuator':'arm_cannon'})
    for obj in list(bpy.data.objects):
        if obj.name.startswith(('AR40_','Rifle_','Optic_','PB4_','Hornet_')): hide(obj)
    for slot,part in fit.items():
        before=set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=str(ROOT/'art/models/teamster_parts'/(asset_name(part,slot)+'.glb')))
        imported=set(bpy.data.objects)-before
        component=bpy.data.objects['Component_'+slot.replace('.','_')]
        for mount in [obj for obj in imported if obj.name.startswith('Mount_')]:
            kind=mount.name.split('_')[1].split('.')[0].lower()
            target=component
            if kind!='upper':
                side=slot.split('_')[0]; suffix=slot.split('.')[1]
                target=bpy.data.objects.get('Joint_'+side+'_'+kind+'_'+suffix,component)
            mount.parent=target
            mount.matrix_world=Matrix.Identity(4)
            mount.name='Variant_'+part+'_'+kind
        for obj in list(imported):
            if obj.parent is None and not obj.children: bpy.data.objects.remove(obj,do_unlink=True)
    rig.animation_data.action=bpy.data.actions['Controls_twohand_idle' if label=='marksman' else 'Controls_idle']
    bpy.context.scene.frame_set(0)
    bpy.context.view_layer.update()
    bpy.context.scene['refit_recipe']=json.dumps(fit)
    bpy.context.scene['note']='Assembled workshop example. Stock build and standalone variant source are separate files.'
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/('art/source/m9_teamster_'+label+'.blend')))
    print('REFIT_SOURCE_COMPLETE',label,flush=True)
