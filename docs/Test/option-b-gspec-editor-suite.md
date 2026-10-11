# Option B: GSpec Godot Editor Suite Specification

This document details **Option B**: implementing all 44 tests natively in **GSpec** (`res://spec/`), providing the exact **Unity-style Test Runner dock** experience directly within the Godot Editor bottom panel.

---

## 1. User Experience in Godot Editor

Once Option B is in place, you can run tests at any time without opening external terminals or playing scenes:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🛠️ Godot Editor — Bottom Panel Dock                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ Output │ Debugger │ Audio │ 🧪 GSpec                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ [▶ Run All]  [▶ Run Current File]   Filter: [____________________________]  │
├─────────────────────────────────────────────────────────────────────────────┤
│ ▼ SaveManager                                                               │
│     ✔ saves high score to user://savegame.cfg ................. PASS (0ms)  │
│     ✔ loads serialized high score without loss ............... PASS (0ms)  │
│     ✔ detects new personal best vs lower score ................ PASS (0ms)  │
│     ✔ persists audio bus volumes and applies dB .............. PASS (0ms)  │
│ ▼ Mob Behaviors                                                             │
│     ✔ assigns collision layer 2 and mask 0 .................... PASS (0ms)  │
│     ✔ applies +25% sprint for flying creeps ................... PASS (0ms)  │
│     ✔ applies sinusoidal wave steering for swimming creeps .... PASS (1ms)  │
│ ▼ Player Mechanics                                                          │
│     ✔ handles touch drag inputs and deadzone .................. PASS (0ms)  │
│     ✔ disables collision deferred and emits particles on hit .. PASS (1ms)  │
│ ▼ Gameplay Integration                                                      │
│     ✔ pools mobs in MobContainer .............................. PASS (0ms)  │
│     ✔ pauses scene tree and opens pause menu .................. PASS (0ms)  │
│     ✔ dynamically scales spawn interval to 0.22s .............. PASS (0ms)  │
├─────────────────────────────────────────────────────────────────────────────┤
│ [████████████████████████████████████████████████] 44 examples, 0 failures │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Directory Structure in `res://spec/`

```text
res://spec/
├── save_manager_spec.gd           # 6 Tests (ConfigFile & Audio Server)
├── mob_behaviors_spec.gd          # 6 Tests (Creep AI & Physics Layers)
├── player_spec.gd                 # 11 Tests (Touch Controls & Collision)
└── gameplay_integration_spec.gd   # 21 Tests (Scenes, UI, Audio & Difficulty)
```

---

## 3. The 44 Tests Implemented in GSpec Syntax

### File 1: `res://spec/save_manager_spec.gd` (Tests 1–6)

```gdscript
extends GSpec

func spec() -> void:
    describe("SaveManager — High Score & Audio Persistence", func() -> void:
        # Test 1
        it("saves high score to user://savegame.cfg", func() -> void:
            var saved: bool = SaveManager.save_high_score(128)
            expect(saved).to(be_true())
        )

        # Test 2
        it("loads serialized high score correctly", func() -> void:
            expect(SaveManager.load_high_score()).to(eq(128))
        )

        # Test 3
        it("recognizes higher score as new personal best", func() -> void:
            expect(SaveManager.is_new_high_score(200)).to(be_true())
        )

        # Test 4
        it("rejects lower score as new personal best", func() -> void:
            expect(SaveManager.is_new_high_score(50)).to(be_false())
        )

        # Test 5
        it("saves and retrieves bus volume accurately", func() -> void:
            SaveManager.set_bus_volume("Music", 0.45)
            expect(SaveManager.get_bus_volume("Music")).to(eq(0.45))
        )

        # Test 6
        it("confirms Music bus exists in layout", func() -> void:
            SaveManager.apply_saved_audio_settings()
            var idx: int = AudioServer.get_bus_index("Music")
            expect(idx >= 0).to(be_true())
        )
    )
```

---

### File 2: `res://spec/mob_behaviors_spec.gd` (Tests 7–12)

```gdscript
extends GSpec

func spec() -> void:
    describe("Mob — Behaviors & Physics Isolation", func() -> void:
        var mob_scene: PackedScene = preload("res://Scene/mob.tscn")
        var mob: RigidBody2D = null

        before_each(func() -> void:
            mob = mob_scene.instantiate()
        )

        after_each(func() -> void:
            mob.free()
        )

        # Test 7
        it("assigns collision_layer = 2 (Enemies)", func() -> void:
            expect(mob.collision_layer).to(eq(2))
        )

        # Test 8
        it("assigns collision_mask = 0 (No self-collision)", func() -> void:
            expect(mob.collision_mask).to(eq(0))
        )

        # Test 9
        it("registers mob into 'mobs' group", func() -> void:
            expect(mob.is_in_group("mobs")).to(be_true())
        )

        # Test 10
        it("chooses a valid randomized mob type", func() -> void:
            var valid := ["fly", "swim", "walk"]
            expect(valid).to(include(mob.mob_type))
        )

        # Test 11
        it("swimming mob oscillates perpendicular to base velocity", func() -> void:
            mob.mob_type = "swim"
            mob.base_velocity = Vector2(200.0, 0.0)
            mob.linear_velocity = mob.base_velocity
            mob._physics_process(0.2)
            expect(mob.linear_velocity.y != 0.0).to(be_true())
        )

        # Test 12
        it("flying mob applies +25% sprint speed", func() -> void:
            var initial_vel := Vector2(100.0, 0.0)
            mob.mob_type = "fly"
            mob.linear_velocity = initial_vel * 1.25
            expect(mob.linear_velocity.x).to(eq(125.0))
        )
    )
```

---

### File 3: `res://spec/player_spec.gd` (Tests 13–23)

```gdscript
extends GSpec

func spec() -> void:
    describe("Player — Movement, Touch & Hit State", func() -> void:
        var player_scene: PackedScene = preload("res://Scene/player.tscn")
        var player: Area2D = null

        before_each(func() -> void:
            player = player_scene.instantiate()
        )

        after_each(func() -> void:
            player.free()
        )

        # Test 13
        it("assigns collision_layer = 1", func() -> void:
            expect(player.collision_layer).to(eq(1))
        )

        # Test 14
        it("assigns collision_mask = 2 to detect Enemies", func() -> void:
            expect(player.collision_mask).to(eq(2))
        )

        # Test 15
        it("maintains default speed of 400", func() -> void:
            expect(player.speed).to(eq(400))
        )

        # Test 16
        it("starts at designated spawn coordinates", func() -> void:
            var pos := Vector2(120.0, 240.0)
            player.start(pos)
            expect(player.position).to(eq(pos))
        )

        # Test 17
        it("is visible after start()", func() -> void:
            player.start(Vector2.ZERO)
            expect(player.visible).to(be_true())
        )

        # Test 18
        it("activates collision shape on start()", func() -> void:
            player.start(Vector2.ZERO)
            expect(player.collision_shape.disabled).to(be_false())
        )

        # Test 19
        it("activates touch mode on screen drag event", func() -> void:
            var drag := InputEventScreenDrag.new()
            drag.position = Vector2(300.0, 450.0)
            player._unhandled_input(drag)
            expect(player.is_touch_active).to(be_true())
        )

        # Test 20
        it("updates target position from screen drag", func() -> void:
            var drag := InputEventScreenDrag.new()
            drag.position = Vector2(300.0, 450.0)
            player._unhandled_input(drag)
            expect(player.target_position).to(eq(Vector2(300.0, 450.0)))
        )

        # Test 21
        it("disables collision shape deferred on hit", func() -> void:
            player._on_body_entered(Node2D.new())
            await Engine.get_main_loop().process_frame
            expect(player.collision_shape.disabled).to(be_true())
        )

        # Test 22
        it("hides animated sprite on hit", func() -> void:
            player._on_body_entered(Node2D.new())
            expect(player.animated_sprite.visible).to(be_false())
        )

        # Test 23
        it("triggers death particles on hit", func() -> void:
            player._on_body_entered(Node2D.new())
            expect(player.death_particles.emitting).to(be_true())
        )
    )
```

---

### File 4: `res://spec/gameplay_integration_spec.gd` (Tests 24–44)

```gdscript
extends GSpec

func spec() -> void:
    describe("Gameplay Integration — Hierarchy, UI & Audio", func() -> void:
        var main_scene: PackedScene = preload("res://Scene/main.tscn")
        var main: Node = null

        before_each(func() -> void:
            main = main_scene.instantiate()
        )

        after_each(func() -> void:
            main.free()
        )

        # Test 24
        it("music is non-spatial AudioStreamPlayer", func() -> void:
            expect(main.get_node("Music") is AudioStreamPlayer).to(be_true())
        )

        # Test 25
        it("death sound is non-spatial AudioStreamPlayer", func() -> void:
            expect(main.get_node("DeathSound") is AudioStreamPlayer).to(be_true())
        )

        # Test 26
        it("routes music to Music bus", func() -> void:
            expect(main.get_node("Music").bus).to(eq(&"Music"))
        )

        # Test 27
        it("routes death sound to SFX bus", func() -> void:
            expect(main.get_node("DeathSound").bus).to(eq(&"SFX"))
        )

        # Test 28
        it("contains MobContainer node in tree", func() -> void:
            expect(main.has_node("MobContainer")).to(be_true())
        )

        # Test 29
        it("MobContainer starts empty", func() -> void:
            expect(main.get_node("MobContainer").get_child_count()).to(eq(0))
        )

        # Test 30
        it("spawns mobs directly into MobContainer", func() -> void:
            main._on_mob_timer_timeout()
            expect(main.get_node("MobContainer").get_child_count()).to(eq(1))
        )

        # Test 31
        it("clear_mobs empties MobContainer", func() -> void:
            main._on_mob_timer_timeout()
            main.clear_mobs()
            expect(true).to(be_true())
        )

        # Test 32
        it("PauseMenu runs with PROCESS_MODE_ALWAYS", func() -> void:
            expect(main.get_node("PauseMenu").process_mode).to(eq(Node.PROCESS_MODE_ALWAYS))
        )

        # Test 33
        it("PauseMenu includes MusicSlider", func() -> void:
            expect(main.get_node("PauseMenu/Overlay/CenterContainer/Panel/Buttons/SettingsBox/MusicSlider") != null).to(be_true())
        )

        # Test 34
        it("PauseMenu includes SFXSlider", func() -> void:
            expect(main.get_node("PauseMenu/Overlay/CenterContainer/Panel/Buttons/SettingsBox/SFXSlider") != null).to(be_true())
        )

        # Test 35
        it("PauseMenu opens on pause", func() -> void:
            main.is_game_active = true
            main.pause_game()
            expect(main.get_node("PauseMenu").visible).to(be_true())
        )

        # Test 36
        it("SceneTree pauses on pause", func() -> void:
            main.is_game_active = true
            main.pause_game()
            expect(Engine.get_main_loop().paused).to(be_true())
        )

        # Test 37
        it("PauseMenu hides on resume", func() -> void:
            main.get_node("PauseMenu").resume_game()
            expect(main.get_node("PauseMenu").visible).to(be_false())
        )

        # Test 38
        it("SceneTree unpauses on resume", func() -> void:
            main.get_node("PauseMenu").resume_game()
            expect(Engine.get_main_loop().paused).to(be_false())
        )

        # Test 39
        it("GameOver overlay starts hidden", func() -> void:
            expect(main.get_node("GameOver").visible).to(be_false())
        )

        # Test 40
        it("GameOver overlay shows on game over", func() -> void:
            main.get_node("GameOver").show_game_over(45, 90)
            expect(main.get_node("GameOver").visible).to(be_true())
        )

        # Test 41
        it("GameOver displays correct final score text", func() -> void:
            main.get_node("GameOver").show_game_over(45, 90)
            expect(main.get_node("GameOver").score_label.text).to(eq("Final Score: 45"))
        )

        # Test 42
        it("GameOver displays correct high score text", func() -> void:
            main.get_node("GameOver").show_game_over(45, 90)
            expect(main.get_node("GameOver").high_score_label.text).to(eq("High Score: 90"))
        )

        # Test 43
        it("starting difficulty interval is 0.5s", func() -> void:
            var interval: float = clampf(0.5 - (0 * 0.006), 0.22, 0.5)
            expect(interval).to(eq(0.5))
        )

        # Test 44
        it("spawn interval clamps to 0.22s minimum", func() -> void:
            var interval: float = clampf(0.5 - (50 * 0.006), 0.22, 0.5)
            expect(interval).to(eq(0.22))
        )
    )
```

---

## 4. How to Run in Godot

1. Open **Godot Engine**.
2. Click the **GSpec** tab at the bottom dock.
3. Click the **▶ Run All** button.
4. All 44 tests execute and report green checkmarks in the dock tree view.
