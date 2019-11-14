extends Camera2D
class_name GameCam

var initial_camera_position := Vector2()
var initial_mouse_position := Vector2()

var viewport_extents := Vector2()
var player_has_control := true

export var speed := 2000


func _input(event: InputEvent) -> void:
	_handle_mouse(event)


func _ready() -> void:
	viewport_extents = get_viewport_rect().size / 2

	var limit_tolerance := Global.TILE_SIZE * 3
	limit_left = -limit_tolerance
	limit_top = -limit_tolerance
	limit_right = Global.get_map().get_extents().x + limit_tolerance
	limit_bottom = Global.get_map().get_extents().y + limit_tolerance


func _process(delta: float) -> void:
	_handle_keyboard_scroll(delta)


func _handle_keyboard_scroll(delta: float) -> void:
	if not player_has_control:
		return

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
	if not player_has_control:
		return

	if Input.is_action_pressed("grab_camera"):
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


func remove_limitation():
	"""
	Used so camera can go out of bounds
	"""
	limit_left = -10000
	limit_top = -10000
	limit_right = Global.get_map().get_extents().x + 10000
	limit_bottom = Global.get_map().get_extents().y + 10000
