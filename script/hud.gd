extends CanvasLayer

signal start_game
signal pause_requested

@onready var score_label: Label = $ScoreLabel
@onready var message_label: Label = $Message
@onready var start_button: Button = $StartButton
@onready var instruction_label: Label = $InstructionLabel
@onready var message_timer: Timer = $MessageTimer
@onready var pause_button: Button = $PauseButton


func show_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	message_timer.start()


## Legacy game over flow retained for backward-compatibility.
## Note: Scene/game_over.tscn is the authoritative overlay presentation.
func show_game_over() -> void:
	show_message("Game Over!")
	#Wait till the message timer has counted 
	await message_timer.timeout
	
	message_label.text = "Dodge the Creeps!"
	message_label.show()
	
	#make a one-shot timmer and wait for it to finish
	#One-shot -> a property or node type that triggers a single execution without repetition, commonly used in timers, particles, and animations.
	await get_tree().create_timer(1.0).timeout
	start_button.show()
	if instruction_label != null:
		instruction_label.show()
	set_pause_button_visible(false)


func update_score(score: int) -> void:
	score_label.text = str(score)


func set_pause_button_visible(visible_state: bool) -> void:
	if pause_button != null:
		pause_button.visible = visible_state


func _on_start_button_pressed() -> void:
	start_button.hide()
	if instruction_label != null:
		instruction_label.hide()
	start_game.emit()


func _on_pause_button_pressed() -> void:
	pause_requested.emit()


func _on_message_timer_timeout() -> void:
	message_label.hide()
