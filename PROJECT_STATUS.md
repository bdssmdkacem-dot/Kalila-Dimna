# PROJECT STATUS — Kalila-Dimna

Last updated: 2026-10-09 (UTC)
Default branch: `main`
Latest test adjustment: `7a590127efd4571910c8026ab40c27595a563954`
Latest status record: updated by this commit's follow-up status commit.

## Current state

- Last green baseline: [CI run 37852473690](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37852473690), including Android Debug APK export.
- Expanded runtime test on commit `102eb382926bf2dc559b72143fb5a47e876b485b` failed because `godot -s` does not register project autoload identifiers when it compiles the story scene script: `Identifier not found: GameState`. This was a test-harness limitation; it was not proof that the app runtime itself fails to start.
- The test has been adjusted to validate scene resource loading and static startup safeguards without instantiating a scene in a runner that lacks project autoload context.
- CI for the latest test adjustment is queued/running and must be checked before declaring green.

## Latest changes

- Removed the static GLB external-resource dependency from `scenes/scene01_3d.tscn`; the scene now uses a safe `KalilaDimnaGLB` placeholder and runtime loading.
- Added explicit missing/load/instantiate failure handling and an Arabic recovery panel with a return-to-map action.
- Added `tests/validate_scene01_boot.gd` and wired it into the Godot CI workflow.
- Expanded background crossfades, doubt/sadness/reconciliation motion, and the final friendship camera shot.

## Root-cause notes: black screen

The confirmed design risk was a static GLB dependency in the scene resource table: a broken imported asset could prevent the script-level recovery UI from running. Runtime loading removes that dependency from scene parsing and provides explicit fallback UI for missing assets or invalid visible geometry.

CI import logs also report a missing external texture path, `res://assets/3d/animals/Textures/colormap.png`, referenced by one or more animal imports. The geometry assets are present and existing asset validation passes, but this texture warning should be investigated separately because it may affect model appearance. Do not assume it is the sole cause of the Scene01 black screen.

## CI evidence

- Latest test adjustment: [run 37965505081](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37965505081) — queued at last check.
- Prior failed expanded test: [run 37852498943](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37852498943).
- Last green APK build: [run 37852473690](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37852473690).

## Next steps

1. Confirm the newest CI result and repair any failure before further visual changes.
2. Investigate the missing `colormap.png` references and either restore the correct licensed texture or re-export affected models with embedded textures; do not fabricate a substitute without checking source/provenance.
3. Export and test on a real Android device: cold start, map → lion/bull story, return to map, and story completion. CI cannot prove device GPU/driver behavior.
4. Review actor bounds/animation names and confirm crossfades/finale work on-device.

## Working rules

- Commit meaningful changes and update this file at each significant milestone.
- Record exact CI status; never label a build successful without workflow evidence or user confirmation.
- Preserve the last green commit while resolving startup/runtime failures.
