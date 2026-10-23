"""Blender 3.2+ template. Run with blender --background --python this_file.py.

Authored in Godot coordinates: metres, +Y up, -Z forward, origin at ground.
The coordinate adapter converts to Blender before glTF's Y-up conversion.
Six fixed material slots, flat bevels, no textures, no gameplay/collision data.
"""
from pathlib import Path
import math
import bpy
import bmesh
from mathutils import Vector

OUTPUT = Path(__file__).resolve().parent
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

PALETTE = [
    ("armour_primary", "bec7c7"),
    ("armour_secondary", "687b8a"),
    ("frame", "263342"),
    ("accent", "e0e2d5"),
    ("sensor", "344959"),
    ("weapon", "3e4a58"),
]

def linear(value):
    return value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4

materials = []
for name, rgb in PALETTE:
    material = bpy.data.materials.new(name)
    material.diffuse_color = tuple(linear(int(rgb[i:i+2], 16) / 255) for i in (0, 2, 4)) + (1,)
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = material.diffuse_color
    bsdf.inputs["Roughness"].default_value = 1
    materials.append(material)

def point(coordinates):
    x, y, z = coordinates
    return (x, -z, y)

parts = []

def mesh_part(name, vertices, faces, slot, bevel=0):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([point(v) for v in vertices], [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    for material in materials:
        mesh.materials.append(material)
    for polygon in mesh.polygons:
        polygon.material_index = slot
    if bevel:
        bm = bmesh.new()
        bm.from_mesh(mesh)
        bmesh.ops.bevel(bm, geom=list(bm.edges), offset=bevel, segments=1, affect="EDGES")
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        bm.to_mesh(mesh)
        bm.free()
    else:
        bm = bmesh.new()
        bm.from_mesh(mesh)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        bm.to_mesh(mesh)
        bm.free()
    parts.append(obj)
    return obj

def plate(name, size, center, slot=0, bevel=0.015):
    x, y, z = [v / 2 for v in size]
    cx, cy, cz = center
    vertices = [(cx+a*x, cy+b*y, cz+c*z) for a, b, c in
                [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
    return mesh_part(name, vertices, [(0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)], slot, bevel)

def profile(name, xy, z_front, z_back, slot=0, bevel=0.008):
    count = len(xy)
    vertices = [(x, y, z) for z in (z_front, z_back) for x, y in xy]
    faces = [tuple(range(count-1, -1, -1)), tuple(range(count, count*2))]
    faces += [(i, (i+1) % count, (i+1) % count + count, i+count) for i in range(count)]
    return mesh_part(name, vertices, faces, slot, bevel)

for side, tag in [(-1, "L"), (1, "R")]:
    x = side * 0.19
    plate(tag + "_Foot", (0.25, 0.14, 0.43), (x, 0.07, -0.12), 0, 0.025)
    plate(tag + "_Sole", (0.25, 0.04, 0.4), (x, 0.025, -0.12), 2, 0.008)
    plate(tag + "_Shin", (0.22, 0.34, 0.25), (x, 0.31, 0.005), 0, 0.028)
    plate(tag + "_Knee", (0.19, 0.12, 0.12), (x, 0.47, -0.12), 1, 0.018)
    plate(tag + "_Thigh", (0.17, 0.2, 0.18), (x, 0.55, 0.025), 2)
    plate(tag + "_ShinStripe", (0.08, 0.15, 0.014), (x, 0.30, -0.126), 3, 0)
    plate(tag + "_Shoulder", (0.30, 0.24, 0.36), (side*0.41, 0.98, 0), 0, 0.035)
    plate(tag + "_UpperArm", (0.17, 0.23, 0.21), (side*0.42, 0.79, 0), 2)
    plate(tag + "_Forearm", (0.20, 0.25, 0.24), (side*0.44, 0.63, -0.06), 0, 0.02)
    plate(tag + "_Hand", (0.16, 0.13, 0.17), (side*0.44, 0.47, -0.08), 2)
    # Angular flight stabilisers give this line frame its own black silhouette.
    profile(tag + "_FlightFin", [(side*0.23,0.72),(side*0.31,1.20),(side*0.62,1.42),(side*0.50,0.78)], 0.27, 0.37, 1)
    profile(tag + "_HipSkirt", [(x-0.12,0.68),(x+0.12,0.68),(x+0.14,0.47),(x-0.14,0.47)], -0.20, -0.13, 0)
    plate(tag + "_Thruster", (0.16, 0.29, 0.20), (side*0.19, 0.81, 0.36), 5)
    plate(tag + "_Exhaust", (0.12, 0.05, 0.14), (side*0.19, 0.65, 0.37), 2, 0)

plate("Pelvis", (0.42, 0.18, 0.30), (0, 0.64, 0), 1, 0.02)
plate("Waist", (0.27, 0.12, 0.24), (0, 0.77, 0), 2)
profile("Chest", [(-0.29,0.87),(-0.24,1.10),(0.24,1.10),(0.29,0.87),(0.15,0.80),(-0.15,0.80)], -0.20, 0.18, 0, 0.025)
plate("ChestInset", (0.31, 0.12, 0.025), (0, 1.02, -0.218), 1, 0.008)
for x in [-0.105, -0.035, 0.035, 0.105]:
    plate("ChestLouvre", (0.035, 0.07, 0.01), (x, 1.02, -0.238), 2, 0)
plate("Collar", (0.29, 0.06, 0.25), (0, 1.12, 0), 2)
plate("Helmet", (0.24, 0.24, 0.25), (0, 1.24, -0.015), 0, 0.038)
plate("Visor", (0.18, 0.052, 0.025), (0, 1.26, -0.15), 4, 0.008)
plate("Chin", (0.07, 0.08, 0.04), (0, 1.16, -0.155), 1, 0.008)
for side, tag in [(-1,"L"),(1,"R")]:
    profile(tag + "_Crest", [(side*0.025,1.31),(side*0.24,1.46),(side*0.17,1.29)], -0.135, -0.10, 3, 0)
plate("Backpack", (0.31, 0.33, 0.22), (0, 0.97, 0.27), 2, 0.02)
plate("ShoulderID", (0.15, 0.018, 0.25), (-0.41, 1.108, 0), 3, 0)
plate("RifleReceiver", (0.15, 0.18, 0.38), (0.45, 0.61, -0.25), 2)
plate("RifleBarrel", (0.075, 0.08, 0.49), (0.45, 0.64, -0.67), 2, 0.006)
plate("RifleMuzzle", (0.12, 0.13, 0.10), (0.45, 0.64, -0.92), 1, 0.01)
profile("Shield", [(-0.65,0.95),(-0.37,0.95),(-0.35,0.51),(-0.50,0.38),(-0.67,0.51)], -0.24, -0.14, 1, 0.018)
plate("ShieldStripe", (0.055, 0.36, 0.015), (-0.51, 0.73, -0.252), 3, 0)

root = bpy.data.objects.new("BlueLineMech__Y_UP_NEG_Z_FORWARD", None)
bpy.context.collection.objects.link(root)
root["forward_godot"] = "-Z"
root["units"] = "metres"
root["origin"] = "ground centre between feet"
for obj in parts:
    obj.parent = root
bpy.ops.object.select_all(action="DESELECT")
root.select_set(True)
for obj in parts:
    obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "blue_line.glb"), export_format="GLB", use_selection=True, export_yup=True)

import json
checks_dir = OUTPUT.parents[1] / "artifacts"
checks_dir.mkdir(parents=True, exist_ok=True)
triangles = sum(len(face.vertices) - 2 for obj in parts for face in obj.data.polygons)
checks = {"triangles": triangles, "materials": [name for name, _ in PALETTE],
          "origin": list(root.location), "godot_forward": "-Z", "blender_forward": "+Y",
          "height_metres": max(vertex.co.z for obj in parts for vertex in obj.data.vertices),
          "rigid_parts": len(parts), "textures": 0}
(checks_dir / "blue-line-model-checks.json").write_text(json.dumps(checks, indent=2))
assert triangles <= 8000, "Mech exceeds the 8k triangle budget"
assert len(PALETTE) == 6 and root.location.length == 0

# The editable source contains only the model, with the same six-slot contract.
source_dir = OUTPUT.parent / "source"
source_dir.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(source_dir / "blue_line.blend"))

# Automated black silhouette renders, including the game's default camera angle.
black = bpy.data.materials.new("QA_Silhouette")
black.diffuse_color = (0, 0, 0, 1)
for obj in parts:
    for i in range(len(obj.data.materials)):
        obj.data.materials[i] = black
scene = bpy.context.scene
scene.render.engine = "BLENDER_WORKBENCH"
scene.display.shading.light = "FLAT"
scene.display.shading.color_type = "MATERIAL"
scene.display.shading.show_shadows = False
scene.display.shading.show_cavity = False
scene.display.shading.show_specular_highlight = False
scene.display.shading.background_type = "WORLD"
scene.world.color = (0.65, 0.68, 0.71)
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.resolution_percentage = 100
camera_data = bpy.data.cameras.new("QA_Camera")
camera = bpy.data.objects.new("QA_Camera", camera_data)
bpy.context.collection.objects.link(camera)
scene.camera = camera
camera_data.type = "ORTHO"
camera_data.ortho_scale = 2.1
qa_dir = OUTPUT.parents[1] / "artifacts" / "blue-line-silhouettes"
qa_dir.mkdir(parents=True, exist_ok=True)
for name, location in [("default", (0,6,7)), ("deployed", (0,6,7)), ("front", (0,0.8,-7)), ("side", (7,0.8,0)), ("back", (0,0.8,7)), ("top", (0,7,0.001))]:
    root.rotation_euler.z = -math.pi / 2 if name == "deployed" else 0
    camera.location = point(location)
    direction = Vector(point((0,0.75,0))) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = str(qa_dir / (name + ".png"))
    bpy.ops.render.render(write_still=True)
print("BLUE LINE / exported GLB, editable BLEND, six silhouette views /", triangles, "triangles")
