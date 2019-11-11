extends Control
"""
Shows tooltip at mouse position
"""

onready var label = $Label


func set_cost(value: int):
	label.text = str(-value)


func _input(event):
	# Follow mouse cursor
	rect_global_position = get_global_mouse_position()

	rect_global_position.x = clamp(rect_global_position.x, 0, ProjectSettings.get_setting("display/window/size/width") - rect_size.x)
	rect_global_position.y = clamp(rect_global_position.y, 0, ProjectSettings.get_setting("display/window/size/height") - rect_size.y)
