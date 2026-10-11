# Option C: Standalone In-Engine Visual GUI Test Runner Scene

This document details **Option C**: building an interactive, graphical test dashboard (`tests/test_runner_gui.tscn`) that runs directly as a Godot scene with <kbd>F6</kbd>, with **zero plugin dependencies**.

---

## 1. Visual UI Dashboard Design

When you open `tests/test_runner_gui.tscn` and press <kbd>F6</kbd>, a standalone test dashboard window opens:

```text
┌────────────────────────────────────────────────────────────────────────┐
│  👾 DODGE THE CREEPS — VISUAL TEST RUNNER                              │
├────────────────────────────────────────────────────────────────────────┤
│  [▶ Run All Tests]    [⟲ Clear]      Status: 44 PASSED (100%) [0 FAILS]│
│                                                                        │
│  Progress: [██████████████████████████████████████████████████] 100%   │
├────────────────────────────────────────────────────────────────────────┤
│  Status  │ Suite                   │ Test Assertion Name     │ Time   │
├──────────┼─────────────────────────┼─────────────────────────┼────────┤
│  ✔ PASS  │ SaveManager             │ High score save file    │ 0.4 ms │
│  ✔ PASS  │ SaveManager             │ High score load data    │ 0.1 ms │
│  ✔ PASS  │ SaveManager             │ Detect higher score     │ 0.0 ms │
│  ✔ PASS  │ SaveManager             │ Reject lower score      │ 0.0 ms │
│  ✔ PASS  │ SaveManager             │ Persist Music volume    │ 0.2 ms │
│  ✔ PASS  │ SaveManager             │ Verify Music bus exists │ 0.1 ms │
│  ✔ PASS  │ Mob Behaviors           │ Collision layer = 2     │ 0.1 ms │
│  ✔ PASS  │ Mob Behaviors           │ Collision mask = 0      │ 0.1 ms │
│  ✔ PASS  │ Mob Behaviors           │ 'mobs' group registered │ 0.1 ms │
│  ✔ PASS  │ Mob Behaviors           │ Valid random type       │ 0.1 ms │
│  ✔ PASS  │ Mob Behaviors           │ Swim wave oscillation   │ 0.8 ms │
│  ✔ PASS  │ Mob Behaviors           │ Fly sprint speed burst  │ 0.1 ms │
│  ✔ PASS  │ Player Mechanics        │ Layer 1 / Mask 2        │ 0.2 ms │
│  ✔ PASS  │ Player Mechanics        │ Touch drag tracking     │ 0.3 ms │
│  ✔ PASS  │ Player Mechanics        │ Deferred disable on hit │ 1.1 ms │
│  ✔ PASS  │ Gameplay Integration    │ MobContainer node pool  │ 0.2 ms │
│  ✔ PASS  │ Gameplay Integration    │ Audio bus routing       │ 0.2 ms │
│  ✔ PASS  │ Gameplay Integration    │ Pause / resume flow     │ 0.4 ms │
│  ✔ PASS  │ Gameplay Integration    │ Dynamic scaling formula │ 0.1 ms │
│  ... (44 total rows)                                                   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Technical Architecture of `test_runner_gui.tscn`

### Scene Tree Node Hierarchy

```text
TestRunnerGUI (Control, Anchor: Full Rect)
├── Background (ColorRect, Color: #1a1a24)
└── MainLayout (VBoxContainer)
    ├── HeaderBar (PanelContainer)
    │   └── HBoxContainer
    │       ├── TitleIcon (TextureRect / Label)
    │       ├── TitleLabel ("Dodge the Creeps — Automated Test Suite")
    │       └── StatusBadge (Label: "Ready")
    ├── ControlsBar (HBoxContainer)
    │   ├── RunButton (Button: "▶ Run All Tests")
    │   ├── ClearButton (Button: "⟲ Reset")
    │   └── SummaryLabel ("0 / 44 Completed")
    ├── ProgressContainer (MarginContainer)
    │   └── TestProgressBar (ProgressBar, Min: 0, Max: 44, Step: 1)
    └── ResultsPanel (PanelContainer, Size Flags: Expand Fill)
        └── ResultsTree (Tree, Columns: 4)
            Column 0: Status Icon (PASS / FAIL)
            Column 1: Test Suite Category
            Column 2: Assertion Description
            Column 3: Elapsed Latency (ms)
```

---

## 3. The 44 Tests Executed in the Visual GUI Runner

The GUI script (`tests/test_runner_gui.gd`) executes each test sequentially, updates the progress bar, and inserts a colored row in the `ResultsTree`:

### Suite 1: `SaveManager` Persistence (Tests 1–6)
1. **`High score serialization`**: Tests `SaveManager.save_high_score(128)` writing to `user://savegame.cfg`.
2. **`High score retrieval`**: Tests `SaveManager.load_high_score() == 128`.
3. **`New high score check (higher)`**: Tests `SaveManager.is_new_high_score(200) == true`.
4. **`New high score check (lower)`**: Tests `SaveManager.is_new_high_score(50) == false`.
5. **`Audio bus volume persistence`**: Tests `SaveManager.set_bus_volume("Music", 0.45)` & retrieval.
6. **`Audio bus index resolution`**: Tests `AudioServer.get_bus_index("Music") >= 0`.

### Suite 2: `Mob` Behaviors & Physics (Tests 7–12)
7. **`Mob layer isolation`**: Asserts `mob.collision_layer == 2` (Enemies).
8. **`Mob mask isolation`**: Asserts `mob.collision_mask == 0` (No internal collisions).
9. **`Mob group registration`**: Asserts `mob.is_in_group("mobs") == true`.
10. **`Randomized behavior selection`**: Asserts `mob.mob_type` in `["fly", "swim", "walk"]`.
11. **`Swimming sinusoidal steering`**: Simulates `_physics_process(0.2)` and verifies Y-velocity wave displacement.
12. **`Flying sprint speed multiplier`**: Verifies 1.25x linear velocity increase on flying type.

### Suite 3: `Player` Mechanics & Touch (Tests 13–23)
13. **`Player collision layer`**: Asserts `player.collision_layer == 1`.
14. **`Player collision mask`**: Asserts `player.collision_mask == 2` (Enemy scanner).
15. **`Base speed parameter`**: Asserts `player.speed == 400`.
16. **`Spawn coordinate reset`**: Asserts `start(Vector2(120, 240))` sets exact location.
17. **`Spawn visibility reset`**: Asserts `player.visible == true` upon start.
18. **`Spawn collision shape activation`**: Asserts `collision_shape.disabled == false` upon start.
19. **`Touch drag event detection`**: Emits `InputEventScreenDrag` and asserts `is_touch_active == true`.
20. **`Target position interpolation`**: Asserts `target_position` updates to touch coordinate.
21. **`Deferred collision disabling`**: Simulates `_on_body_entered()` and asserts disabled state after next frame.
22. **`Visual death feedback`**: Asserts `animated_sprite.visible == false` on hit.
23. **`Particle death emission`**: Asserts `death_particles.emitting == true` on hit.

### Suite 4: `Gameplay` Integration & UI Lifecycle (Tests 24–44)
24. **`Music player spatiality`**: Asserts `Music` node is `AudioStreamPlayer`.
25. **`Death SFX player spatiality`**: Asserts `DeathSound` node is `AudioStreamPlayer`.
26. **`Music bus declaration`**: Asserts `Music.bus == &"Music"`.
27. **`SFX bus declaration`**: Asserts `DeathSound.bus == &"SFX"`.
28. **`MobContainer node presence`**: Asserts `main.has_node("MobContainer")`.
29. **`MobContainer initial state`**: Asserts child count equals `0`.
30. **`Spawn pooling target`**: Asserts mob instances spawn into `MobContainer`.
31. **`Container bulk cleanup`**: Asserts `clear_mobs()` frees children.
32. **`PauseMenu process mode`**: Asserts `process_mode == Node.PROCESS_MODE_ALWAYS`.
33. **`Music volume UI slider`**: Asserts `MusicSlider` exists in pause menu.
34. **`SFX volume UI slider`**: Asserts `SFXSlider` exists in pause menu.
35. **`Pause overlay visibility`**: Asserts pause menu shows when paused.
36. **`SceneTree pause state`**: Asserts engine freezes on pause.
37. **`Pause overlay dismissal`**: Asserts pause menu hides on resume.
38. **`SceneTree resume state`**: Asserts engine unfreezes on resume.
39. **`GameOver initial visibility`**: Asserts overlay starts hidden.
40. **`GameOver show trigger`**: Asserts overlay shows on game over.
41. **`GameOver final score text`**: Asserts label shows `"Final Score: 45"`.
42. **`GameOver high score text`**: Asserts label shows `"High Score: 90"`.
43. **`Baseline spawn interval`**: Asserts formula yields `0.5s` at score 0.
44. **`Max difficulty spawn clamp`**: Asserts formula clamps at `0.22s` at score 50+.

---

## 4. Advantages Over Plugin-Based Runners

1. **Zero Setup Required**: No plugin enablement, no dependency conflicts, no `.cfg` files.
2. **One-Key Execution**: Open the scene in Godot and press <kbd>F6</kbd>.
3. **Smooth Live Visuals**: You see the progress bar advance in real time as each test runs.
4. **Standalone Portability**: Can be compiled into debug builds or shared with team members without requiring editor plugins.
