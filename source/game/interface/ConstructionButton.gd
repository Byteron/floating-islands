extends Button

onready var tooltip := $CanvasLayer/Tooltip

var data : ConstructionData = null


func _ready() -> void:
	name = data.name
	text = data.name
	tooltip.set_cost(data.cost)


func show_tooltip():
	tooltip.show()


func hide_tooltip():
	tooltip.hide()
