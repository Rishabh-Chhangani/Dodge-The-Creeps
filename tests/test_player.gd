extends RefCounted

## Unit and integration tests for Player state, touch inputs, and collision response.

static func run(runner) -> void:
	print("Running Player Tests...")
	var player_scene: PackedScene = load("res://Scene/player.tscn")
	var player = player_scene.instantiate()
	runner.root.add_child(player)
	
	runner.assert_eq(player.collision_layer, 1, "Player collision_layer is 1")
	runner.assert_eq(player.collision_mask, 2, "Player collision_mask is 2 (scans Mobs)")
	runner.assert_eq(player.speed, 400, "Default player speed is 400")
	
	# Test start lifecycle
	var spawn_pos := Vector2(120.0, 240.0)
	player.start(spawn_pos)
	runner.assert_eq(player.position, spawn_pos, "Player starts at designated coordinates")
	runner.assert_true(player.visible, "Player is visible after start()")
	runner.assert_true(not player.collision_shape.disabled, "Collision shape is active after start()")
	
	# Test touch drag input handling
	var touch_drag := InputEventScreenDrag.new()
	touch_drag.position = Vector2(300.0, 450.0)
	player._unhandled_input(touch_drag)
	runner.assert_true(player.is_touch_active, "Touch drag event activates touch mode")
	runner.assert_eq(player.target_position, Vector2(300.0, 450.0), "Target position updated by touch drag")
	
	# Test joystick movement integration
	player.set_joystick_vector(Vector2(1.0, 0.0))
	runner.assert_eq(player.joystick_vector, Vector2(1.0, 0.0), "Joystick vector updated")
	runner.assert_true(not player.is_touch_active, "Touch drag disabled when joystick vector active")
	player._process(0.016)
	runner.assert_true(player.position.x > spawn_pos.x, "Player moves in direction of joystick vector")
	runner.assert_eq(player.animated_sprite.animation, "walk", "Walk animation active when moving horizontally")
	player.set_joystick_vector(Vector2.ZERO)
	player._process(0.016)
	runner.assert_true(not player.animated_sprite.is_playing(), "Animated sprite stops when joystick is idle")

	# Test hit collision response
	player._on_body_entered(Node2D.new())
	await runner.process_frame
	runner.assert_true(player.collision_shape.disabled, "Collision shape deferred disabled on hit")
	runner.assert_true(not player.animated_sprite.visible, "Animated sprite hidden on hit")
	runner.assert_true(player.death_particles.emitting, "Death particles triggered on hit")
	runner.assert_eq(player.joystick_vector, Vector2.ZERO, "Joystick vector cleared on hit")
	
	player.queue_free()

	# Test HUD contains VirtualJoystick node
	var hud_scene: PackedScene = load("res://Scene/hud.tscn")
	var hud = hud_scene.instantiate()
	runner.root.add_child(hud)
	runner.assert_true(hud.has_node("VirtualJoystick"), "HUD contains VirtualJoystick node")
	runner.assert_true(hud.has_signal("joystick_moved"), "HUD emits joystick_moved signal")
	var joystick = hud.get_node("VirtualJoystick")
	runner.assert_eq(joystick.default_position.x, joystick.get_viewport_rect().size.x * 0.5, "Joystick is centered horizontally in middle of screen")
	hud.queue_free()
