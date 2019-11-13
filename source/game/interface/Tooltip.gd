extends Control
"""
Shows tooltip at mouse position
"""

onready var basic_alloy_display = $HBoxContainer/basic_alloy
onready var special_alloy_display = $HBoxContainer/special_alloy


func set_costs(costs: Dictionary):
	basic_alloy_display.set_value(costs)
	special_alloy_display.set_value(costs)

