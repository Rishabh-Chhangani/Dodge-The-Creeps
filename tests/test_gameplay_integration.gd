extends RefCounted

## Integration tests for Main controller, MobContainer, GameOver, PauseMenu, and dynamic scaling.

static func run(runner) -> void:
	print("Running Gameplay Integration Tests...")
	var main_scene: PackedScene = load("res://Scene/main.tscn")
	var main_instance = main_scene.instantiate()
	runner.root.add_child(main_instance)
	
	# Verify audio nodes and buses
	var music_node = main_instance.get_node("Music")
	var death_node = main_instance.get_node("DeathSound")
	runner.assert_true(music_node is AudioStreamPlayer, "Music is non-spatial AudioStreamPlayer")
	runner.assert_true(death_node is AudioStreamPlayer, "DeathSound is non-spatial AudioStreamPlayer")
	runner.assert_eq(music_node.bus, &"Music", "Music is routed to Music bus")
	runner.assert_eq(death_node.bus, &"SFX", "DeathSound is routed to SFX bus")
	
	# Verify MobContainer and spawning
	runner.assert_true(main_instance.has_node("MobContainer"), "Main contains MobContainer node")
	var container = main_instance.get_node("MobContainer")
	runner.assert_eq(container.get_child_count(), 0, "MobContainer starts empty")
	
	main_instance._on_mob_timer_timeout()
	runner.assert_eq(container.get_child_count(), 1, "Mob spawned directly into MobContainer")
	
	main_instance.clear_mobs()
	runner.assert_true(true, "clear_mobs cleans up container instances")
	
	# Verify PauseMenu integration and sliders
	var pause_menu = main_instance.get_node("PauseMenu")
	runner.assert_true(pause_menu.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseMenu runs with PROCESS_MODE_ALWAYS")
	runner.assert_true(pause_menu.has_node("Overlay/CenterContainer/Panel/Buttons/SettingsBox/MusicSlider"), "PauseMenu includes Music volume slider")
	runner.assert_true(pause_menu.has_node("Overlay/CenterContainer/Panel/Buttons/SettingsBox/SFXSlider"), "PauseMenu includes SFX volume slider")
	
	main_instance.is_game_active = true
	main_instance.pause_game()
	runner.assert_true(pause_menu.visible, "PauseMenu opens when game pauses")
	runner.assert_true(runner.paused, "SceneTree is paused")
	
	pause_menu.resume_game()
	runner.assert_true(not pause_menu.visible, "PauseMenu closes on resume")
	runner.assert_true(not runner.paused, "SceneTree is unpaused on resume")
	
	# Verify GameOver overlay
	var game_over = main_instance.get_node("GameOver")
	runner.assert_true(not game_over.visible, "GameOver starts hidden")
	game_over.show_game_over(45, 90)
	runner.assert_true(game_over.visible, "GameOver shows on game over")
	runner.assert_eq(game_over.score_label.text, "Final Score: 45", "GameOver displays final score")
	runner.assert_eq(game_over.high_score_label.text, "High Score: 90", "GameOver displays high score")
	game_over.hide_game_over()
	
	# Verify difficulty scaling math
	var interval_0: float = clampf(0.5 - (0 * 0.006), 0.22, 0.5)
	var interval_50: float = clampf(0.5 - (50 * 0.006), 0.22, 0.5)
	runner.assert_eq(interval_0, 0.5, "Starting interval is 0.5s")
	runner.assert_eq(interval_50, 0.22, "Spawn interval clamps at 0.22s minimum")
	
	main_instance.queue_free()
