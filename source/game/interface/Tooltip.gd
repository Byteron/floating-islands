extends Control
"""
Shows tooltip at mouse position
"""

onready var basic_alloy_display = $VBoxContainer/ResourceCost/basic_alloy
onready var special_alloy_display = $VBoxContainer/ResourceCost/special_alloy

onready var description_label = $VBoxContainer/BuildingDesc/Description
onready var icon = $VBoxContainer/BuildingDesc/Icon

func set_description(value: String):
	icon.texture = null

	var description = value
	for id in Global.resources:
		description = value.replace("%" + id, "")
		if value != description:
			icon.texture = Global.resources[id].icon
			break

	description_label.text = description


func set_costs(costs: Dictionary):
	basic_alloy_display.set_value(costs)
	special_alloy_display.set_value(costs)

