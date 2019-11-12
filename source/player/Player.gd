extends Node
class_name Player

var resources := 0 setget _set_resources

export var start_resources := 1000
# warning-ignore:unused_class_variable
export(float, 0, 1) var refund_percentage := 0.75


func _ready() -> void:
	_set_resources(start_resources)


func add_resources(amount: int) -> void:
	_set_resources(resources + amount)


func _set_resources(value: int) -> void:
	resources = value
	get_tree().call_group("Interface", "update_player", self)
