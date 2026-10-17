extends CanvasLayer

signal start_game
signal pause_requested
signal joystick_moved(vector: Vector2)

@onready var score_label: Label = $ScoreLabel
@onready var message_label: Label = $Message
@onready var start_button: Button = $StartButton
@onready var instruction_label: Label = $InstructionLabel
@onready var message_timer: Timer = $MessageTimer
@onready var pause_button: Button = $PauseButton
@onready var virtual_joystick: Control = $VirtualJoystick if has_node("VirtualJoystick") else null


func _ready() -> void:
	if instruction_label != null:
		if OS.get_name() == "Windows" or OS.has_feature("pc"):
			instruction_label.text = "Arrow Keys / WASD to Move • Esc to Pause"
		else:
			instruction_label.text = "Drag Joystick or Tap Start to Play"
	if virtual_joystick != null:
		virtual_joystick.show()
		if not virtual_joystick.is_connected("joystick_moved", _on_joystick_moved):
			virtual_joystick.joystick_moved.connect(_on_joystick_moved)


func _on_joystick_moved(vector: Vector2) -> void:
	# Voodoo style: touching/dragging joystick on start screen immediately starts game!
	if start_button != null and start_button.visible and vector != Vector2.ZERO:
		_on_start_button_pressed()
	joystick_moved.emit(vector)


func set_joystick_visible(visible_state: bool) -> void:
	if virtual_joystick != null:
		virtual_joystick.visible = visible_state
		if visible_state:
			if virtual_joystick.has_method("_update_default_position"):
				virtual_joystick._update_default_position()
		else:
			if virtual_joystick.has_method("reset_joystick"):
				virtual_joystick.reset_joystick()


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
	set_joystick_visible(true)


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
