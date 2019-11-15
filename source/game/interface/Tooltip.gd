extends Control
"""
Shows tooltip at mouse position
"""

onready var basic_alloy_display = $Container/ResourceCost/basic_alloy
onready var special_alloy_display = $Container/ResourceCost/special_alloy
onready var oil_display := $Container/ResourceCost/oil

onready var description_label = $Container/BuildingDesc/Description
onready var icon = $Container/BuildingDesc/Icon

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
	oil_display.set_value(costs)
