extends Button

onready var tooltip := $Tooltip

var data : ConstructionData = null


func _ready() -> void:
	name = data.name
	text = data.name
	tooltip.set_description(data.description)
	tooltip.set_costs(data.get_costs())


func show_tooltip():
	tooltip.show()


func hide_tooltip():
	tooltip.hide()
