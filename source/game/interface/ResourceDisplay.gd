extends Control

export var resource_id : String = ""
export var hide_empty : bool = false

onready var icon = $Icon
onready var label = $Icon/ValueLabel


func _ready():
	assert(resource_id != "")
	assert(Global.resources.has(resource_id))

	icon.texture = Global.resources[resource_id].icon


func set_value(resources: Dictionary):
	assert(resources.has(resource_id))
	label.set_text(str(resources[resource_id]))

	if hide_empty:
		if resources[resource_id] == 0:
			hide()
	else:
		show()

	if resources[resource_id] > 0:
		show()
