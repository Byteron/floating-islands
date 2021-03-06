extends Panel
"""
Displays building informations
"""

var building: Building

onready var efficiency_label = $MarginContainer/Container/Efficiency
onready var description_label = $MarginContainer/Container/HBoxContainer/Description
onready var icon = $MarginContainer/Container/HBoxContainer/Icon


func _process(_delta):
	update_status()


func set_building(value: Building):
	"""
	Set building whose information will be displayed
	"""
	building = value


func update_status():
	"""
	Update displayed informations
	"""
	description_label.text = ""
	efficiency_label.text = ""
	icon.texture = null

	if not building:
		return

	# Efficiency is given as a percentage fraction
	efficiency_label.text = "Efficiency: %.f%%" % (building.efficiency * 100)

	var description = building.data.description
	for id in Global.resources:
		description = building.data.description.replace("%" + id, "")
		if building.data.description != description:
			icon.texture = Global.resources[id].icon
			break

	description_label.text = description
