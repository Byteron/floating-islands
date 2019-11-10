extends Control
class_name TileSelector

signal tile_selected()

var selected_tile : Tile = null
var map = null

static func instance():
	return load("res://source/game/interface/TileSelector.tscn").instance()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tile = map.get_tile(get_global_mouse_position())
		if tile and tile.type == Tile.TYPE.LAND:
			selected_tile = tile
			print("Tile Selected: ", tile)
			emit_signal("tile_selected")

	elif event.is_action_pressed("RMB"):
		emit_signal("tile_selected")
	accept_event()

func _process(delta: float) -> void:
	rect_global_position = map.world_to_world(rect_global_position)
