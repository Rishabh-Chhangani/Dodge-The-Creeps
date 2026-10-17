extends Control
class_name VirtualJoystick

signal joystick_moved(vector: Vector2)

@export var base_radius: float = 55.0
@export var tip_radius: float = 26.0
@export var deadzone: float = 0.08

var base_position: Vector2 = Vector2.ZERO
var tip_position: Vector2 = Vector2.ZERO
var default_position: Vector2 = Vector2.ZERO
var output_vector: Vector2 = Vector2.ZERO
var touch_id: int = -1
var is_active: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_default_position()
	get_viewport().size_changed.connect(_update_default_position)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		reset_joystick()


func _update_default_position() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	# Ergonomic bottom-left resting spot for mobile portrait & landscape
	default_position = Vector2(
		clampf(viewport_size.x * 0.22, 65.0, 130.0),
		viewport_size.y - clampf(viewport_size.y * 0.18, 90.0, 150.0)
	)
	if not is_active:
		base_position = default_position
		tip_position = default_position
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible or not is_inside_tree():
		return
	if get_tree().paused:
		if is_active:
			reset_joystick()
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started in the left/lower interactive steering zone
			if touch_id == -1 and event.position.x <= viewport_size.x * 0.65 and event.position.y >= viewport_size.y * 0.35:
				touch_id = event.index
				is_active = true
				base_position = Vector2(
					clampf(event.position.x, base_radius + 12.0, viewport_size.x * 0.65),
					clampf(event.position.y, viewport_size.y * 0.35, viewport_size.y - base_radius - 12.0)
				)
				tip_position = event.position
				_update_output()
				queue_redraw()
				get_viewport().set_input_as_handled()
		else:
			if event.index == touch_id:
				reset_joystick()
				get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		if event.index == touch_id:
			tip_position = event.position
			_update_output()
			queue_redraw()
			get_viewport().set_input_as_handled()

	# Mouse fallback for testing in Godot editor or desktop
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if touch_id == -1 and event.position.x <= viewport_size.x * 0.65 and event.position.y >= viewport_size.y * 0.35:
				touch_id = 999
				is_active = true
				base_position = event.position
				tip_position = event.position
				_update_output()
				queue_redraw()
		else:
			if touch_id == 999:
				reset_joystick()

	elif event is InputEventMouseMotion and touch_id == 999:
		tip_position = event.position
		_update_output()
		queue_redraw()


func _update_output() -> void:
	var diff: Vector2 = tip_position - base_position
	var dist: float = diff.length()
	
	if dist > base_radius:
		tip_position = base_position + diff.normalized() * base_radius
		dist = base_radius
	
	if dist / base_radius < deadzone:
		output_vector = Vector2.ZERO
	else:
		output_vector = (tip_position - base_position) / base_radius
	
	joystick_moved.emit(output_vector)


func reset_joystick() -> void:
	touch_id = -1
	is_active = false
	output_vector = Vector2.ZERO
	base_position = default_position
	tip_position = default_position
	joystick_moved.emit(Vector2.ZERO)
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	
	# Outer base circle (Minecraft / CODM semi-transparent style)
	var base_alpha: float = 0.45 if is_active else 0.25
	# Outer subtle shadow
	draw_circle(base_position, base_radius + 4.0, Color(0.0, 0.0, 0.0, base_alpha * 0.5))
	# Base disc
	draw_circle(base_position, base_radius, Color(0.12, 0.14, 0.20, base_alpha))
	# Outer ring border
	draw_arc(base_position, base_radius, 0.0, TAU, 36, Color(1.0, 1.0, 1.0, base_alpha * 0.8), 2.5, true)
	
	# Concentric guide ring
	draw_arc(base_position, base_radius * 0.5, 0.0, TAU, 24, Color(1.0, 1.0, 1.0, base_alpha * 0.3), 1.5, true)
	
	# Cardinal direction ticks (up, down, left, right)
	var tick_len: float = 6.0
	var col_tick := Color(1.0, 1.0, 1.0, base_alpha * 0.6)
	draw_line(base_position + Vector2(0, -base_radius + 2), base_position + Vector2(0, -base_radius + 2 + tick_len), col_tick, 2.0)
	draw_line(base_position + Vector2(0, base_radius - 2), base_position + Vector2(0, base_radius - 2 - tick_len), col_tick, 2.0)
	draw_line(base_position + Vector2(-base_radius + 2, 0), base_position + Vector2(-base_radius + 2 + tick_len, 0), col_tick, 2.0)
	draw_line(base_position + Vector2(base_radius - 2, 0), base_position + Vector2(base_radius - 2 - tick_len, 0), col_tick, 2.0)
	
	# Connecting stick line when pulled
	if is_active and tip_position != base_position:
		draw_line(base_position, tip_position, Color(1.0, 1.0, 1.0, 0.35), 3.0, true)
	
	# Inner thumbstick / knob
	var tip_alpha: float = 0.85 if is_active else 0.50
	# Shadow under knob
	draw_circle(tip_position + Vector2(0, 2), tip_radius, Color(0.0, 0.0, 0.0, tip_alpha * 0.4))
	# Knob disc
	draw_circle(tip_position, tip_radius, Color(0.85, 0.92, 1.0, tip_alpha))
	# Knob border
	draw_arc(tip_position, tip_radius, 0.0, TAU, 28, Color(1.0, 1.0, 1.0, tip_alpha), 2.0, true)
	# Center dot / grip
	draw_circle(tip_position, tip_radius * 0.32, Color(0.4, 0.6, 0.9, tip_alpha * 0.7))
