extends Node2D

var min_island_radius := Global.TILE_SIZE * 2
var max_island_radius := Global.TILE_SIZE * 6

# warning-ignore:unused_class_variable
var id: int = -1
var tiles_position: Array = []		# Array of all position used by this island


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

	# Smaller radius is used to ensure there is a gap between islands
	var inner_radius = radius - Global.TILE_SIZE

	for x in range(radius * 2 / Global.TILE_SIZE):
		for y in range(radius * 2 / Global.TILE_SIZE):
			var local_position = -Vector2(radius, radius) + (Vector2(x, y) * Global.TILE_SIZE)
			if local_position.length() > inner_radius:
				continue

			var world_position = position + local_position
			var cell_position = map.world_to_map(world_position)

			map.create_tile(cell_position, Tile.TYPE.LAND, self)
			tiles_position.append(cell_position)


func remove(map: TileMap):
	"""
	Remove the island from the tilemap
	"""
	for position in tiles_position:
		map.remove_tile(position)


func size():
	return tiles_position.size()


func get_resource_count(map: TileMap) -> int:
	"""
	Compute total of resource on this island
	"""
	var count := 0
	for position in tiles_position:
		var tile = map.get_tile(position)
		if tile:
			count += tile.resources

	return count
