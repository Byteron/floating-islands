extends Node2D
"""
Heatmap layer showing where efficiency is best
"""

export var color_gradient : Gradient


func _ready():
	for x in Global.get_map().size.x:
		for y in Global.get_map().size.y:
			var cell = load("res://source/game/map/EfficiencyArea.tscn").instance()
			cell.x = x
			cell.y = y
			add_child(cell)


func generate(use_mouse: bool=false):
	for cell in get_children():
		var cell_position = Vector2(cell.x, cell.y)
		var real_position = cell_position * Global.TILE_SIZE + Global.get_rect_center(Vector2(1, 1))

		var efficiency = 0
		var storages = get_tree().get_nodes_in_group("Storage")
		for building in storages:
			efficiency = max(efficiency, building.compute_efficiency(real_position))

		if use_mouse:
			var storage = storages[0]
			var mouse_position = Global.get_map().snap_position(get_global_mouse_position()) + storage.get_center_position()

			efficiency = max(efficiency, storage._compute_efficiency(mouse_position, real_position))

		cell.modulate = color_gradient.interpolate(efficiency)


