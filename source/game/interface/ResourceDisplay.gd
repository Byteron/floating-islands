extends Control

const POSITIVE_COLOR = Color("FFFFFF")
const NEGATIVE_COLOR = Color("FF0000")

export var resource_id : String = ""
export var hide_empty : bool = false

export var show_total := false

onready var icon = $Icon
onready var label = $ValueLabel


func _ready():
	assert(resource_id != "")
	assert(Global.resources.has(resource_id))

	icon.texture = Global.resources[resource_id].icon


func set_value(resources: Dictionary):
	assert(resources.has(resource_id))
	var value = resources[resource_id]

	if resource_id == "oil" and show_total:
		var total = Global.resources[resource_id].start_value
		for refinery in get_tree().get_nodes_in_group("Refinery"):
			total += refinery.mined
		label.text = "%d / %d" % [value, total]
	else:
		label.text = "%d" % value

	if value < 0:
		label.modulate = NEGATIVE_COLOR
	else:
		label.modulate = POSITIVE_COLOR

	if hide_empty:
		if resources[resource_id] == 0:
			hide()
	else:
		show()

	if resources[resource_id] > 0:
		show()
