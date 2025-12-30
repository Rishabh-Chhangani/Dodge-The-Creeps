extends CanvasLayer
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over!")
	#Wait till the message timer has counted 
	await $MessageTimer.timeout
	
	$Message.text = "Dodge the Creeps!"
	$Message.show()
	
	#make a one-shot timmer and wait for it to finish
	#One-shot -> a property or node type that triggers a single execution without repetition, commonly used in timers, particles, and animations.
	await get_tree().create_timer(1.0).timeout
	$StartButoon.show()

func update_score(score):
	$ScoreLabel.text = str(score)
	
func _on_start_butoon_pressed() -> void:
	$StartButoon.hide()
	start_game.emit()
	
func _on_message_timer_timeout() -> void:
	$Message.hide()
	
