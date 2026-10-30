# Demo dock environmental textures — 23 October 2026

Generated with the built-in image_gen tool for the full-colour OVA battlefield. Original prompts are in [prompts.json](prompts.json). These are albedo assets, with muted military-industrial colours and painted weathering.

| Asset | Intended surface | Starting repeat scale |
| --- | --- | --- |
| [dock-concrete-albedo-v1.png](dock-concrete-albedo-v1.png) | Dock floor and deployment aprons | 6–8 world units |
| [cover-concrete-albedo-v1.png](cover-concrete-albedo-v1.png) | Concrete barricades and building walls | 3–4 world units |
| [weathered-steel-albedo-v1.png](weathered-steel-albedo-v1.png) | Cover roofs, steel housings and service panels | 2–3 world units |

Use as sRGB albedo with repeat and mipmaps. Keep material tint near white initially; multiplying by the existing dark paint values will darken these already coloured images substantially. Use world-scale projection to avoid stretching on differently sized cover boxes. Keep floor markings and tactical colours separate.

Retain shader-driven puddles, rain, reflections and lighting. No normal, metallic or roughness maps are supplied; preserve the environment roughness reservation of 0.18–0.88. View the [repeat preview](preview.html) to assess repetition before choosing scale.

The textures are integrated into both the prebuilt standard dock and the procedural fallback. Dock concrete repeats every 7 world units, concrete cover every 3.5 units, and steel roofs every 2.5 units. The environment shader uses dominant-axis world projection with mipmapped, anisotropic repeat sampling; mesh dimensions do not stretch the textures. Existing architectural trim, markings and tactical overlays remain separate.

Overview and close-view renders were inspected. Material checks verified all three dock surfaces in both build paths and concrete/steel bindings on cover. The wet-lighting regression passed at four camera angles with no bright flare pixels. The art suite passed 90 of 91 checks; the remaining failure concerns Kestrel model ground alignment, outside this environment integration.
