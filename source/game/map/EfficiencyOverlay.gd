extends TileMap
"""
Heatmap layer showing where efficiency is best
"""

onready var RED = tile_set.find_tile_by_name("red")
onready var ORANGE = tile_set.find_tile_by_name("orange")
onready var GREEN = tile_set.find_tile_by_name("green")


func _ready():
	for x in Global.get_map().size.x:
		for y in Global.get_map().size.y:
			set_cell(x, y, GREEN)


func generate(use_mouse: bool=false):
	for cell in get_used_cells():
		var real_position = cell * Global.TILE_SIZE + Global.get_rect_center(Vector2(1, 1))

		var efficiency = 0
		var storages = get_tree().get_nodes_in_group("Storage")
		for building in storages:
			efficiency = max(efficiency, building.compute_efficiency(real_position))

		if use_mouse:
			var storage = storages[0]
			var mouse_position = Global.get_map().snap_position(get_global_mouse_position()) + storage.get_center_position()

			efficiency = max(efficiency, storage._compute_efficiency(mouse_position, real_position))

		if efficiency > 0.75:
			set_cellv(cell, GREEN)
		elif efficiency > 0.50:
			set_cellv(cell, ORANGE)
		else:
			set_cellv(cell, RED)


