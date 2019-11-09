extends Node2D

onready var map := $Map as Map
onready var interface := $Interface as Interface

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		print("click")
		var isle := map.get_isle(get_global_mouse_position())
		if isle:
			print("Isle: ", isle)
			print("Tiles: ", isle.tiles)
			interface.highlight_lands(isle.tiles)

	if event.is_action_pressed("RMB"):
		interface.clear_highlights()
