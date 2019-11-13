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
	update_validity()


func update_validity(force_site_check=false):
	var ignore_valid_site = false

	if force_site_check:
		ignore_valid_site = false

	# If this is a connector but not the first, we ignore valid site check
	elif placing_connector:
		ignore_valid_site = offset != Vector2()

	# For a building, valid site was already computed
	else:
		ignore_valid_site = true

	color = invalid_color
	if Global.get_map().is_area_available(cell, Vector2(1, 1), placing_connector, ignore_valid_site):
		color = valid_color


func set_valid():
	color = valid_color


func set_invalid():
	color = invalid_color


func is_valid():
	return color == valid_color
