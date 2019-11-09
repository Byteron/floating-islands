extends Camera2D
class_name GameCam

var initial_camera_position := Vector2()
var initial_mouse_position := Vector2()

var viewport_extents := Vector2()

export var speed := 2000

func _input(event: InputEvent) -> void:
	_handle_mouse(event)

func _ready() -> void:
	viewport_extents = get_viewport_rect().size / 2

func _process(delta: float) -> void:
	_handle_keyboard_scroll(delta)

func _handle_keyboard_scroll(delta: float) -> void:
	var motion := Vector2()

	if Input.is_action_pressed("ui_up"):
		motion.y -= speed * delta / 2

	if Input.is_action_pressed("ui_down"):
		motion.y += speed * delta / 2

	if Input.is_action_pressed("ui_left"):
		motion.x -= speed * delta / 2

	if Input.is_action_pressed("ui_right"):
		motion.x += speed * delta / 2

	global_position.x = clamp(global_position.x + motion.x, limit_left + viewport_extents.x, limit_right - viewport_extents.x)
	global_position.y = clamp(global_position.y + motion.y, limit_top + viewport_extents.y, limit_bottom - viewport_extents.y)

func _handle_mouse(event: InputEvent) -> void:
	if Input.is_action_pressed("RMB"):
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()

		if not event is InputEventMouseMotion:
			initial_camera_position = global_position
			initial_mouse_position = mouse_pos

		# We multiply by -1 in order move the camera in the direction of the mouse.
		var new_position = initial_camera_position + (mouse_pos - initial_mouse_position) * -1 * zoom
		global_position.x = clamp(new_position.x, limit_left + viewport_extents.x, limit_right - viewport_extents.x)
		global_position.y = clamp(new_position.y, limit_top + viewport_extents.y, limit_bottom - viewport_extents.y)

func focus(world_position: Vector2) -> void:
	global_position = world_position
