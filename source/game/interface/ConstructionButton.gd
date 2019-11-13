extends Button

onready var tooltip := $Pivot/Tooltip

var data : ConstructionData = null


func _ready() -> void:
	name = data.name
	text = data.name
	tooltip.set_costs(data.get_costs())


func show_tooltip():
	tooltip.show()


func hide_tooltip():
	tooltip.hide()
