# Session 7: Architectural Solutions & Refactoring Blueprint

**Date:** 2026-10-11  

---

### User

Make a solution md  for all this flaws

### Assistant

I have created a comprehensive architectural solutions document in [`docs/architectural-solutions.md`](../architectural-solutions.md) covering design patterns, refactoring steps, GDScript code patterns, and an implementation roadmap for all 10 architectural flaws identified:

1. **Monolithic "God Node" Resolution**:
   - Extract spawning into a dedicated `MobSpawner` component node owning `MobPath` and difficulty scaling formulas.
   - Separate game state and scoring into an Autoload `GameState.gd` singleton.
   - Isolate camera shake into a modular `ShakingCamera2D` component extending `Camera2D`.
2. **Unification of Game Over Flows**:
   - Remove dead code `show_game_over()` from `script/hud.gd`.
   - Pre-instance `Scene/game_over.tscn` as a hidden `CanvasLayer` in `main.tscn` rather than incurring runtime instantiation and free overhead.
3. **Containerized Enemy Hierarchy (`MobContainer`)**:
   - Add a `MobContainer` node (`Node2D`) in `Scene/main.tscn`.
   - Spawn mobs into `MobContainer` and perform cleanups via local iteration over `MobContainer.get_children()` instead of global `get_tree().call_group()`.
4. **Audio Architecture & Bus Separation**:
   - Convert positional `AudioStreamPlayer2D` nodes to standard non-spatial `AudioStreamPlayer`.
   - Create `default_bus_layout.tres` with `Master`, `Music`, and `SFX` buses, enabling independent volume attenuation and routing.
5. **Type-Safe Cached Node References (`@onready`)**:
   - Replace repeated inline `$` string lookups with typed `@onready var` variables at script scope.
6. **Correct Spawn Angle Mathematics**:
   - Fix the static spawn trajectory bug from `direction += randf_range(PI/4, PI/4)` to `direction += randf_range(-PI / 4.0, PI / 4.0)` for full ±45° angular variance.
7. **Progressive Difficulty Scaling**:
   - Scale spawn interval dynamically from 0.6s down to 0.25s as score climbs (`clampf(0.6 - (score * 0.008), 0.25, 0.6)`).
   - Dynamically scale mob speed by up to +80% based on score.
8. **High Score & Settings Persistence (`SaveManager`)**:
   - Implement `SaveManager` utilizing `ConfigFile` persisted to `user://savegame.cfg`.
9. **Physics Layer & Mask Segregation**:
   - Define named layers in `project.godot`: Layer 1 (Player), Layer 2 (Enemies), Layer 3 (Boundaries).
   - Set Player mask to detect Layer 2; set Mob mask to 0 to prevent inter-enemy collision calculations.
10. **Mobile Lifecycle & Pause Architecture**:
    - Add on-screen pause toggle and `PauseMenu` (`process_mode = Node.PROCESS_MODE_ALWAYS`).
    - Bind `_notification` handlers for `NOTIFICATION_APPLICATION_PAUSED` and `NOTIFICATION_WM_WINDOW_FOCUS_OUT` to prevent background deaths.

A prioritized 5-phase refactoring roadmap (P1 through P5) was established and indexed in [`docs/README.md`](../README.md).
