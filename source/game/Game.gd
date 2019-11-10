extends Node2D

onready var map := $Map as Map
onready var interface := $Interface as Interface

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		print("click")
		var isle := map.get_isle(get_global_mouse_position())
		if isle:
			interface.highlight_lands(isle.tiles)

	if event.is_action_pressed("RMB"):
		interface.clear_highlights()

func place_construction(data: ConstructionData):
	var tile_selector := map.new_tile_selector()
	yield(tile_selector, "tile_selected")
	if tile_selector.selected_tile:
		map.add_contruction(tile_selector.selected_tile, data)
	map.remove_tile_selector()
	call_deferred("set_process_unhandled_input", true)
