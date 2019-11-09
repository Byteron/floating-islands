extends TileMap
class_name Map

# const
var LAND_INDEX := tile_set.find_tile_by_name("Land")
var VOID_INDEX := tile_set.find_tile_by_name("Void")

var tiles := {}

export var size := Vector2(40, 40)

export var noise_amplitude := 2
export var noise_shrink := 4
export(float, -1, 1) var noise_offset := -0.2

func _ready() -> void:
	_generate_tiles()
	_build_terrain()

func get_isle(world_position: Vector2) -> Isle:
	var cell = world_to_map(world_position)

	if not tiles.has(cell):
		return null

	var tile = tiles[cell]
	return tile.get_isle()

func _generate_tiles():
	randomize()

	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 20

	for y in size.y:
		for x in size.x:
			var cell := Vector2(x, y)
			var random_id := _get_random_index(x, y, noise, noise_shrink)

			var tile := Tile.new()
			tile.index = random_id
			tile.cell = cell
			tile.position = map_to_world(cell)

			if random_id == LAND_INDEX:
				tile.type = Tile.TYPE.LAND
			else:
				tile.type = Tile.TYPE.VOID

			tiles[cell] = tile

	_generate_neighbors()
	_remove_dwarve_isles()

func _remove_dwarve_isles():
	var visited := []
	for tile in tiles.values():
		if visited.has(tile) or tile.type != Tile.TYPE.LAND:
			continue

		var isle = tile.get_isle()

		for i_tile in isle.tiles:
			visited.append(i_tile)

		if isle.size < 7:
			for i_tile in isle.tiles:
				i_tile.type = Tile.TYPE.VOID
				i_tile.index = VOID_INDEX

func _generate_neighbors() -> void:
	for tile in tiles.values():
		var n_cells = get_neighbor_cells(tile.cell)
		var neighbors := []
		for n_cell in n_cells:
			if tiles.has(n_cell):
				neighbors.append(tiles[n_cell])
		tile.neighbors = neighbors

func get_neighbor_cells(cell: Vector2) -> Array:
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

func _get_random_index(x: int, y: int, noise: OpenSimplexNoise, factor: int) -> int:
	var value = noise.get_noise_2d(x * factor, y * factor) + noise_offset
	return LAND_INDEX if value * noise_amplitude > 0 else VOID_INDEX
