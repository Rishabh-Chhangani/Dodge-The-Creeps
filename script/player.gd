extends Area2D
signal hit #This defines a custom signal called "hit" that we will have our player emit (send out) when it collides with an enemy
@export var speed = 400 # Player move speed (pixel/sec) 
						# Using the export key word allows us to set the value in the inspector.
var screen_size # To Set Size of the Game Window 

func _ready() -> void: #This funtion is called when a node enters the scene tree.
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):  #Defines what a player does.Is called very frame 
	#The delta parameter in the _process() function refers to the frame length - the amount of time that the previous frame took to complete. 
	#Using this value ensures that your movement will remain consistent even if the frame rate changes.
	var velocity = Vector2.ZERO #The player's movement.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0 :
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		#$ is shorthand for get_node(). So in the code above, $AnimatedSprite2D.play() is the same as get_node("AnimatedSprite2D").play().
		#In GDScript, $ returns the node at the relative path from the current node, or returns null if the node is not found. 
		#Since AnimatedSprite2D is a child of the current node, we can use $AnimatedSprite2D.
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
		
		
		
		
	


 


func _on_body_entered(_body: Node2D) -> void:
	hide() #player disappears after being hit 
	hit.emit()
	$CollisionShape2D.set_deferred("disable" , true)
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

	
	
