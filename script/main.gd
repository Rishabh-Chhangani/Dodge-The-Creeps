extends Node2D

@export var mob_scene: PackedScene
@export var game_over_scene: PackedScene

var score: int = 0
var high_score: int = 0
var is_game_active: bool = false

@export var trauma_decay: float = 2.5
@export var max_shake_offset: Vector2 = Vector2(16.0, 16.0)
var trauma: float = 0.0
var trauma_time: float = 0.0

# Type-safe cached node references (Flaw 5)
@onready var player: Area2D = $Player
@onready var mob_timer: Timer = $MobTimer
@onready var score_timer: Timer = $ScoreTimer
@onready var start_timer: Timer = $StartTimer
@onready var start_position: Marker2D = $StartPosition
@onready var mob_path: Path2D = $MobPath
@onready var mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation
@onready var hud: CanvasLayer = $HUD
@onready var music_player: AudioStreamPlayer = $Music
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var camera: Camera2D = $Camera2D
@onready var mob_container: Node2D = $MobContainer
@onready var game_over_ui: CanvasLayer = $GameOver
@onready var pause_menu: CanvasLayer = $PauseMenu


func _enter_tree() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

	_configure_layout()
	get_viewport().size_changed.connect(_configure_layout)

	# Configure background music to loop seamlessly
	if music_player != null and music_player.stream != null:
		if music_player.stream is AudioStreamOggVorbis:
			(music_player.stream as AudioStreamOggVorbis).loop = true
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)

	high_score = SaveManager.load_high_score()
	SaveManager.apply_saved_audio_settings()
	if game_over_ui != null:
		game_over_ui.hide()
	if pause_menu != null:
		pause_menu.hide()
		if pause_menu.has_signal("resume_requested") and not pause_menu.resume_requested.is_connected(_on_pause_menu_resume_requested):
			pause_menu.resume_requested.connect(_on_pause_menu_resume_requested)

	if hud != null and hud.has_signal("joystick_moved") and player != null and player.has_method("set_joystick_vector"):
		if not hud.joystick_moved.is_connected(player.set_joystick_vector):
			hud.joystick_moved.connect(player.set_joystick_vector)


func _configure_layout() -> void:
	_ensure_nodes()
	var viewport_size: Vector2 = get_viewport_rect().size
	if start_position != null:
		start_position.position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.38)
	if mob_path != null:
		mob_path.position = Vector2.ZERO

		var spawn_curve := Curve2D.new()
		spawn_curve.add_point(Vector2(0.0, 0.0))
		spawn_curve.add_point(Vector2(viewport_size.x, 0.0))
		spawn_curve.add_point(Vector2(viewport_size.x, viewport_size.y))
		spawn_curve.add_point(Vector2(0.0, viewport_size.y))
		spawn_curve.add_point(Vector2(0.0, 0.0))
		mob_path.curve = spawn_curve

	if has_node("ColorRect"):
		var color_rect: ColorRect = $ColorRect
		color_rect.position = Vector2.ZERO
		color_rect.size = viewport_size


func _on_music_finished() -> void:
	if is_game_active and music_player != null:
		music_player.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		if is_game_active:
			if get_tree().paused:
				if pause_menu != null and pause_menu.has_method("resume_game"):
					pause_menu.resume_game()
				else:
					get_tree().paused = false
				if hud != null and hud.has_method("set_joystick_visible"):
					hud.set_joystick_visible(true)
			else:
				pause_game()
			get_viewport().set_input_as_handled()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = maxf(trauma - trauma_decay * delta, 0.0)
		var shake: float = trauma * trauma
		trauma_time += delta * 30.0
		if camera != null:
			camera.offset = Vector2(
				max_shake_offset.x * shake * sin(trauma_time * 1.7),
				max_shake_offset.y * shake * sin(trauma_time * 2.3)
			)
	else:
		if camera != null and camera.offset != Vector2.ZERO:
			camera.offset = Vector2.ZERO


# Mobile lifecycle focus handler (Flaw 10)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			if is_game_active and not get_tree().paused:
				pause_game()


func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)


func _ensure_nodes() -> void:
	if player == null and has_node("Player"):
		player = $Player
	if mob_timer == null and has_node("MobTimer"):
		mob_timer = $MobTimer
	if score_timer == null and has_node("ScoreTimer"):
		score_timer = $ScoreTimer
	if start_timer == null and has_node("StartTimer"):
		start_timer = $StartTimer
	if start_position == null and has_node("StartPosition"):
		start_position = $StartPosition
	if mob_path == null and has_node("MobPath"):
		mob_path = $MobPath
	if mob_spawn_location == null and has_node("MobPath/MobSpawnLocation"):
		mob_spawn_location = $MobPath/MobSpawnLocation
	if hud == null and has_node("HUD"):
		hud = $HUD
	if music_player == null and has_node("Music"):
		music_player = $Music
	if death_sound == null and has_node("DeathSound"):
		death_sound = $DeathSound
	if camera == null and has_node("Camera2D"):
		camera = $Camera2D
	if mob_container == null and has_node("MobContainer"):
		mob_container = $MobContainer
	if game_over_ui == null and has_node("GameOver"):
		game_over_ui = $GameOver
	if pause_menu == null and has_node("PauseMenu"):
		pause_menu = $PauseMenu


func pause_game() -> void:
	if not is_game_active:
		return
	_ensure_nodes()
	if hud != null and hud.has_method("set_joystick_visible"):
		hud.set_joystick_visible(false)
	if player != null and player.has_method("set_joystick_vector"):
		player.set_joystick_vector(Vector2.ZERO)
	if pause_menu != null and pause_menu.has_method("pause_game"):
		pause_menu.pause_game()
	elif is_inside_tree():
		get_tree().paused = true


func _on_pause_menu_resume_requested() -> void:
	if is_game_active and hud != null and hud.has_method("set_joystick_visible"):
		hud.set_joystick_visible(true)


func _on_pause_menu_restart_requested() -> void:
	new_game()


func game_over() -> void:
	is_game_active = false
	_ensure_nodes()
	score_timer.stop()
	mob_timer.stop()
	music_player.stop()
	death_sound.play()
	add_trauma(0.8)
	
	if hud.has_method("set_pause_button_visible"):
		hud.set_pause_button_visible(false)
	if hud.has_method("set_joystick_visible"):
		hud.set_joystick_visible(false)
	if player != null and player.has_method("set_joystick_vector"):
		player.set_joystick_vector(Vector2.ZERO)

	# High score persistence (Flaw 8)
	if score > high_score:
		high_score = score
		SaveManager.save_high_score(high_score)

	# Unified Game Over presentation (Flaw 2)
	if game_over_ui != null:
		if game_over_ui.has_method("show_game_over"):
			game_over_ui.show_game_over(score, high_score)
		else:
			game_over_ui.show()


func _on_game_over_restart_requested() -> void:
	if game_over_ui != null:
		game_over_ui.hide()
	new_game()


func clear_mobs() -> void:
	_ensure_nodes()
	if mob_container != null:
		for mob in mob_container.get_children():
			mob.queue_free()
	# Defensive fallback for any node instanced outside container
	if is_inside_tree():
		get_tree().call_group("mobs", "queue_free")


func new_game() -> void:
	is_game_active = true
	_ensure_nodes()
	score = 0
	trauma = 0.0
	if camera != null:
		camera.offset = Vector2.ZERO
	if mob_timer != null:
		mob_timer.wait_time = 0.5

	if game_over_ui != null:
		game_over_ui.hide()
	if pause_menu != null and pause_menu.has_method("resume_game"):
		pause_menu.resume_game()

	clear_mobs()
	_configure_layout()
	player.start(start_position.position) 
	start_timer.start()
	hud.update_score(score)
	hud.show_message("Get Ready")
	if hud.has_method("set_pause_button_visible"):
		hud.set_pause_button_visible(true)
	if hud.has_method("set_joystick_visible"):
		hud.set_joystick_visible(true)
	music_player.play()


func _on_mob_timer_timeout() -> void:
	_ensure_nodes()
	print("Spawning Mob")
	
	#Creates a new instance of mob scene
	var mob := mob_scene.instantiate() as RigidBody2D
	
	# Choose a random location on path 2d
	mob_spawn_location.progress_ratio = randf()
	
	#Set the mob's position to random location
	mob.position = mob_spawn_location.global_position
	
	#Set the mob's direction perpendicular to the path direction 
	var direction: float = mob_spawn_location.rotation + PI / 2.0
	
	#Adding som randomness to the direction (Flaw 6 fixed: ±45 degrees range)
	direction += randf_range(-PI / 4.0, PI / 4.0)
	mob.rotation = direction
	
	#Dynamic velocity scaling based on progressive difficulty (Flaw 7)
	var speed_multiplier: float = 1.0 + minf(score * 0.015, 0.75)
	var speed: float = randf_range(150.0, 250.0) * speed_multiplier
	var velocity := Vector2(speed, 0.0) 
	mob.linear_velocity = velocity.rotated(direction)
	
	#Adding it to the dedicated MobContainer (Flaw 3)
	if mob_container != null:
		mob_container.add_child(mob)
	else:
		add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	hud.update_score(score)
	
	# Dynamic difficulty scaling for spawn interval (Flaw 7)
	# Gradually decreases from 0.5s down to 0.22s as score increases
	if mob_timer != null:
		mob_timer.wait_time = clampf(0.5 - (score * 0.006), 0.22, 0.5)


func _on_start_timer_timeout() -> void:
	mob_timer.start()
	score_timer.start()
