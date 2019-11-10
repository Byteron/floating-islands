extends Node

# warning-ignore:unused_class_variable
var TILE_SIZE: int = 16
var constructions := {}

func _ready() -> void:
	_load_constructions()


func _load_constructions():
	var files = Loader.load_dir("res://data/constructions/", ["tres"])

	for file in files:
		constructions[file.data.id] = file.data


func get_map():
	return get_tree().get_nodes_in_group("map")[0]


func get_camera():
	return get_tree().get_nodes_in_group("camera")[0]
