extends ColorRect
class_name TileSelectorRect
"""
Displays if the tile under it is valid placement or not
"""

export (Color) var valid_color
export (Color) var invalid_color

var placing_connector: bool = false
var cell: Vector2 setget set_cell
var offset: Vector2


static func instance():
	return load("res://source/game/interface/TileSelectorRect.tscn").instance()


func set_cell(value: Vector2):
	cell = value + offset
	rect_global_position = cell * Global.TILE_SIZE

	color = invalid_color
	if Global.get_map().is_area_available(cell, Vector2(1, 1), placing_connector, true):
		color = valid_color


func set_valid():
	color = valid_color


func set_invalid():
	color = invalid_color
