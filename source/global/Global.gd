extends Node

# warning-ignore:unused_class_variable
var TILE_SIZE: int = 16
var constructions := {}
var resources := {}


func _ready() -> void:
	_load_constructions()
	_load_resources()


func _load_constructions():
	constructions = _load_data("res://data/constructions/")


func _load_resources():
	resources = _load_data("res://data/resources/")


func _load_data(path: String) -> Dictionary:
	var files = Loader.load_dir(path, ["tres"])

	var data = {}
	for file in files:
		data[file.data.id] = file.data

	return data


func get_map():
	return get_tree().get_nodes_in_group("Map")[0]


func get_player():
	return get_tree().get_nodes_in_group("Player")[0]


func get_camera():
	return get_tree().get_nodes_in_group("Camera")[0]


func get_game():
	return get_tree().get_nodes_in_group("Game")[0]
