extends Node
class_name Player

var resources := 0

export var start_resources := 100

func _ready() -> void:
	resources = start_resources
