# 3D animal asset manifest

The story stage supports real Godot-imported `.glb` or `.gltf` files in this directory. If a model is missing, the game intentionally falls back to its built-in low-poly procedural animal so story playback and tests remain functional.

## Preferred licensing

Use CC0 / public-domain assets only for shipped models.

## Verified sources

- Quaternius Ultimate Animated Animals: CC0, animated, glTF/FBX/OBJ/Blend. The pack includes Bull and other animals, but not every animal required by Kalila & Dimna.
- Quaternius Bunny: CC0, animated, GLTF/FBX.
- Quaternius Snake: CC0, animated, GLTF/FBX.
- Quaternius Monkroose: CC0, animated, GLTF/FBX.

Source pages are recorded in the project documentation before any binary asset is committed.

## Naming convention

Use lowercase story-neutral filenames:

- `lion.glb`
- `bull.glb`
- `crow.glb`
- `snake.glb`
- `monkey.glb`
- `turtle.glb`
- `dove.glb`
- `hare.glb`

The runtime checks both `.glb` and `.gltf`.
