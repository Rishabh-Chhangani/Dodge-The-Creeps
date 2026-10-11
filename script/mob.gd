extends RigidBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var mob_type: String = ""
var base_velocity: Vector2 = Vector2.ZERO
var wave_time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animated_sprite == null:
		animated_sprite = $AnimatedSprite2D
	
	var mob_types: Array = Array(animated_sprite.sprite_frames.get_animation_names())
	mob_type = mob_types.pick_random()
	animated_sprite.animation = mob_type
	animated_sprite.play()

	# Differentiated mob behavior profiles
	match mob_type:
		"fly":
			# Flying creeps are fast, direct sprinters (+25% velocity)
			linear_velocity *= 1.25
			base_velocity = linear_velocity
		"swim":
			# Swimming creeps weave in a fluid sinusoidal motion
			base_velocity = linear_velocity
		"walk":
			# Walking creeps maintain steady baseline velocity
			base_velocity = linear_velocity


func _physics_process(delta: float) -> void:
	if mob_type == "swim" and base_velocity != Vector2.ZERO:
		wave_time += delta * 6.0
		var perpendicular := base_velocity.orthogonal().normalized()
		linear_velocity = base_velocity + perpendicular * (sin(wave_time) * 75.0)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
