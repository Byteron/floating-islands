extends Control
class_name TileSelector

signal tile_selected()

onready var color_rect = $ColorRect

export (Color) var valid_color
export (Color) var invalid_color

var selected_tile : Tile = null
var selected_cell := Vector2()

var size := Vector2(1, 1)
var map = null
var is_void_valid = false


static func instance():
	return load("res://source/game/interface/TileSelector.tscn").instance()


func _ready() -> void:
	color_rect.rect_size = size * Global.TILE_SIZE


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tile = map.get_tile_from_world_position(get_global_mouse_position())
		if tile:
			selected_tile = tile
			emit_signal("tile_selected")
		else:
			var cell = map.world_to_map(get_global_mouse_position())
			selected_cell = cell
			emit_signal("tile_selected")

	elif event.is_action_pressed("RMB"):
		emit_signal("tile_selected")
	accept_event()


func _process(_delta: float) -> void:
	var cell = map.world_to_map(get_global_mouse_position())
	rect_global_position = map.snap_position(get_global_mouse_position())

	color_rect.color = invalid_color
	if map.is_area_available(cell, size, is_void_valid):
		color_rect.color = valid_color
