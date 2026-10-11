extends RefCounted

## Unit tests for SaveManager high score and audio bus persistence.

static func run(runner) -> void:
	print("Running SaveManager Tests...")
	test_high_score_persistence(runner)
	test_audio_volume_persistence(runner)


static func test_high_score_persistence(runner) -> void:
	var original: int = SaveManager.load_high_score()
	var test_val: int = 128
	
	var saved: bool = SaveManager.save_high_score(test_val)
	runner.assert_true(saved, "SaveManager.save_high_score succeeded")
	runner.assert_eq(SaveManager.load_high_score(), test_val, "SaveManager loaded correct high score")
	runner.assert_true(SaveManager.is_new_high_score(200), "Higher score recognized as new high score")
	runner.assert_true(not SaveManager.is_new_high_score(50), "Lower score rejected as new high score")
	
	# Restore original score
	SaveManager.save_high_score(original)


static func test_audio_volume_persistence(runner) -> void:
	var original_music: float = SaveManager.get_bus_volume("Music")
	var test_vol: float = 0.45
	
	SaveManager.set_bus_volume("Music", test_vol)
	runner.assert_eq(SaveManager.get_bus_volume("Music"), test_vol, "Music volume saved and retrieved")
	
	SaveManager.apply_saved_audio_settings()
	var music_idx: int = AudioServer.get_bus_index("Music")
	runner.assert_true(music_idx >= 0, "Music bus exists")
	
	# Restore original
	SaveManager.set_bus_volume("Music", original_music)
