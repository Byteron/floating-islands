extends TileMap
class_name Map

const RES_INDEX := 0 # Is the index of the resource tile, as the tile set only has that one tile
var LAND_INDEX := tile_set.find_tile_by_name("Land")
var VOID_INDEX := tile_set.find_tile_by_name("Void")

var tile_selector : TileSelector = null

var tiles := {}
var connectors := {}				# List of all rails
# warning-ignore:unused_class_variable
var valid_construction_sites := {}	# Where player is allowed to build

export var size = Vector2(64, 64)

export var resource_min := 200
export var resource_max := 8000

# warning-ignore:unused_class_variable
export var resource_amplitude := 2
export var resource_shrink := 8
export(float, -1, 1) var resource_offset := -0.3

export (Resource) var IslandPacked
export (int) var island_count = 100
export (int) var max_island_offset = 10				# Offset for placing island
export (int) var min_island_size = 6
export (float) var process_time = 0.5				# Time given to physic engine to place islands

onready var rails_overlay := $Rails as TileMap
onready var resource_overlay := $Resources as TileMap
onready var construction_container := $ConstructionContainer as Node2D
onready var island_container := $Islands as Node2D


func _ready() -> void:
	randomize()

	_place_islands()

	# Wait for physic engine to finish positioning islands
	yield(get_tree().create_timer(process_time), "timeout")

	_generate_islands()
	_generate_void()
	_generate_resources()
	_generate_neighbors()
	_spawn_player()
	#_print_info()


func _place_islands() -> void:
	"""
	Adds islands with some random offset
	"""
	for id in range(island_count):
		var island = IslandPacked.instance()
		island.id = id
		island.position = (get_extents() / 2) + Vector2(
			-max_island_offset + randi() % (max_island_offset * 2),
			-max_island_offset + randi() % (max_island_offset * 2)
		)

		island_container.add_child(island)


func _generate_islands() -> void:
	"""
	Generate visual island representation in the tilemap
	"""
	for island in island_container.get_children():
		# Remove out of bound islands
		var position = world_to_map(island.position)
		if not Rect2(Vector2(), size).has_point(position):
			$Islands.remove_child(island)
			continue

		island.generate(self)

		# Remove small islands
		if island.size() < min_island_size:
			island.remove(self)
			island_container.remove_child(island)


func _generate_void() -> void:
	"""
	Generate every possible tile not used
	"""
	for x in range(size.x):
		for y in range(size.y):
			var position = Vector2(x, y)
			if tiles.has(position):
				continue

			if not create_tile(position, Tile.TYPE.VOID, null):
				print("mega meh")


func _generate_resources():
	"""
	Add resource deposit randomly using simplex noise
	"""
	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 20

	for island in island_container.get_children():
		for position in island.tiles_position:
			var tile = get_tile(position)
			if not tile:
				continue

			var idx = _get_resource_index(tile.position, noise, resource_shrink)
			if idx != RES_INDEX:
				continue

			assert(resource_min > 0) # Could create empty deposit otherwise
			tile.resources = (randi() % (resource_max - resource_min)) + resource_min
			resource_overlay.set_cellv(tile.position, RES_INDEX)
			tile.connect("resource_depleted", self, "_on_Tile_resource_depleted")


func _get_resource_index(cell: Vector2, noise: OpenSimplexNoise, factor: int) -> int:
	var value = noise.get_noise_2dv(cell * factor) + resource_offset
	return RES_INDEX if value * resource_amplitude > 0 else TileMap.INVALID_CELL


func _generate_neighbors() -> void:
	"""
	Pre-computation of the list of neighbors for every tile
	"""
	for tile in tiles.values():
		tile.neighbors = _get_tiles(_get_neighbor_cells(tile.position))
		tile.direct_neighbors = _get_tiles(_get_non_diagonal_neighbor_cells(tile.position))


func _spawn_player():
	"""
	Choose a starting island and adds a first building on it
	"""
	var start_island := get_random_island()

	# Otherwise, its possible to get an island with no plain tile in it
	assert(min_island_size >= 6)

	start_island.tiles_position.shuffle()
	for position in start_island.tiles_position:
		var tile = get_tile(position)
		if not tile:
			continue

		# Want a tile that is more or less central to that island
		if tile.neighbors.size() < 8:
			continue

		add_contruction(tile, Global.constructions["Storage"])

		Global.get_camera().set_global_position(start_island.global_position)
		break


func _get_tiles(positions: Array) -> Array:
	"""
	Get a list of tiles from an array of position
	"""
	var result = []

	for position in positions:
		var tile = get_tile(position)
		if tile:
			result.append(tile)

	return result


func _get_neighbor_cells(position: Vector2) -> Array:
	var neighbors := []
	neighbors.append(position + Vector2(+1, -1))
	neighbors.append(position + Vector2(+1, 0))
	neighbors.append(position + Vector2(+1, +1))
	neighbors.append(position + Vector2(0, +1))
	neighbors.append(position + Vector2(0, -1))
	neighbors.append(position + Vector2(-1, +1))
	neighbors.append(position + Vector2(-1, 0))
	neighbors.append(position + Vector2(-1, -1))
	return neighbors


func _get_non_diagonal_neighbor_cells(position: Vector2) -> Array:
	var neighbors := []
	neighbors.append(position + Vector2(+1, 0))
	neighbors.append(position + Vector2(0, +1))
	neighbors.append(position + Vector2(0, -1))
	neighbors.append(position + Vector2(-1, 0))
	return neighbors


func create_tile(position: Vector2, type, island: Node) -> bool:
	"""
	Adds a tile at the given location, replacing any existing one
	Returns true on success
	"""
	if not Rect2(Vector2(), size).has_point(position):
		return false

	tiles[position] = Tile.new(position, type, island)

	# TODO: Check given type to set correct tile type instead of hardcoded LAND_INDEX
	if type == Tile.TYPE.LAND:
		set_cellv(position, LAND_INDEX)
		update_bitmask_area(position)

	return true


func remove_tile(position: Vector2) -> void:
	"""
	Remove the tile at the given coordinates
	"""
	var __ = tiles.erase(position)

	set_cellv(position, VOID_INDEX)


func get_random_island() -> Island:
	return island_container.get_children()[randi() % island_container.get_child_count()]


func get_tile(position: Vector2) -> Tile:
	"""
	Get tile at the given tile coordinates
	"""
	if not tiles.has(position):
		return null

	return tiles[position]


func get_tile_from_world_position(position: Vector2) -> Tile:
	"""
	Get tile at the given world coordinates
	"""
	return get_tile(world_to_map(position))


func get_island(world_position: Vector2) -> Node:
	"""
	Get the island at the given world coordinates
	"""
	var tile = get_tile_from_world_position(world_position)
	if tile:
		return tile.island

	return null


func get_island_tiles(world_position: Vector2) -> Array:
	"""
	Get all tiles of the island at the given coordinates
	"""
	var island = get_island(world_position)
	if island:
		var tiles = []
		for position in island.tiles_position:
			var tile = get_tile(position)
			if tile:
				tiles.append(tile)

		return tiles

	return []


func snap_position(world_position: Vector2) -> Vector2:
	"""
	Given a world position, snaps to the closest tile and return as world position
	"""
	return map_to_world(world_to_map(world_position))


func new_tile_selector() -> TileSelector:
	remove_tile_selector()
	tile_selector = TileSelector.instance() as TileSelector
	tile_selector.map = self
	add_child(tile_selector)
	return tile_selector


func remove_tile_selector() -> void:
	if not tile_selector:
		return

	remove_child(tile_selector)
	tile_selector.queue_free()
	tile_selector = null


func add_contruction(tile: Tile, data: ConstructionData) -> void:
	"""
	Adds a construction on the given tile
	"""
	var construction = null
	if data.is_connector:
		construction = _add_connection(tile)
	else:
		construction = _add_building(tile, data)

	tile.construction = construction

	# Adds neighboring tiles to available construction places
	for neighbor in tile.direct_neighbors:
		# If there is a building or a rail, cannot be built on
		var type = get_tile_type(neighbor.position)
		if type == Tile.TYPE.BUILDING or type == Tile.TYPE.CONNECTOR:
			continue

		valid_construction_sites[neighbor.position] = neighbor

	# Remove that tile from possible constructions
	var __ = valid_construction_sites.erase(tile.position)

	update_connections()


func _add_connection(tile: Tile) -> Connector:
	rails_overlay.set_cellv(tile.position, 0)
	rails_overlay.update_bitmask_area(tile.position)

	var connector = Connector.new(tile)
	connectors[tile.position] = connector

	return connector


func _add_building(tile: Tile, data: ConstructionData) -> Construction:
	var construction = Construction.instance()
	construction_container.add_child(construction)
	construction.initialize(data, tile)
	construction.global_position = tile.get_world_position()

	return construction


func update_connections():
	# Disconnects everybody
	for connector in connectors.values():
		connector.connected_to_storage = false

	for construction in construction_container.get_children():
		construction.connected_to_storage = false

	# For every storage
	for construction in construction_container.get_children():
		if not construction.get_id() == "Storage":
			continue

		construction.connected_to_storage = true
		_propagate_connection(construction)


func _propagate_connection(construction: Object):
	"""
	Propagate connected status to all neighbors of neighbors and so on
	"""
	for neighbor in construction.tile.direct_neighbors:
		if neighbor.construction:
			# Already processed
			if neighbor.construction.connected_to_storage:
				continue

			neighbor.construction.connected_to_storage = true
			if neighbor.construction is Connector:
				_propagate_connection(neighbor.construction)


func get_tile_type(position: Vector2) -> int:
	"""
	Give the type of entity at the given position (road, building, land, ...)
	"""
	# Check building and connector layer first
	var tile = get_tile(position)
	if tile and tile.construction:
		if tile.construction is Construction:
			return Tile.TYPE.BUILDING
		else:
			return Tile.TYPE.CONNECTOR

	# Check connector layer
	# Should not be necessary, can be removed if performance is issue
	if rails_overlay.get_cellv(position) != TileMap.INVALID_CELL:
		return Tile.TYPE.CONNECTOR

	# Then resource layer
	if resource_overlay.get_cellv(position) == RES_INDEX:
		return Tile.TYPE.RESOURCE

	# Lastly, terrain layer
	if get_cellv(position) == LAND_INDEX:
		return Tile.TYPE.LAND

	return Tile.TYPE.VOID


func get_extents() -> Vector2:
	"""
	World size of the map
	"""
	return size * Global.TILE_SIZE


func _print_info():
	for island in island_container.get_children():
		print("Island %d -> Size: %d, Resources: %d" % [
			island.id,
			island.size(),
			island.get_resource_count(self)]
		)


func _on_Tile_resource_depleted(cell: Vector2) -> void:
	"""
	Remove the depleted resource from the map
	"""
	resource_overlay.set_cellv(cell, TileMap.INVALID_CELL)
