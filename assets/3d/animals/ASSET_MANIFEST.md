# 3D animal asset manifest

The shipped story stage now contains eight real Godot-imported animal assets. AnimalStage checks these files first and instantiates the imported scene. Procedural geometry is only a non-release development fallback; Release builds never silently substitute it.

## Required shipped assets

| File | Story animal | Source / author | License |
|---|---|---|---|
| `lion.glb` | Lion | Kenney Cube Pets | CC0 1.0 |
| `bull.glb` | Bull | Quaternius Ultimate Animated Animals | CC0 1.0 |
| `crow.glb` | Crow / raven | Teh_Bucket, OpenGameArt | CC0 1.0 |
| `snake.glb` | Snake | Quaternius Easy Enemies | CC0 1.0 |
| `monkey.glb` | Monkey / Monkroose | Kenney Cube Pets | CC0 1.0 |
| `turtle.glb` | Turtle | Serenity Blocks self-generated asset pipeline | MIT-project-local — attribution retained |
| `dove.gltf` | Dove / pigeon | Quaternius | CC0 1.0 |
| `hare.glb` | Hare / bunny | Quaternius Ultimate Monsters | CC0 1.0 |

The turtle is the only non-CC0 asset in this set; its provenance is retained because it comes from a third-party project-local asset pipeline distributed under that project's MIT terms.

## Runtime contract

The runtime checks:

- `res://assets/3d/animals/<id>.glb`
- `res://assets/3d/animals/<id>.gltf`

for every required animal. CI runs `tests/validate_animal_assets.gd` and fails if any required model is missing or cannot be loaded.

## APK contract

The Android workflow also checks the exported APK for the eight model paths after export. This prevents a successful APK build from silently omitting the story animal resources.

## Naming

Keep the lowercase story-neutral filenames exactly as listed above.
