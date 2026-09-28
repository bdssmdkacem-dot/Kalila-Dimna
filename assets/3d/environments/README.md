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
