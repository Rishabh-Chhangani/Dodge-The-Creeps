# Improvement Roadmap

This roadmap outlines prioritized engineering work to elevate the project to release quality.

## Phase 1: Baseline Fixes and Typing (Priority: P2)

**Task ID: T-01 - Fix Typos and Naming Conventions — Completed (2026-10-11)**
- **Priority**: P2
- **Problem Statement**: The Start button node and callback used inconsistent misspelled names.
- **Solution**: Name the node `StartButton` and connect its `pressed` signal to `_on_start_button_pressed`; update the script's node paths to match.
- **Files Affected**: `Scene/hud.tscn`, `script/hud.gd`
- **Acceptance Criteria**: Met — the node, script paths, and pressed-signal callback use matching names. Godot 4.5 headless project validation completed without parse errors.

**Task ID: T-02 - Enforce GDScript Static Typing — Completed (2026-10-11)**
- **Priority**: P2
- **Problem Statement**: Lack of static typing makes refactoring risky.
- **Solution**: Add explicit types to all variables (e.g., `var score: int = 0`) and return types to all functions across `player.gd`, `mob.gd`, `hud.gd`, and `main.gd`.
- **Files Affected**: `script/player.gd`, `script/mob.gd`, `script/hud.gd`, `script/main.gd`.
- **Acceptance Criteria**: Met — all variables, function arguments, and function returns have static type annotations. Verified via Godot 4.5 headless test runner.

## Phase 2: Mobile Adaptation (Priority: P1)

**Task ID: T-03 - Implement Touch Controls for Android — Completed (2026-10-11)**
- **Priority**: P1
- **Problem Statement**: The game assumes physical keyboard input, making mobile play difficult or impossible.
- **Solution**: Added touch & drag input support (`InputEventScreenTouch` and `InputEventScreenDrag`) in `script/player.gd` moving towards touch coordinates with a deadzone to prevent jitter. Enabled touch-from-mouse and mouse-from-touch emulation in `project.godot`.
- **Files Affected**: `project.godot`, `script/player.gd`.
- **Acceptance Criteria**: Met — game fully supports mobile touch & drag controls alongside desktop keyboard input. Verified via headless test runner.

## Phase 3: UI/UX and Polish (Priority: P3)

**Task ID: T-04 - Improve Title Screen and Game Over State — Completed (2026-10-11)**
- **Priority**: P3
- **Problem Statement**: The title screen is a simple text overlay. Visual feedback on death is lacking.
- **Solution**: Added `InstructionLabel` on Title screen to guide players on touch and keyboard movement. Added explosive `DeathParticles` (`CPUParticles2D`) on Player hit. Added decaying trauma-based screen shake via `Camera2D` in `main.gd`. Implemented `GameOver` UI overlay with final score display and restart flow.
- **Files Affected**: `Scene/hud.tscn`, `script/hud.gd`, `Scene/player.tscn`, `script/player.gd`, `Scene/main.tscn`, `script/main.gd`, `Scene/game_over.tscn`, `Scene/game_over.gd`.
- **Acceptance Criteria**: Met — distinct title presentation, dynamic screen shake and particle death feedback, and styled game over screen with score reporting. Verified via headless integration test.

## Phase 4: Automated Testing (Priority: P1)

**Task ID: T-05 - Headless Automated Testing Framework — Completed (2026-10-11)**
- **Priority**: P1
- **Problem Statement**: No automated verification exists.
- **Solution**: Created a headless SceneTree-based test harness (`tests/test_runner.gd`) executing modular test suites:
  - `tests/test_save_manager.gd`: High score persistence, ConfigFile operations, and AudioServer linear/dB bus attenuation.
  - `tests/test_mob_behaviors.gd`: Physics layers, enemy groups, mob randomized types, and swimming sinusoidal oscillation / flying speed modifiers.
  - `tests/test_player.gd`: Start positioning, touch drag input events, deferred collision shape disabling, and death particle emission.
  - `tests/test_gameplay_integration.gd`: MobContainer child management, AudioStreamPlayer non-spatial bus assignment, PauseMenu lifecycle, GameOver overlay scoring, and dynamic difficulty scaling.
- **Files Affected**: `tests/test_runner.gd`, `tests/test_save_manager.gd`, `tests/test_mob_behaviors.gd`, `tests/test_player.gd`, `tests/test_gameplay_integration.gd`.
- **Acceptance Criteria**: Met — runner executes headlessly with exit code 0; verified 44/44 assertions passed with zero failures.
