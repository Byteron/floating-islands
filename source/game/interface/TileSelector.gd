extends Control
class_name TileSelector

signal tile_selected()

var selected_tile : Tile = null
var selected_cell := Vector2()

var size := Vector2(1, 1)
var map = null

static func instance():
	return load("res://source/game/interface/TileSelector.tscn").instance()

func _ready() -> void:
	for y in size.y:
		for x in size.x:
			var rect := ColorRect.new()
			rect.rect_size = Vector2(16, 16)
			rect.color = Color("8cffffff")
			rect.rect_position = Vector2(x, y) * Global.TILE_SIZE
			add_child(rect)

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
	rect_global_position = map.snap_position(get_global_mouse_position())
