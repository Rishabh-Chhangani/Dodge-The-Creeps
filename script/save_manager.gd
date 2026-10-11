extends RefCounted
class_name SaveManager

## SaveManager handles high score and game preferences persistence to user://.
## Uses ConfigFile with defensive error handling and fallback recovery.

const SAVE_PATH: String = "user://savegame.cfg"
const BACKUP_PATH: String = "user://savegame.cfg.bak"
const SECTION_RECORDS: String = "records"
const SECTION_AUDIO: String = "audio"
const KEY_HIGH_SCORE: String = "high_score"
const KEY_MASTER_VOL: String = "master_volume"
const KEY_MUSIC_VOL: String = "music_volume"
const KEY_SFX_VOL: String = "sfx_volume"


static func _get_config() -> ConfigFile:
	var config := ConfigFile.new()
	if FileAccess.file_exists(SAVE_PATH):
		var err := config.load(SAVE_PATH)
		if err == OK:
			return config
	if FileAccess.file_exists(BACKUP_PATH):
		var backup_err := config.load(BACKUP_PATH)
		if backup_err == OK:
			return config
	return config


static func _save_config(config: ConfigFile) -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)
	return config.save(SAVE_PATH) == OK


static func load_high_score() -> int:
	var config := _get_config()
	return int(config.get_value(SECTION_RECORDS, KEY_HIGH_SCORE, 0))


static func save_high_score(new_high_score: int) -> bool:
	var config := _get_config()
	config.set_value(SECTION_RECORDS, KEY_HIGH_SCORE, new_high_score)
	return _save_config(config)


static func is_new_high_score(current_score: int) -> bool:
	return current_score > load_high_score()


static func reset_high_score() -> bool:
	return save_high_score(0)


# Audio Settings Persistence

static func get_bus_volume(bus_name: String) -> float:
	var config := _get_config()
	match bus_name.to_lower():
		"master":
			return float(config.get_value(SECTION_AUDIO, KEY_MASTER_VOL, 1.0))
		"music":
			return float(config.get_value(SECTION_AUDIO, KEY_MUSIC_VOL, 0.8))
		"sfx":
			return float(config.get_value(SECTION_AUDIO, KEY_SFX_VOL, 1.0))
		_:
			return 1.0


static func set_bus_volume(bus_name: String, volume_linear: float) -> void:
	var config := _get_config()
	match bus_name.to_lower():
		"master":
			config.set_value(SECTION_AUDIO, KEY_MASTER_VOL, volume_linear)
		"music":
			config.set_value(SECTION_AUDIO, KEY_MUSIC_VOL, volume_linear)
		"sfx":
			config.set_value(SECTION_AUDIO, KEY_SFX_VOL, volume_linear)
	_save_config(config)
	apply_volume_to_server(bus_name, volume_linear)


static func apply_volume_to_server(bus_name: String, volume_linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		var clamped: float = clampf(volume_linear, 0.0, 1.0)
		if clamped <= 0.001:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clamped))


static func apply_saved_audio_settings() -> void:
	apply_volume_to_server("Master", get_bus_volume("Master"))
	apply_volume_to_server("Music", get_bus_volume("Music"))
	apply_volume_to_server("SFX", get_bus_volume("SFX"))
