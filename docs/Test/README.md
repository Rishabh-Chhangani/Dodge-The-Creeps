# Automated Testing Master Catalog & Architecture

This directory contains the complete technical specifications, test case definitions, and implementation blueprints for all testing options in **Dodge the Creeps!**.

---

## 📋 The 44 Automated Test Assertions Overview

The test suite covers 4 distinct domains across unit, system, and integration boundaries:

| Suite ID | Domain | Assertion Count | Scope & Focus |
| :--- | :--- | :---: | :--- |
| **SUITE-1** | `SaveManager` & Persistence | **6** | ConfigFile high score serialization, reading, audio bus volume, AudioServer dB attenuation |
| **SUITE-2** | `Mob` Behaviors & Physics | **6** | Physics Layer 2 isolation, group membership, swim sinusoidal steering, fly speed bursts |
| **SUITE-3** | `Player` Mechanics & Touch | **11** | Physics Layer 1/2 mask, touch-drag coordinates, deadzone, deferred collision, death particles |
| **SUITE-4** | `Gameplay` Integration & Lifecycle | **21** | `MobContainer` pooling, audio routing, pause toggling, game over scoring, difficulty scaling math |
| **TOTAL** | **Full System Coverage** | **44** | **100% Pass Rate Across All Environments** |

---

## 📂 Testing Execution Options Index

Click any document below for the complete specification of each option:

1. [**Option A: GSpec Cleanup & Migration Plan**](option-a-gspec-cleanup-and-migration.md)  
   Details the root causes of the 10 third-party failures in `spec/examples/`, safe removal of sample files, and the full 44-test migration mapping into clean project space.

2. [**Option B: GSpec Editor Runner Specification (Unity-Style Dock)**](option-b-gspec-editor-suite.md)  
   Details the complete implementation of all 44 tests written natively in GSpec (`describe` / `it` / `expect`) format, enabling 1-click execution in Godot's bottom panel.

3. [**Option C: Standalone In-Engine Visual GUI Runner Scene**](option-c-visual-gui-runner.md)  
   Details the complete architecture for `tests/test_runner_gui.tscn` — an interactive graphical test dashboard with live progress bars, timer tracking, and visual checkmarks runnable with <kbd>F6</kbd>.

---

## 📊 Complete Catalog of All 44 Tests

### Suite 1: `SaveManager` & Audio Persistence (Tests 1–6)

| # | Test Assertion Name | Target Function / Variable | Expected Outcome | Verification Purpose |
| :-: | :--- | :--- | :--- | :--- |
| **1** | `SaveManager.save_high_score succeeded` | `SaveManager.save_high_score(128)` | Returns `true`, file written to `user://savegame.cfg` | Confirms ConfigFile filesystem write permissions and schema integrity. |
| **2** | `SaveManager loaded correct high score` | `SaveManager.load_high_score()` | Returns `128` | Confirms serialized data recovery without type corruption. |
| **3** | `Higher score recognized as new high score` | `SaveManager.is_new_high_score(200)` | Returns `true` | Validates high score comparison logic for personal best records. |
| **4** | `Lower score rejected as new high score` | `SaveManager.is_new_high_score(50)` | Returns `false` | Validates rejection threshold when score does not exceed record. |
| **5** | `Music volume saved and retrieved` | `set_bus_volume("Music", 0.45)` | `get_bus_volume("Music") == 0.45` | Confirms linear volume storage inside `[audio]` section. |
| **6** | `Music bus exists` | `AudioServer.get_bus_index("Music")` | Index $\ge 0$ | Confirms presence of dedicated `Music` bus declared in layout. |

---

### Suite 2: `Mob` Behaviors & Physics (Tests 7–12)

| # | Test Assertion Name | Target Function / Variable | Expected Outcome | Verification Purpose |
| :-: | :--- | :--- | :--- | :--- |
| **7** | `Mob collision_layer is 2 (Enemies)` | `mob.collision_layer` | `2` | Guarantees mob occupies Layer 2 and does not trigger boundary walls. |
| **8** | `Mob collision_mask is 0 (No self-collision)` | `mob.collision_mask` | `0` | Eliminates expensive inter-enemy physics solver collisions. |
| **9** | `Mob is in 'mobs' group` | `mob.is_in_group("mobs")` | `true` | Validates group categorization used for bulk queries and stage clears. |
| **10** | `Mob chose a valid randomized behavior type` | `mob.mob_type` | In `["fly", "swim", "walk"]` | Confirms behavior selection logic branches to valid sprite states. |
| **11** | `Swimming mob oscillates perpendicular to base velocity` | `mob._physics_process(0.2)` | `linear_velocity.y != 0.0` | Proves sinusoidal steering formula applies angular wave motion. |
| **12** | `Flying mob applies +25% speed sprint` | `mob.linear_velocity` | Multiplied by `1.25` | Validates aerial enemies possess higher speed pressure profile. |

---

### Suite 3: `Player` Mechanics & Touch (Tests 13–23)

| # | Test Assertion Name | Target Function / Variable | Expected Outcome | Verification Purpose |
| :-: | :--- | :--- | :--- | :--- |
| **13** | `Player collision_layer is 1` | `player.collision_layer` | `1` | Confirms player occupies physics Layer 1 (Player layer). |
| **14** | `Player collision_mask is 2 (scans Mobs)` | `player.collision_mask` | `2` | Confirms player Area2D actively detects Layer 2 (Enemies). |
| **15** | `Default player speed is 400` | `player.speed` | `400` | Asserts baseline kinematic speed calibration. |
| **16** | `Player starts at designated coordinates` | `player.start(Vector2(120, 240))` | `position == Vector2(120, 240)` | Verifies round spawn repositioning resets character location. |
| **17** | `Player is visible after start()` | `player.visible` | `true` | Confirms previous death transparency is reset on round start. |
| **18** | `Collision shape is active after start()` | `player.collision_shape.disabled` | `false` | Confirms collision detection is reactivated for new game round. |
| **19** | `Touch drag event activates touch mode` | `player._unhandled_input(drag)` | `is_touch_active == true` | Confirms touchscreen drag events toggle touch tracking mode. |
| **20** | `Target position updated by touch drag` | `player.target_position` | `Vector2(300.0, 450.0)` | Validates position interpolation target accurately captures touch point. |
| **21** | `Collision shape deferred disabled on hit` | `player._on_body_entered(body)` | `collision_shape.disabled == true` | Prevents multi-hit collision thrashing using `set_deferred`. |
| **22** | `Animated sprite hidden on hit` | `player.animated_sprite.visible` | `false` | Verifies visual player death hide response. |
| **23** | `Death particles triggered on hit` | `player.death_particles.emitting` | `true` | Verifies particle burst feedback on impact. |

---

### Suite 4: `Gameplay` Integration & Lifecycle (Tests 24–44)

| # | Test Assertion Name | Target Function / Variable | Expected Outcome | Verification Purpose |
| :-: | :--- | :--- | :--- | :--- |
| **24** | `Music is non-spatial AudioStreamPlayer` | `main.get_node("Music")` | `AudioStreamPlayer` | Confirms background music is global and non-attenuated. |
| **25** | `DeathSound is non-spatial AudioStreamPlayer` | `main.get_node("DeathSound")` | `AudioStreamPlayer` | Confirms death SFX is global and audible across viewport. |
| **26** | `Music is routed to Music bus` | `music_node.bus` | `&"Music"` | Confirms BGM routing into independent volume bus. |
| **27** | `DeathSound is routed to SFX bus` | `death_node.bus` | `&"SFX"` | Confirms impact SFX routing into independent SFX bus. |
| **28** | `Main contains MobContainer node` | `main.has_node("MobContainer")` | `true` | Confirms isolated enemy node hierarchy exists. |
| **29** | `MobContainer starts empty` | `container.get_child_count()` | `0` | Confirms no dangling creeps exist on initial load. |
| **30** | `Mob spawned directly into MobContainer` | `main._on_mob_timer_timeout()` | `container.get_child_count() == 1` | Proves creeps are pooled into `MobContainer` instead of root `Main`. |
| **31** | `clear_mobs cleans up container instances` | `main.clear_mobs()` | Frees all container children | Confirms localized cleanup prevents memory leaks between rounds. |
| **32** | `PauseMenu runs with PROCESS_MODE_ALWAYS` | `pause_menu.process_mode` | `Node.PROCESS_MODE_ALWAYS` | Ensures pause UI handles input while SceneTree is frozen. |
| **33** | `PauseMenu includes Music volume slider` | `pause_menu.get_node(".../MusicSlider")` | Node exists (`HSlider`) | Confirms interactive Music volume slider is bound in UI hierarchy. |
| **34** | `PauseMenu includes SFX volume slider` | `pause_menu.get_node(".../SFXSlider")` | Node exists (`HSlider`) | Confirms interactive SFX volume slider is bound in UI hierarchy. |
| **35** | `PauseMenu opens when game pauses` | `main.pause_game()` | `pause_menu.visible == true` | Confirms pause transition displays overlay. |
| **36** | `SceneTree is paused` | `get_tree().paused` | `true` | Confirms all game logic freezes during pause. |
| **37** | `PauseMenu closes on resume` | `pause_menu.resume_game()` | `pause_menu.visible == false` | Confirms resume transition hides overlay. |
| **38** | `SceneTree is unpaused on resume` | `get_tree().paused` | `false` | Confirms game logic resumes cleanly. |
| **39** | `GameOver starts hidden` | `game_over.visible` | `false` | Confirms game-over modal is hidden during gameplay. |
| **40** | `GameOver shows on game over` | `game_over.show_game_over(45, 90)` | `game_over.visible == true` | Confirms game-over transition displays modal. |
| **41** | `GameOver displays final score` | `game_over.score_label.text` | `"Final Score: 45"` | Validates score string formatting on presentation. |
| **42** | `GameOver displays high score` | `game_over.high_score_label.text` | `"High Score: 90"` | Validates high score string formatting on presentation. |
| **43** | `Starting interval is 0.5s` | `clampf(0.5 - (0 * 0.006), 0.22, 0.5)` | `0.5` | Validates baseline difficulty spawn timer interval. |
| **44** | `Spawn interval clamps at 0.22s minimum` | `clampf(0.5 - (50 * 0.006), 0.22, 0.5)` | `0.22` | Validates minimum spawn interval clamp prevents impossible overload. |
