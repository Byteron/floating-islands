extends Control
"""
Shows tooltip at mouse position
"""

onready var basic_alloy_display = $HBoxContainer/basic_alloy
onready var special_alloy_display = $HBoxContainer/special_alloy


func set_costs(costs: Dictionary):
	basic_alloy_display.set_value(costs)
	special_alloy_display.set_value(costs)


func _input(_event):
	# Follow mouse cursor
	rect_global_position = get_global_mouse_position()

	rect_global_position.x = clamp(rect_global_position.x, 0, ProjectSettings.get_setting("display/window/size/width") - rect_size.x)
	rect_global_position.y = clamp(rect_global_position.y, 0, ProjectSettings.get_setting("display/window/size/height") - rect_size.y)
