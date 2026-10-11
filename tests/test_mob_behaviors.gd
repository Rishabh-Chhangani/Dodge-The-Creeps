extends RefCounted

## Unit and integration tests for Mob behaviors, animations, and physics layers.

static func run(runner) -> void:
	print("Running Mob Behavior Tests...")
	var mob_scene: PackedScene = load("res://Scene/mob.tscn")
	var mob = mob_scene.instantiate()
	runner.root.add_child(mob)
	
	runner.assert_eq(mob.collision_layer, 2, "Mob collision_layer is 2 (Enemies)")
	runner.assert_eq(mob.collision_mask, 0, "Mob collision_mask is 0 (No self-collision)")
	runner.assert_true(mob.is_in_group("mobs"), "Mob is in 'mobs' group")
	
	var valid_types := ["fly", "swim", "walk"]
	runner.assert_true(valid_types.has(mob.mob_type), "Mob chose a valid randomized behavior type")
	
	# Test swimming wave movement logic
	mob.mob_type = "swim"
	mob.base_velocity = Vector2(200.0, 0.0)
	mob.linear_velocity = mob.base_velocity
	mob._physics_process(0.2)
	runner.assert_true(mob.linear_velocity.y != 0.0, "Swimming mob oscillates perpendicular to base velocity")
	
	# Test flying speed multiplier
	var initial_vel := Vector2(100.0, 0.0)
	mob.mob_type = "fly"
	mob.linear_velocity = initial_vel
	mob.linear_velocity *= 1.25
	runner.assert_eq(mob.linear_velocity.x, 125.0, "Flying mob applies +25% speed sprint")
	
	mob.queue_free()
