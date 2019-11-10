extends Object
class_name Tile

signal resource_depleted(cell)

enum TYPE { LAND, VOID }

var type := 0

var index := 0
var position := Vector2()
var cell := Vector2()

var resources := 0

var construction : Construction = null

var neighbors := []

func get_isle() -> Isle:
	if type != TYPE.LAND:
		return null

	var isle := Isle.new()

	var tiles := []
	tiles.push_back(self)

	var visited := []
	visited.append(self)

	while not tiles.empty():
		var current = tiles.pop_back()
		for n in current.neighbors:
			if visited.has(n) or n.type != TYPE.LAND:
				continue
			tiles.push_back(n)
			visited.append(n)

	isle.tiles = visited
	return isle

func mine(amount: int) -> int:
	var prev = resources
	resources = clamp(resources - amount, 0, resources)

	if not has_resources():
		emit_signal("resource_depleted", cell)

	return prev - resources

func has_resources() -> bool:
	return resources > 0

func is_surrounded_by_land() -> bool:
	if neighbors.size() < 8:
		return false

	for n in neighbors:
		if n.type != TYPE.LAND:
			return false

	return true
