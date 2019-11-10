extends TileMap
class_name Map

const RES_INDEX := 0 # Is the index of the resource tile, as the tile set only has that one tile
var LAND_INDEX := tile_set.find_tile_by_name("Land")
var VOID_INDEX := tile_set.find_tile_by_name("Void")

var tile_selector : TileSelector = null

var tiles := {}
var isles := []

export var size := Vector2(40, 40)
export var min_isle_size := 7

# warning-ignore:unused_class_variable
export var noise_amplitude := 2
export var noise_shrink := 4
export(float, -1, 1) var noise_offset := -0.2

export var resource_min := 200
export var resource_max := 8000

export var resource_amplitude := 2
export var resource_shrink := 8
export(float, -1, 1) var resource_offset := -0.3

onready var resource_overlay := $Resources as TileMap

onready var construction_container := $ConstructionContainer as Node2D

export (Resource) var IslandPacked
export (int) var island_count = 100
export (int) var max_island_offset = 10				# Offset for placing island collider


func _ready() -> void:
	randomize()
	generate_islands()


func generate_islands() -> void:
	for __ in range(island_count):
		var island = IslandPacked.instance()
		island.position = Vector2(
			-max_island_offset + randi() % (max_island_offset * 2),
			-max_island_offset + randi() % (max_island_offset * 2)
		)

		$Islands.add_child(island)

	# Wait for physic engine to finish
	yield(get_tree().create_timer(1.0), "timeout")

	# Generate each island
	for island in $Islands.get_children():
		island.generate(self)


func world_to_world(world_position: Vector2) -> Vector2:
	return map_to_world(world_to_map(world_position))

func world_to_world_centered(world_position: Vector2) -> Vector2:
	return world_to_world(world_position) + cell_size / 2

func map_to_world_centered(cell: Vector2) -> Vector2:
	return map_to_world(cell) + cell_size / 2

func get_tile(world_position: Vector2) -> Tile:
	var cell = world_to_map(world_position)

	if not tiles.has(cell):
		return null

	return tiles[cell]

func new_tile_selector() -> TileSelector:
	remove_tile_selector()
	tile_selector = TileSelector.instance() as TileSelector
	tile_selector.map = self
	add_child(tile_selector)
	print("Selector Added")
	return tile_selector

func remove_tile_selector() -> void:

	if not tile_selector:
		return

	remove_child(tile_selector)
	tile_selector.queue_free()
	tile_selector = null
	print("Selector Removed")

func add_contruction(tile: Tile, data: ConstructionData) -> void:

	var construction = Construction.instance()
	construction_container.add_child(construction)
	construction.initialize(data)
	construction.global_position = tile.position + cell_size / 2

	tile.construction = construction
	print("Contruction Placed")

func _generate_tiles():
	randomize()

	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 20

	for y in size.y:
		for x in size.x:
			var cell := Vector2(x, y)
			var terrain_id := _get_terrain_index(x, y, noise, noise_shrink)

			var tile := Tile.new()
			tile.index = terrain_id
			tile.cell = cell
			tile.position = map_to_world(cell)

			if terrain_id == LAND_INDEX:
				tile.type = Tile.TYPE.LAND
			else:
				tile.type = Tile.TYPE.VOID

			tiles[cell] = tile

func _generate_neighbors() -> void:
	for tile in tiles.values():
		var n_cells = _get_neighbor_cells(tile.cell)
		var neighbors := []
		for n_cell in n_cells:
			if tiles.has(n_cell):
				neighbors.append(tiles[n_cell])
		tile.neighbors = neighbors

func _remove_dwarve_isles():
	for tile in tiles.values():
		if tile.type != Tile.TYPE.LAND:
			continue

		var visited := false
		for isle in isles:
			if isle.tiles.has(tile):
				visited = true

		if visited:
			continue

		var isle = tile.get_isle()

		if isle.size < min_isle_size:
			for i_tile in isle.tiles:
				i_tile.type = Tile.TYPE.VOID
				i_tile.index = VOID_INDEX
		else:
			isles.append(isle)

func _generate_resources():
	randomize()

	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 20

	for isle in isles:
		for tile in isle.tiles:
			var value = noise.get_noise_2dv(tile.cell)
			var idx = _get_resource_index(tile.cell, noise, resource_shrink)
			if idx == RES_INDEX:
				tile.resources = (randi() % (resource_max - resource_min)) + resource_min

func _get_neighbor_cells(cell: Vector2) -> Array:
	var neighbors := []
	neighbors.append(cell + Vector2(+1, -1))
	neighbors.append(cell + Vector2(+1, 0))
	neighbors.append(cell + Vector2(+1, +1))
	neighbors.append(cell + Vector2(0, +1))
	neighbors.append(cell + Vector2(0, -1))
	neighbors.append(cell + Vector2(-1, +1))
	neighbors.append(cell + Vector2(-1, 0))
	neighbors.append(cell + Vector2(-1, -1))
	return neighbors

func _build_terrain():
	for tile in tiles.values():
		set_cellv(tile.cell, tile.index)
		update_bitmask_area(tile.cell)

		if tile.resources:
			resource_overlay.set_cellv(tile.cell, RES_INDEX)

func _print_info():
	var idx := 1
	for isle in isles:
		print("Isle %d -> Size: %d, Resources: %d" % [idx, isle.size, isle.resource_count])
		idx += 1

func _get_terrain_index(x: int, y: int, noise: OpenSimplexNoise, factor: int) -> int:
	var value = noise.get_noise_2d(x * factor, y * factor) + noise_offset
	return LAND_INDEX if value * noise_amplitude > 0 else VOID_INDEX

func _get_resource_index(cell: Vector2, noise: OpenSimplexNoise, factor: int) -> int:
	var value = noise.get_noise_2dv(cell * factor) + resource_offset
	return RES_INDEX if value * resource_amplitude > 0 else TileMap.INVALID_CELL
