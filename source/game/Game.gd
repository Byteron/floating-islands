extends Node2D

onready var player := $Player as Player

onready var map := $Map as Map
onready var interface := $Interface as Interface

onready var camera := $GameCam as Camera2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tiles := map.get_island_tiles(get_global_mouse_position())
		interface.highlight_lands(tiles)

	if event.is_action_pressed("RMB"):
		interface.clear_highlights()


func place_construction(data: ConstructionData):
	interface.highlight_connected_tiles(map.connectors.values())

	var tile_selector := map.new_tile_selector()
	yield(tile_selector, "tile_selected")

	if tile_selector.selected_tile and not map.connectors.values().has(tile_selector.selected_tile):
		pass

	elif tile_selector.selected_tile and not tile_selector.selected_tile.construction:
		if tile_selector.selected_tile.type == Tile.TYPE.CONNECTOR and not data.is_connector:
			pass
		else:
			player.resources -= data.cost
			map.add_contruction(tile_selector.selected_tile, data)

	map.remove_tile_selector()
	interface.clear_highlights()
	call_deferred("set_process_unhandled_input", true)
