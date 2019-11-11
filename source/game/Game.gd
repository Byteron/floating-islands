extends Node2D

onready var player := $Player as Player

onready var map := $Map as Map
onready var interface := $Interface as Interface


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tiles := map.get_island_tiles(get_global_mouse_position())
		interface.highlight_lands(tiles)

	if event.is_action_pressed("RMB"):
		interface.clear_highlights()


func place_construction(data: ConstructionData):
	"""
	Handle positioning of a specific construction
	Does the required check for possible contruction
	"""
	# Adds selection UI
	var tile_selector := map.new_tile_selector(data.size)
	interface.highlight_connected_tiles(map.connectors.values())

	yield(tile_selector, "tile_selected")

	var tile = tile_selector.selected_tile

	# Remove specific UI
	map.remove_tile_selector()
	interface.clear_highlights()

	call_deferred("set_process_unhandled_input", true)

	# Cannot build there or nothing selected
	if not tile or not map.connectors.values().has(tile):
		return

	# Already occupied
	if tile.construction:
		return

	# Not enough resources
	if player.resources < data.cost:
		return

	# Cant build on top of building or connector or void
	var type = map.get_tile_type(tile.position)
	if type == Tile.TYPE.BUILDING or type == Tile.TYPE.CONNECTOR:
		return

	# No building on the void
	if not data.is_connector and type == Tile.TYPE.VOID:
		return

	player.resources -= data.cost
	map.add_contruction(tile_selector.selected_tile, data)

	if Input.is_action_pressed("shift"):
		set_process_unhandled_input(false)
		place_construction(data)
