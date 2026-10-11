extends Area2D
signal hit #This defines a custom signal called "hit" that we will have our player emit (send out) when it collides with an enemy
@export var speed: int = 400 # Player move speed (pixel/sec) 
						# Using the export key word allows us to set the value in the inspector.
var screen_size: Vector2 # To Set Size of the Game Window 
var target_position: Vector2 = Vector2.ZERO
var is_touch_active: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var death_particles: CPUParticles2D = $DeathParticles

func _ready() -> void: #This funtion is called when a node enters the scene tree.
	screen_size = get_viewport_rect().size
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			target_position = event.position
			is_touch_active = true
		else:
			is_touch_active = false
	elif event is InputEventScreenDrag:
		target_position = event.position
		is_touch_active = true

func _process(delta: float) -> void: 
	 #Defines what a player does.Is called very frame 
	#The delta parameter in the _process() function refers to the frame length - the amount of time that the previous frame took to complete. 
	#Using this value ensures that your movement will remain consistent even if the frame rate changes.
	var velocity: Vector2 = Vector2.ZERO #The player's movement.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		is_touch_active = false
	elif is_touch_active:
		var diff: Vector2 = target_position - position
		if diff.length() > 10.0:
			velocity = diff.normalized() * speed
		else:
			velocity = Vector2.ZERO
	
	if velocity.length() > 0 :
		velocity = velocity.normalized() * speed
		animated_sprite.play()
	else:
		animated_sprite.stop()
		#$ is shorthand for get_node(). So in the code above, $AnimatedSprite2D.play() is the same as get_node("AnimatedSprite2D").play().
		#In GDScript, $ returns the node at the relative path from the current node, or returns null if the node is not found. 
		#Since AnimatedSprite2D is a child of the current node, we can use $AnimatedSprite2D.
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Motion juice: subtle dynamic squash and stretch while running
	var target_scale := Vector2(0.80, 0.70) if velocity.length() > 0 else Vector2(0.75, 0.75)
	animated_sprite.scale = animated_sprite.scale.lerp(target_scale, delta * 12.0)

	if velocity.x != 0:
		animated_sprite.animation = "walk"
		animated_sprite.flip_v = false
		animated_sprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		animated_sprite.animation = "up"
		animated_sprite.flip_v = false
		animated_sprite.flip_h = velocity.x < 0
		
		
func _on_body_entered(_body: Node2D) -> void:
	animated_sprite.hide() #player disappears after being hit 
	hit.emit()
	is_touch_active = false
	if death_particles != null:
		death_particles.restart()
		death_particles.emitting = true
	collision_shape.set_deferred("disabled", true)
func start(pos: Vector2) -> void:
	position = pos
	target_position = pos
	is_touch_active = false
	show()
	animated_sprite.show()
	collision_shape.disabled = false

	
	
