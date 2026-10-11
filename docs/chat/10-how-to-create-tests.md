# Session 10: How to Create Tests in Godot 4

**Date:** 2026-10-11  

---

### User

How to create those test. Do not make them yet

### Assistant

I explained the principles, patterns, and workflows for authoring automated tests in Godot 4:

1. **The Testing Model in Godot**:
   - Node-based and Scene-based testing patterns.
   - Headless execution with real OS exit codes (`0` for success, non-zero for failure).
2. **Two Primary Architectural Approaches**:
   - **Approach A: Built-in Lightweight SceneTree Runner**:
     - Extends `SceneTree`.
     - Uses `_initialize()` and `await process_frame` to allow nodes to enter the tree and execute lifecycle methods.
     - Custom assertion helpers (`assert_eq`, `assert_true`).
     - Exits via `quit(code)` for CI compatibility without third-party plugins.
   - **Approach B: GUT Framework (Godot Unit Test)**:
     - Test classes extend `GutTest`.
     - Built-in lifecycle methods (`before_each`, `after_each`).
     - Signal monitoring via `watch_signals(node)` and `assert_signal_emitted(node, signal_name)`.
     - CLI execution via `addons/gut/gut_cmdln.gd`.
3. **Structuring Tests for Dodge the Creeps**:
   - Separation into `tests/unit/` (pure data, `SaveManager`, math equations) and `tests/integration/` (scenes, signals, timers, collisions).
4. **No Test Files Created**:
   - Respected user constraint to explain only and not create files yet.
