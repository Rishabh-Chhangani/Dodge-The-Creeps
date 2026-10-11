# Session 6: Architectural Inspection & Flaws Analysis

**Date:** 2026-10-11  

---

### User

i wannt you to inspect the architecture and poiinnt out the faws of it '

### Assistant

I conducted a comprehensive architectural inspection of the codebase across scene hierarchy, script design, data flow, audio routing, and lifecycle management.

Key Architectural Flaws Identified:
1. **Monolithic Controller Anti-Pattern (`Main`)**: `main.gd` manages spawning, UI updates, camera shake, audio, scoring, and overlay instantiation, violating the Single Responsibility Principle (SRP).
2. **Conflicting Dual Game Over Systems**: `hud.gd` contains legacy tutorial game-over logic (`show_game_over()`), while `main.gd` instantiates a dedicated `GameOver` canvas overlay, creating dual sources of truth and redundant code.
3. **Flat Scene Hierarchy & Direct Root Spawning**: Mobs are spawned directly via `add_child(mob)` under `Main` rather than in a dedicated container node (like `MobContainer`), requiring global `get_tree().call_group()` lookups to clean up enemies.
4. **Incorrect Audio Node Types & Lack of Audio Bus Architecture**: Global non-spatial BGM and SFX use `AudioStreamPlayer2D` instead of `AudioStreamPlayer`, and all audio routes to `Master` without dedicated `Music` and `SFX` buses.
5. **NodePath String Hardcoding**: Extensive reliance on inline `$` / `get_node()` queries rather than cached `@onready var` typed references, creating runtime fragility if nodes are renamed or moved.
6. **Spawn Randomness Flaw**: `direction += randf_range(PI/4, PI/4)` in `main.gd` provides zero angular variation because min and max are identical.
7. **Lack of Difficulty Scaling**: Mob spawn interval (0.5s) and speed (150-250) remain fixed regardless of score, resulting in a flat difficulty curve.
8. **Missing Global State & High Score Persistence**: No Autoload singleton or disk persistence (`user://`); scores vanish upon restart.
9. **Unsegregated Collision Layers & Masks**: Player and mobs both exist on default Layer 1 / Mask 1 without dedicated layer filtering.
10. **Absence of Mobile Pause / Focus Handling**: No pause state or focus loss listeners to suspend gameplay when the mobile app is backgrounded.
