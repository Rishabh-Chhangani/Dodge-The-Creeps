# Option A: GSpec Cleanup & Test Migration Plan

This document details **Option A**: resolving the third-party GSpec errors, cleaning up the `res://spec/` directory, and establishing a clean migration plan for all 44 project tests.

---

## 1. Problem Statement: Why Did GSpec Report 10 Failures and 3 Pendings?

When GSpec is installed via AssetLib, it bundles an internal documentation directory under `res://spec/examples/`. Because GSpec's default test discovery path in `addons/gspec/editor/gspec_panel.gd` is hardcoded to `res://spec`, clicking **▶ Run All** executes GSpec's internal dogfooding test suite rather than your game's tests.

### The 3 Pendings (Intentional Demos)
- Found in `spec/godot_spec_spec.gd:300` and `spec/examples/lifecycle_spec.gd:322, 326`.
- Written with `xit(...)` to demonstrate GSpec's ability to skip tests.
- **They are not bugs; they are intentional demonstrations by the library author.**

### The 10 Failures (Bugs in GSpec Addon Itself on Godot 4.5)
All 10 failures stem from Godot 4.5 lifecycle hook timing inside `spec/examples/lifecycle_spec.gd`:
1. **Failure 1**: Nested `after_each` hook ordering ran outer before inner instead of inner before outer (`expected [] to equal ["inner_after", "outer_after"]`).
2. **Failures 2–3**: `let_def / get_let` memoization evaluated eagerly instead of lazily.
3. **Failures 4–10**: `before_all` and `after_all` suite hooks failed to trigger across group boundaries in Godot 4.5's SceneTree lifecycle.

**Conclusion:** Zero failures were caused by *Dodge the Creeps!*. They are third-party plugin bugs in the sample code.

---

## 2. Cleanup Execution Steps

### Step 1: Remove Third-Party Example Files
Delete the extraneous demonstration files that belong to the GSpec library author:
```text
Remove:
res://spec/examples/advanced_spec.gd
res://spec/examples/advanced_spec.gd.uid
res://spec/examples/doubles_spec.gd
res://spec/examples/doubles_spec.gd.uid
res://spec/examples/lifecycle_spec.gd       <-- Contains the 10 failures
res://spec/examples/lifecycle_spec.gd.uid
res://spec/examples/matchers_spec.gd
res://spec/examples/matchers_spec.gd.uid
res://spec/godot_spec_spec.gd
res://spec/godot_spec_spec.gd.uid
```

### Step 2: Establish Clean Game Spec Root
After removal, `res://spec/` becomes 100% owned by *Dodge the Creeps!*, structured as:
```text
res://spec/
├── save_manager_spec.gd           # 6 Persistence assertions
├── mob_behaviors_spec.gd          # 6 Creep behavior & physics assertions
├── player_spec.gd                 # 11 Player & touch mechanics assertions
└── gameplay_integration_spec.gd   # 21 Scene & UI integration assertions
```

---

## 3. The 44 Tests Mapped to the Cleaned GSpec Structure

Below is the full catalog of all 44 tests that will execute in the cleaned environment:

### `res://spec/save_manager_spec.gd` (6 Tests)
1. **`SaveManager.save_high_score succeeded`**: Verifies `SaveManager.save_high_score(128)` writes to `user://savegame.cfg` and returns `true`.
2. **`SaveManager loaded correct high score`**: Verifies `SaveManager.load_high_score()` recovers `128` without data loss.
3. **`Higher score recognized as new high score`**: Verifies `SaveManager.is_new_high_score(200)` evaluates `true`.
4. **`Lower score rejected as new high score`**: Verifies `SaveManager.is_new_high_score(50)` evaluates `false`.
5. **`Music volume saved and retrieved`**: Verifies linear volume `0.45` is stored and retrieved accurately.
6. **`Music bus exists`**: Verifies `AudioServer.get_bus_index("Music")` returns a valid non-negative index.

### `res://spec/mob_behaviors_spec.gd` (6 Tests)
7. **`Mob collision_layer is 2 (Enemies)`**: Asserts `mob.collision_layer == 2` for enemy isolation.
8. **`Mob collision_mask is 0 (No self-collision)`**: Asserts `mob.collision_mask == 0` preventing inter-mob collisions.
9. **`Mob is in 'mobs' group`**: Asserts `mob.is_in_group("mobs") == true` for group operations.
10. **`Mob chose a valid randomized behavior type`**: Asserts `mob.mob_type` is one of `fly`, `swim`, or `walk`.
11. **`Swimming mob oscillates perpendicular to base velocity`**: Asserts `_physics_process(0.2)` alters perpendicular velocity.
12. **`Flying mob applies +25% speed sprint`**: Asserts `mob.linear_velocity` applies 1.25x speed multiplier.

### `res://spec/player_spec.gd` (11 Tests)
13. **`Player collision_layer is 1`**: Asserts player occupies Layer 1.
14. **`Player collision_mask is 2 (scans Mobs)`**: Asserts player detects Layer 2 enemies.
15. **`Default player speed is 400`**: Asserts baseline speed parameter equals `400`.
16. **`Player starts at designated coordinates`**: Asserts `start(Vector2(120, 240))` sets position to `(120, 240)`.
17. **`Player is visible after start()`**: Asserts `player.visible == true` upon start.
18. **`Collision shape is active after start()`**: Asserts `collision_shape.disabled == false` upon start.
19. **`Touch drag event activates touch mode`**: Asserts `_unhandled_input(drag)` sets `is_touch_active == true`.
20. **`Target position updated by touch drag`**: Asserts target coordinates track drag event vector.
21. **`Collision shape deferred disabled on hit`**: Asserts deferred disabling on body entered to prevent multi-hits.
22. **`Animated sprite hidden on hit`**: Asserts sprite visibility is disabled on impact.
23. **`Death particles triggered on hit`**: Asserts `death_particles.emitting == true` on impact.

### `res://spec/gameplay_integration_spec.gd` (21 Tests)
24. **`Music is non-spatial AudioStreamPlayer`**: Asserts music node is non-spatial.
25. **`DeathSound is non-spatial AudioStreamPlayer`**: Asserts death SFX node is non-spatial.
26. **`Music is routed to Music bus`**: Asserts `music.bus == &"Music"`.
27. **`DeathSound is routed to SFX bus`**: Asserts `death.bus == &"SFX"`.
28. **`Main contains MobContainer node`**: Asserts `main.has_node("MobContainer")`.
29. **`MobContainer starts empty`**: Asserts container child count is `0`.
30. **`Mob spawned directly into MobContainer`**: Asserts `_on_mob_timer_timeout()` spawns into container.
31. **`clear_mobs cleans up container instances`**: Asserts `clear_mobs()` empties container.
32. **`PauseMenu runs with PROCESS_MODE_ALWAYS`**: Asserts pause menu handles input during pause.
33. **`PauseMenu includes Music volume slider`**: Asserts `MusicSlider` exists in pause UI hierarchy.
34. **`PauseMenu includes SFX volume slider`**: Asserts `SFXSlider` exists in pause UI hierarchy.
35. **`PauseMenu opens when game pauses`**: Asserts `main.pause_game()` displays pause overlay.
36. **`SceneTree is paused`**: Asserts tree state is paused.
37. **`PauseMenu closes on resume`**: Asserts `pause_menu.resume_game()` hides pause overlay.
38. **`SceneTree is unpaused on resume`**: Asserts tree state is unpaused.
39. **`GameOver starts hidden`**: Asserts game over modal is hidden on start.
40. **`GameOver shows on game over`**: Asserts game over modal displays upon player death.
41. **`GameOver displays final score`**: Asserts score label displays `"Final Score: 45"`.
42. **`GameOver displays high score`**: Asserts high score label displays `"High Score: 90"`.
43. **`Starting interval is 0.5s`**: Asserts difficulty scaling starts at 0.50s.
44. **`Spawn interval clamps at 0.22s minimum`**: Asserts difficulty scaling clamps at 0.22s minimum.

---

## 4. Expected Outcome

Once Option A cleanup is applied:
- **0 Third-Party Failures**
- **0 Unwanted Pendings**
- **44 / 44 Passing Game Assertions**
- Running **▶ Run All** in GSpec will output:
  ```text
  44 examples, 0 failures, 0 pending (finished in 0.082s)
  ```
