extends Button
class_name ConstructionButton

var data : ConstructionData = null


func _ready() -> void:
	name = data.name
	text = data.name
