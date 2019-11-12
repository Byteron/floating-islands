extends Control

var resource : ResourceData = null

onready var icon = $MarginContainer/Icon
onready var label = $ValueLabel


func set_resource(_resource: ResourceData):
	resource = _resource
	icon.texture = resource.icon


func set_value(value: int):
	label.set_text(str(value))
