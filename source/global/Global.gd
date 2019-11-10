extends Node

var TILE_SIZE: int = 16
var constructions := {}

func _ready() -> void:
	_load_constructions()

func _load_constructions():
	var files = Loader.load_dir("res://data/constructions/", ["tres"])

	for file in files:
		constructions[file.data.id] = file.data
