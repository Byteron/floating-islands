extends Panel
"""
Displays building informations
"""

var building: Building

onready var efficiency_label = $MarginContainer/VBoxContainer/Efficiency
onready var description_label = $MarginContainer/VBoxContainer/Description


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
	if not building:
		return

	# Efficiency is given as a percentage fraction
	efficiency_label.text = "Efficiency: %.f%%" % (building.efficiency * 100)
	description_label.text = building.data.description
