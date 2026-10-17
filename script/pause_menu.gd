extends CanvasLayer

signal resume_requested
signal restart_requested

@onready var overlay: Control = $Overlay
@onready var resume_button: Button = $Overlay/CenterContainer/Panel/Buttons/ResumeButton
@onready var restart_button: Button = $Overlay/CenterContainer/Panel/Buttons/RestartButton
@onready var music_slider: HSlider = $Overlay/CenterContainer/Panel/Buttons/SettingsBox/MusicSlider
@onready var sfx_slider: HSlider = $Overlay/CenterContainer/Panel/Buttons/SettingsBox/SFXSlider


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_load_audio_sliders()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE)):
		resume_game()
		resume_requested.emit()
		get_viewport().set_input_as_handled()


func _load_audio_sliders() -> void:
	if music_slider != null:
		music_slider.value = SaveManager.get_bus_volume("Music")
	if sfx_slider != null:
		sfx_slider.value = SaveManager.get_bus_volume("SFX")


func pause_game() -> void:
	if is_inside_tree():
		get_tree().paused = true
	_load_audio_sliders()
	show()
	if resume_button != null:
		resume_button.grab_focus()


func resume_game() -> void:
	if is_inside_tree():
		get_tree().paused = false
	hide()


func _on_music_slider_value_changed(value: float) -> void:
	SaveManager.set_bus_volume("Music", value)


func _on_sfx_slider_value_changed(value: float) -> void:
	SaveManager.set_bus_volume("SFX", value)


func _on_resume_button_pressed() -> void:
	resume_game()
	resume_requested.emit()


func _on_restart_button_pressed() -> void:
	resume_game()
	restart_requested.emit()
