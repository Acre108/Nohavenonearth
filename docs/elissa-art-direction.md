# Elissa art direction — backpack layout and separate camera views

Updated 30 October 2026. This direction governs new QT-1 Elissa art and supersedes the earlier “cradle above the fuel cells” wording and combined front/rear compositions. It supplements [the frame brief](../Gen3-Prototype-Art-Briefs.md#qt-1-elissa).

## Backpack and medical carrier

The backpack has two distinct assemblies on the same central spine:

- **Upper back:** fixed dark BZ-6 reformer fuel-cell cylinders, behind the shoulder blades.
- **Lower back:** a separate medical carrier tucked directly **under the fuel-cell backpack**, behind the pelvis. It stays centred between the shoulders and hips in rear projection.
- **Four pods:** two columns and two rows. Each pod is small-car-sized; its long axis runs **fore-aft**, parallel to the frame's facing direction. Access doors face **rearward**, toward the loading crew. A rear viewer sees four access ends; a side viewer sees pod length.
- **Attachment:** a structural spine plate supports two short, symmetric guides and locking brackets. The load goes into the chassis, separately from the fuel cells and humanoid arms.
- **Loading:** the carrier lowers down and slightly aft, remaining centred behind the pelvis. The upper fuel cells stay fixed. Leave clearance for the hips, grounded shin and opposite planted foot, and align the lower pod door with a supported loading platform.
- **Stowage:** a loaded carrier retains all four pods tucked beneath the backpack. Only an **empty** carrier may fold flat against the back; label that state explicitly in studies.

Pods do not sit beside the waist or beneath an armpit. There is no long overhead crane, lateral outrigger rack, third humanoid arm or second pod bank.

Rear arrangement, not to scale:

```text
             back of helmet
          [ left ] [ right ]     shoulders
             [ BZ-6 cells ]      fixed upper backpack
             [ BZ-6 cells ]
                spine plate
              [ P1 ][ P2 ]       rear-facing access doors
              [ P3 ][ P4 ]       rack tucked beneath backpack
                 pelvis          rack is aft of it in side view
               /        \
```

## Two separate illustrations

| Deliverable | Camera and subject | Equipment visibility |
|---|---|---|
| Main frame scene | One front view at the Tunis harbour, showing Elissa's face, breastplate, shield and readable half-kneel. | Backpack and pods may be naturally hidden. Do not move them around the waist to display them. |
| “Room for a Medic” key art | One rear view of medical assistance/loading, with upper fuel cells, lower carrier and four pod access ends as the subject. | The chest and visor stay hidden. Shield is mostly edge-on; rifle is stowed clear of loading. |

Front-view sides: Elissa's **left shield is viewer right**, and its **right rifle is viewer left**. Rear-view sides reverse on the page: **left shield is viewer left**, and **right arm is viewer right**.

The front scene contains background evacuation activity, not a foreground cab-boarding or pod-loading demonstration. The rear key art carries the medical story: four pods, three closed and one lower pod open; two medics load one stretcher. The open pod remains one of four.

## Geometry approval before scene generation

First establish a matching true side view and true rear view of the loaded carrier. Check that the rack is below the fuel cells, centred behind the pelvis, with fore-aft pod length and rear-facing doors. Then verify the loading state uses the same attachments and four pods. Use those views as the mechanical references for both illustrations.

Do not use the latest October 30 scene generations as authoritative backpack references: their sideways rack/long-boom arrangements are superseded by this direction. Existing image files and their generation histories remain historical records until replacement artwork is produced.

## Front scene prompt

```text
QT-1 Elissa, 17.8 metre prototype rescue knight mech, ONE full-body FRONT VIEW at eye level, the camera square to the breastplate and both shoulders. Exactly two arms and two legs. Rounded helmet with a dust-shielded T visor and brow floodlight, smooth breastplate and compact tandem pilot/medic cab, rounded knightly armour, finely engineered sealed joints and broad desert feet. Anatomical LEFT arm at VIEWER RIGHT carries one tall curved rescue shield with a white-and-red stripe; one HEAT lance is clipped to its inner face. Anatomical RIGHT hand at VIEWER LEFT holds one QR-30 composite rifle safely lowered. Sand and white armour with slate-blue panels, small date-palm shoulder emblem, painted-over licence stencils and black-and-white prototype calibration marks. A compact BZ-6 fuel-cell backpack is fixed to the upper back; its separate four-pod medical rack is centred directly beneath it behind the pelvis. The rear rack stays hidden naturally by the torso in this FRONT view: do not expose pods beside the waist, rotate the chest away, or add a rear inset. Elissa half-kneels on a Tunis harbour quay at dusk, one knee and shin on the ground and the opposite foot planted; keep shield outboard so the face, breastplate and arm attachments remain readable. Small families and ground medics move toward an evacuation ferry in the background, with smoke and a distant burning inland ridge. No boarding medic on the side door and no pod-loading action in this picture. Grounded real-robot industrial concept painting, cinematic painted environment, worn materials, believable machinery, full frame and shield in a landscape 16:9 composition. No collage, captions, extra arms, floating equipment, oversized people, energy effects, watermark or logo.
```

## Rear medical key-art prompt — “Room for a Medic”

```text
QT-1 Elissa, 17.8 metre rescue knight mech during a daylight medical evacuation drill outside Tunis, ONE full-body REAR VIEW, camera centred behind the spine and looking directly at the rear of the backpack and all four pod access doors. A slight rear offset is allowed only if all four doors remain separate and the chest stays hidden. Show the BACK of the helmet and shoulders, not the visor or breastplate. Fixed dark BZ-6 fuel-cell cylinders occupy the upper back. Directly BELOW them, centred on the SAME SPINE, a compact medical carrier holds exactly FOUR separate small-car-sized stretcher pods in TWO COLUMNS and TWO ROWS. The pods' long axes run FORE-AFT, parallel to the frame's facing direction; their access ends face BACK toward the camera. The rack is tucked under the backpack behind the pelvis, not beside either hip and not hanging from the arms. Two short symmetric guides on a structural spine plate lower the rack down and slightly aft for loading, with visible locks and load-bearing attachments; fixed fuel cells remain above, and leg clearance stays visible. No long crane arms, overhead gantry or sideways swing-out rack. Elissa is half-kneeling with one knee/shin grounded and the opposite foot planted. The lower near pod is open, with two small medics guiding one stretcher into it from a supported truck loading platform; the OTHER THREE pods are closed. The open pod is one of four, never a fifth. White-and-red medical stripes, sand/white/slate-blue knightly armour, sealed joints, date-palm marking and prototype calibration marks. Anatomical LEFT shield remains at VIEWER LEFT in this REAR view, seen mostly edge-on with its clipped lance; rifle is securely stowed and its RIGHT arm stays clear of the loading area. Keep both humanoid arms distinct from carrier guides. Small sheltered families, rescue ambulance, pale Tunis stone buildings, olive trees and warm afternoon light. Humans and doorways remain ordinary human size. Grounded real-robot industrial concept painting, landscape 16:9, no front inset, chest reveal, collage, extra limbs, extra pods, floating equipment, text, watermark or logo.
```

## Technical sheet prompt

```text
QT-1 Elissa, 17.8 metre prototype rescue knight with the established sand/white/slate-blue rounded armour, T visor/dust shield/brow floodlight, tandem pilot-and-medic cab, refined sealed joints and wide desert feet. Exactly two humanoid arms: tall rescue shield and clipped HEAT lance on anatomical LEFT, QR-30 rifle on anatomical RIGHT. Technical design sheet on neutral grey with separate true FRONT, SIDE and REAR views; add three-quarter view only after those agree. Lock backpack geometry across views: fixed dark BZ-6 fuel-cell cylinders on the UPPER BACK; separate four-pod medical carrier directly BELOW them, centred on the spine behind the pelvis. Rear view shows exactly TWO COLUMNS by TWO ROWS of pod access ends. Side view shows each small-car-sized pod's long axis running FORE-AFT, with the entire rack behind the body and clear of hip/knee motion. No lateral rack beside the waist. A structural spine plate and two short symmetric guided supports carry the rack; guides lower it down and slightly aft for loading. Fuel cells stay fixed above. Show matching side/rear transport and loading states with the same four pods and attachment points; show the empty carrier folded close to the back separately, clearly labelled EMPTY. Do not confuse empty folding with disappearing loaded pods. Include tandem cab side cutaway and top plan, pilot in front and medic directly behind, with a human-sized side door and ladder. A 1.8m figure beside the main front foot is 10.1 percent of the 17.8m head-to-floor datum. White/red medical stripes, date-palm shoulder marking and black/white calibration marks. Realistic industrial concept painting, concise labels only, no invented specifications, long crane arms, floating rack, side-mounted pods, extra limbs, duplicate banks or oversized people.
```

## Visual acceptance checks

- True side and rear views agree on one central upper backpack and one lower carrier.
- Four rear-facing access ends form a 2×2 array; side view establishes fore-aft pod length.
- Carrier attaches to the spine, stays clear of legs, and does not become extra humanoid arms.
- Front scene shows the front; rear medical key art shows the rear. Neither twists the torso to reveal both.
- Two humanoid arms, two legs, one shield, one rifle and four pods remain consistent.
- Human doors, stretchers, platforms and crew use the same ordinary human scale.

