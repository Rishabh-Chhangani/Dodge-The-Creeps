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
	
	# Test hit collision response
	player._on_body_entered(Node2D.new())
	await runner.process_frame
	runner.assert_true(player.collision_shape.disabled, "Collision shape deferred disabled on hit")
	runner.assert_true(not player.animated_sprite.visible, "Animated sprite hidden on hit")
	runner.assert_true(player.death_particles.emitting, "Death particles triggered on hit")
	
	player.queue_free()
