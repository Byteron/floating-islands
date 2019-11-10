extends Node2D

var min_island_radius := Global.TILE_SIZE * 2
var max_island_radius := Global.TILE_SIZE * 6


func _ready():
	var shape = CircleShape2D.new()
	shape.custom_solver_bias = 0.80
	# TODO: randi_range() does not exist?
	shape.radius = min_island_radius + (randi() % (max_island_radius - min_island_radius))
	$CollisionShape2D.shape = shape


func generate(map: TileMap) -> void:
	"""
	Generate tiles for the island inside its collider
	"""
	var radius = $CollisionShape2D.shape.radius
	var inner_radius = radius - Global.TILE_SIZE

	for x in range(radius * 2 / Global.TILE_SIZE):
		for y in range(radius * 2 / Global.TILE_SIZE):
			var local_position = -Vector2(radius, radius) + (Vector2(x, y) * Global.TILE_SIZE)
			if local_position.distance_to(Vector2()) > inner_radius:
				continue

			var world_position = position + local_position
			var cell_position = map.world_to_map(world_position)
			map.set_cellv(cell_position, map.LAND_INDEX)
			map.update_bitmask_area(cell_position)
