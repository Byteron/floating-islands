extends TileMap
class_name Map

signal loading_complete()

onready var BASIC_ALLOY_INDEX = $Resources.tile_set.find_tile_by_name("basic_alloy")
onready var SPECIAL_ALLOY_INDEX = $Resources.tile_set.find_tile_by_name("special_alloy")
var LAND_INDEX := tile_set.find_tile_by_name("Land")

var tiles := {}
var connectors := {}				# List of all rails
# warning-ignore:unused_class_variable
var valid_construction_sites := {}	# Where player is allowed to build
var spawn : Vector2					# Player spawn position

export var size = Vector2(64, 64)

export var basic_alloy_min := 200
export var basic_alloy_max := 8000
export var special_alloy_min_deposit_count : int = 40
export var special_alloy_amount_curve : Curve

# warning-ignore:unused_class_variable
export var resource_amplitude := 2
export var resource_shrink := 8
export(float, -1, 1) var resource_offset := -0.3

export (Resource) var IslandPacked
export (int) var island_count = 100
export (int) var max_island_offset = 10				# Offset for placing island
export (int) var min_island_size = 6
export (float) var process_time = 1					# Time given to physic engine to place islands

onready var rails_overlay := $Rails as TileMap
onready var resource_overlay := $Resources as TileMap
onready var island_bottom_overlay := $IslandBottom as TileMap
onready var buildings := $Buildings as Node2D
onready var islands := $Islands as Node2D

onready var RAIL_INDEX := rails_overlay.tile_set.find_tile_by_name("Rail")

func _ready() -> void:
	randomize()

	_place_islands()

	# Wait for physic engine to finish positioning islands
	yield(get_tree().create_timer(process_time), "timeout")

	_generate_islands()
	_generate_void()

	_generate_neighbors()
	_spawn_player()

	_generate_resources()

	_generate_island_bottom()
	emit_signal("loading_complete")


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

		islands.add_child(island)


func _generate_islands() -> void:
	"""
	Generate visual island representation in the tilemap
	"""
	for island in islands.get_children():
		# Remove out of bound islands
		var position = world_to_map(island.position)
		if not _is_cell_on_map(position):
			$Islands.remove_child(island)
			continue

		island.generate(self)

		# Remove small islands
		if island.size() < min_island_size:
			island.remove(self)
			islands.remove_child(island)


func _generate_void() -> void:
	"""
	Generate every possible tile not used
	"""
	for x in range(size.x):
		for y in range(size.y):
			var position = Vector2(x, y)
			if tiles.has(position):
				continue

			assert(create_tile(position, Tile.TYPE.VOID, null))


func _generate_resources():
	_generate_basic_alloy()
	_generate_special_alloy()


func _generate_basic_alloy():
	"""
	Add resource deposit randomly using simplex noise
	"""
	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 20

	for island in islands.get_children():
		for position in island.tiles_position:
			var tile = get_tile(position)
			if not tile:
				continue

			if not _should_have_basic_alloy(tile.position, noise, resource_shrink):
				continue

			assert(basic_alloy_min > 0) # Could create empty deposit otherwise
			tile.deposit.id = "basic_alloy"
			tile.deposit.amount = (randi() % (basic_alloy_max - basic_alloy_min)) + basic_alloy_min
			resource_overlay.set_cellv(tile.position, BASIC_ALLOY_INDEX)


func _generate_special_alloy():
	"""
	Add resource deposit using random land position far enough from start island
	deposit amount depends on distance from spawn
	"""
	var deposit_count = 0
	var loop_count = 0
	var max_trials = 10000
	while deposit_count < special_alloy_min_deposit_count and loop_count < max_trials:
		loop_count += 1

		var island = get_random_island()
		var position = island.get_random_tile_position()
		var tile = get_tile(position)

		assert(tile)

		# Distance from spawn
		var spawn_distance = tile.position.distance_to(spawn)

		tile.deposit.amount = floor(500 * special_alloy_amount_curve.interpolate(spawn_distance / size.x))
		if tile.deposit.amount <= 0:
			continue

		tile.deposit.id = "special_alloy"
		resource_overlay.set_cellv(tile.position, SPECIAL_ALLOY_INDEX)
		deposit_count += 1

	assert(deposit_count == special_alloy_min_deposit_count)


func _should_have_basic_alloy(cell: Vector2, noise: OpenSimplexNoise, factor: int) -> bool:
	"""
	Should the given cell have basic alloy on it?
	"""
	var value = noise.get_noise_2dv(cell * factor) + resource_offset
	return value * resource_amplitude > 0


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
		if not tile.is_surounded_by_land():
			continue

		add_construction(tile, Global.constructions["Storage"])
		spawn = tile.position

		Global.get_camera().set_global_position(start_island.global_position)
		break


func _generate_island_bottom():
	"""
	Adds cliffs under islands
	"""
	var cliff_index = island_bottom_overlay.tile_set.find_tile_by_name("Cliff")
	for position in get_used_cells():
		island_bottom_overlay.set_cellv(position, cliff_index)
		island_bottom_overlay.update_bitmask_area(position)


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


func _get_non_diagonal_construction_neighbor_cells(position: Vector2, data: ConstructionData) -> Array:
	var building_positions := []
	var corners := []
	var neighbors := []

	for y in data.size.y:
		for x in data.size.x:
			building_positions.append(position + Vector2(x, y))

	corners.append(position + Vector2(-1, -1))
	corners.append(position + Vector2(data.size.x, data.size.y))
	corners.append(position + Vector2(-1, data.size.y))
	corners.append(position + Vector2(data.size.x, -1))

	for y in range(-1, data.size.y + 1):
		for x in range(-1, data.size.x + 1):
			var cell = position + Vector2(x, y)
			if not building_positions.has(cell) and not corners.has(cell):
				neighbors.append(cell)
	return neighbors


func create_tile(position: Vector2, type, island: Node) -> bool:
	"""
	Adds a tile at the given location, replacing any existing one
	Returns true on success
	"""
	if not _is_cell_on_map(position):
		return false

	tiles[position] = Tile.new(position, type, island)
	tiles[position].connect("resource_depleted", self, "_on_Tile_resource_depleted")

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

	set_cellv(position, TileMap.INVALID_CELL)


func get_random_island() -> Island:
	return islands.get_children()[randi() % islands.get_child_count()]


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


func remove_construction(tile: Tile):
	"""
	Remove any construction on the given tile
	Returns removed ConstructionData or nothing if error or connector
	"""
	if not tile or not tile.construction:
		return

	var construction = tile.construction
	var data = construction.data

	# Cannot remove last storage
	if construction.data.is_storage:
		var storage_count = 0
		for building in buildings.get_children():
			if building.data.is_storage:
				storage_count += 1

		if storage_count <= 1:
			return

	# Add back the building tile positions to the valid building places
	for construction_tile in construction.tiles:
		construction_tile.construction = null

		# Check neighbor are still valid construction places
		for tile in construction_tile.direct_neighbors:
			if valid_construction_sites.has(tile.position) and not tile.is_adjacent_to_connector():
				var __ = valid_construction_sites.erase(tile.position)

		if construction_tile.is_adjacent_to_connector():
			valid_construction_sites[construction_tile.position] = construction_tile

	if construction is Building:
		_remove_building(construction)
	else:
		_remove_connector(tile)

	update_connections()

	return data


func add_construction(origin: Tile, data: ConstructionData) -> void:
	"""
	Adds a construction on the given tile
	"""
	# Gather all affected tiles
	var affected_tiles = []
	for y in data.size.y:
		for x in data.size.x:
			var position = origin.position + Vector2(x, y)
			var tile = get_tile(position)
			assert(tile)

			affected_tiles.append(tile)

	# Place the building
	var construction = null
	if data.is_connector:
		construction = _add_connector(origin, data)
	else:
		construction = _add_building(origin, affected_tiles, data)

	# Update tile constructions from building size
	for tile in affected_tiles:
		tile.construction = construction
		_add_rail(tile)

		# Remove that tile from possible constructions
		var __ = valid_construction_sites.erase(tile.position)

	update_connections()

	# bail when construction is placed, only rails should add builable tiles
	if not data.is_connector and not data.is_storage:
		return

	# Adds neighboring tiles to available construction places
	for tile in affected_tiles:
		for neighbor in tile.direct_neighbors:
			# If there is a building or a rail, cannot be built on
			var type = get_tile_type(neighbor.position)
			if type == Tile.TYPE.BUILDING or type == Tile.TYPE.CONNECTOR:
				continue

			valid_construction_sites[neighbor.position] = neighbor


func _add_connector(tile: Tile, data: ConstructionData) -> Connector:
	_add_rail(tile)

	var connector = Connector.new(data, tile)
	connectors[tile.position] = connector

	return connector


func _add_rail(tile: Tile) -> void:
	rails_overlay.set_cellv(tile.position, RAIL_INDEX)
	rails_overlay.update_bitmask_area(tile.position)


func _remove_rail(tile: Tile) -> void:
	rails_overlay.set_cellv(tile.position, TileMap.INVALID_CELL)
	rails_overlay.update_bitmask_area(tile.position)


func _remove_connector(tile: Tile):
	"""
	Remove a rail and update adjacent rails connections
	"""
	assert(tile.construction == null) # Tile status should be updated upfront

	rails_overlay.set_cellv(tile.position, TileMap.INVALID_CELL)
	rails_overlay.update_bitmask_area(tile.position)

	var __ = connectors.erase(tile.position)


func _add_building(origin: Tile, affected_tiles: Array, data: ConstructionData) -> Construction:

	var construction: Building = null
	if data.id == "Storage":
		construction = Storage.instance()
	else:
		construction = Building.instance()

	construction.init(data, origin, affected_tiles)
	buildings.add_child(construction)
	construction.global_position = origin.get_world_position()

	return construction


func _remove_building(construction: Construction):
	buildings.remove_child(construction)
	for tile in construction.tiles:
		_remove_rail(tile)
	construction.queue_free()


func update_connections():
	# Disconnects everybody
	for connector in connectors.values():
		connector.connected_to_storage = false

	for construction in buildings.get_children():
		construction.connected_to_storage = false

	# For every storage
	for construction in buildings.get_children():
		if not construction.get_id() == "Storage":
			continue

		construction.connected_to_storage = true
		_propagate_connection(construction)


func _propagate_connection(construction: Object):
	"""
	Propagate connected status to all neighbors of neighbors and so on
	"""
	for tile in construction.tiles:
		for neighbor in tile.direct_neighbors:
			if neighbor.construction:
				# Already processed
				if neighbor.construction.connected_to_storage:
					continue

				neighbor.construction.connected_to_storage = true
				if neighbor.construction is Connector:
					_propagate_connection(neighbor.construction)


func is_area_over_valid_site(position: Vector2, area_size: Vector2):
	"""
	Check if a valid site is in the given area
	"""
	for x in area_size.x:
		for y in area_size.y:
			if valid_construction_sites.has(position + Vector2(x, y)):
				return true

	return false


func is_area_available(position: Vector2, area_size: Vector2, is_void_valid: bool=false, skip_site_check: bool=false) -> bool:
	"""
	Tells wether or not player can build on given position
	"""
	var has_valid_construction_site = skip_site_check or is_area_over_valid_site(position, area_size)

	for x in area_size.x:
		for y in area_size.y:
			var type = get_tile_type(position + Vector2(x, y))
			if type == Tile.TYPE.VOID and not is_void_valid:
				return false
			if type == Tile.TYPE.CONNECTOR or type == Tile.TYPE.BUILDING or type == Tile.TYPE.INVALID:
				return false

	return has_valid_construction_site


func get_tile_type(position: Vector2) -> int:
	"""
	Give the type of entity at the given position (road, building, land, ...)
	"""
	# Check building and connector layer first
	var tile = get_tile(position)
	if not tile:
		return Tile.TYPE.INVALID

	if tile.construction:
		if tile.construction is Building:
			return Tile.TYPE.BUILDING
		else:
			return Tile.TYPE.CONNECTOR

	# Check connector layer
	# Should not be necessary, can be removed if performance is issue
	if rails_overlay.get_cellv(position) != TileMap.INVALID_CELL:
		return Tile.TYPE.CONNECTOR

	# Then resource layer
	if resource_overlay.get_cellv(position) == BASIC_ALLOY_INDEX:
		return Tile.TYPE.BASIC_ALLOY
	if resource_overlay.get_cellv(position) == SPECIAL_ALLOY_INDEX:
		return Tile.TYPE.SPECIAL_ALLOY

	# Lastly, terrain layer
	if get_cellv(position) == LAND_INDEX:
		return Tile.TYPE.LAND

	return Tile.TYPE.VOID


func get_extents() -> Vector2:
	"""
	World size of the map
	"""
	return size * Global.TILE_SIZE


func _is_cell_on_map(cell: Vector2) -> bool:
	return Rect2(Vector2(), size).has_point(cell)


func _on_Tile_resource_depleted(cell: Vector2) -> void:
	"""
	Remove the depleted resource from the map
	"""
	resource_overlay.set_cellv(cell, TileMap.INVALID_CELL)
