# Story 3D environments

The story stage uses dedicated 3D environment sets per story. The environment is built from
Godot 3D mesh primitives so it is deterministic, lightweight, and embedded in the APK with
the game scene.

## Story mapping

- `lion_bull`: meadow, trees, rocks, flowers
- `crow_snake`: darker forest, rocks, bushes
- `monkey_turtle`: river, trees, reeds, river stones
- `dove_ring`: garden, trees, bushes, flowers, perch
- `lion_hare`: meadow variant with denser trees and rocks

These are runtime 3D elements behind the real imported animal models; they are not 2D
background images or silent placeholders.

## Visual consistency sources

The runtime environment is intentionally kept lightweight and deterministic. For future replacement of procedural props with authored GLB assets, the visual baseline is:

- Gobkit Free 3D Assets — CC0 low-poly GLB characters and a nature kit. https://github.com/Ariescar/gobkit-free-assets
- CC0 Public Domain Models — curated CC0 self-contained GLB collection. https://github.com/Papyszoo/CC0-Public-Domain-Models
- CC0Tree — CC0 low-poly environment/world-building assets. https://github.com/SkywolfGameStudios/CC0Tree
- Shapespark assets — CC0 optimized real-time environment assets. https://github.com/shapespark/shapespark-assets

The game currently does not blindly mix packs. Animals and environments are normalized by scale, lighting, camera framing, and palette so that the story remains visually coherent on Android.

## Story visual language

- lion_bull: warm green meadow, soft golden daylight, broad trees, flowers and rocks.
- crow_snake: darker cool forest, restrained ambient light, dense bushes and rocks.
- monkey_turtle: fresh river palette, blue-green water, reeds, river stones and forest edges.
- dove_ring: bright garden palette, bushes, flowers and a wooden perch.
- lion_hare: warmer meadow variant with denser trees and rocks.

All five stories share the same camera family, actor framing, ground treatment and cinematic fade, while their environment palette changes to support the narrative.
