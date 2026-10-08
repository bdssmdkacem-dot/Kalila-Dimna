# PROJECT STATUS — Kalila-Dimna

Last updated: 2026-10-08 (UTC)
Default branch: `main`
Current verified commit: `9a33d2abb9c9788bf86fc53e42f66951cc666d2d`

## Current state

- The latest GitHub Actions workflow for the current commit completed successfully.
- Both `Validate stories` and `Android Debug APK` jobs passed.
- The Scene01 boot-safety regression test passed.
- The Android Debug APK was exported and required embedded resources were verified by CI.

## Latest changes

- Decoupled `scenes/scene01_3d.tscn` from a static GLB external resource. The scene now has a safe `KalilaDimnaGLB` placeholder and loads `assets/3d/kalila_dimna_scene01_v2.glb` at runtime.
- Added explicit checks for missing, unloadable, or non-instantiable GLB resources, with a visible Arabic recovery panel instead of leaving the user on an empty screen.
- Added `tests/validate_scene01_boot.gd` and wired it into `.github/workflows/android.yml`.
- Added two-layer background crossfades, more expressive doubt/sadness/reconciliation acting, and a final friendship camera shot.
- Updated the final dialogue presentation to label the last beat as the moral/wisdom.

## Root-cause notes: black screen

The key startup risk found was the 3D GLB being declared as an external resource in `scene01_3d.tscn`. If that imported asset failed before the scene script ran, script-level recovery could not appear. Runtime loading removes that hard dependency from scene parsing. The startup guard now shows a recovery message and a return-to-map action for GLB and visible-geometry failures.

## Current CI evidence

- Workflow: [Godot CI](https://github.com/bdssmdkacem-dot/Kalila-Dimna/actions/runs/37850685857)
- Result: success
- Verified commit: `9a33d2abb9c9788bf86fc53e42f66951cc666d2d`

## Remaining work / next step

1. Test the exported APK on a real Android device through cold start, map → story, back-to-map, and story completion; CI cannot prove device GPU/driver behavior.
2. Strengthen the regression test to instantiate the story scene with a controlled GameState story and verify the GLB child, camera, and recovery path—not only static resource presence.
3. Review scene actor bounds and animation names on-device; ensure the finale triggers once and background crossfade remains behind the 3D actors on Android.
4. Continue visual polish only after boot and navigation remain stable.

## Working rules

- Commit meaningful changes to this repository and update this file with each significant milestone.
- Record exact CI status; never label a build successful without workflow evidence or user confirmation.
- Preserve the last green commit and avoid unrelated changes while fixing startup/runtime failures.
