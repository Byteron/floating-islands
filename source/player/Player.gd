extends Node
class_name Player

var resources := 0 setget _set_resources

export var start_resources := 1000

func _ready() -> void:
	_set_resources(start_resources)

func _set_resources(value):
	resources = value
	get_tree().call_group("Interface", "update_player", self)
