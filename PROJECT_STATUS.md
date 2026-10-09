# PROJECT STATUS — Kalila-Dimna

Last updated: 2026-10-09 (UTC)
Default branch: `main`
Latest fix commit: `bb3691825ab57c6a9cd9c0f9b2d2a58672a9bd47`

## Current state

- The prior baseline CI passed on commit `f4f7fd10fb4b4a0cd3ece9ab97d660ce610ddb9b`, including the Android Debug APK export.
- The expanded Scene01 boot test failed on commit `102eb382926bf2dc559b72143fb5a47e876b485b`; its failure was isolated to the new test step, and the APK job was skipped because validation failed.
- A follow-up fix now waits one process frame before accessing autoloads in the SceneTree test runner, avoiding a race where `GameState` may not yet be attached during `_init()`.
- CI for the follow-up fix must be checked before treating it as green.

## Latest changes

- Decoupled `scenes/scene01_3d.tscn` from a static GLB external resource. The scene has a safe `KalilaDimnaGLB` placeholder and loads `assets/3d/kalila_dimna_scene01_v2.glb` at runtime.
- Added explicit checks for missing, unloadable, or non-instantiable GLB resources, with a visible Arabic recovery panel instead of leaving the user on an empty screen.
- Added `tests/validate_scene01_boot.gd` and wired it into `.github/workflows/android.yml`.
- Expanded the boot test to instantiate the scene and check GLB attachment and camera startup.
- Added two-layer background crossfades, more expressive doubt/sadness/reconciliation acting, and a final friendship camera shot.

## Root-cause notes: black screen

The main startup risk found was a static GLB dependency inside `scene01_3d.tscn`. If the imported asset failed before the scene script ran, script-level recovery could not appear. Runtime loading removes that hard dependency from scene parsing. The startup guard now provides a visible recovery message and a return-to-map action for GLB and visible-geometry failures.

## CI evidence

- Latest failed expanded test: [run 37852498943](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37852498943).
- Last green baseline including Android Debug APK: [run 37852473690](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37852473690).
- New follow-up fix: `bb3691825ab57c6a9cd9c0f9b2d2a58672a9bd47`; CI status must be confirmed.

## Next steps

1. Confirm CI on the latest commit, fix any remaining failure, and do not claim success until the workflow is green.
2. Test the exported APK on a real Android device through cold start, map → story, back-to-map, and story completion; CI cannot prove device GPU/driver behavior.
3. Review actor bounds and animation names on-device, and verify the finale triggers once and the background crossfade stays behind 3D actors.
4. Keep this file current with every significant milestone.

## Working rules

- Commit meaningful changes to this repository and update this file with each significant milestone.
- Record exact CI status; never label a build successful without workflow evidence or user confirmation.
- Preserve the last green commit and avoid unrelated changes while fixing startup/runtime failures.
