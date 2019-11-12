extends Object
class_name Tile

signal resource_depleted(cell)

enum TYPE { BUILDING, RESOURCE, LAND, VOID, CONNECTOR }

var type := 0						# Type of terrain
var position : Vector2 = Vector2()	# Cell position in the tilemap
var island : Node = null			# Which island this belongs to
# warning-ignore:unused_class_variable
var neighbors: Array = []			# List of adjacent tiles
# warning-ignore:unused_class_variable
var direct_neighbors: Array = []	# List of adjacent tiles (but not diagonaly)

# warning-ignore:unused_class_variable
var construction : Object = null

var deposit : Dictionary = {
	"id": "",
	"amount": 0
}


func _init(_position: Vector2, _type, _island: Node):
	position = _position
	type = _type
	island = _island


func mine(amount: int) -> int:
	"""
	Try to remove the given amount of resource.
	Return how many are removed
	"""
	var mined_amount = max(amount - deposit.amount, amount)
	deposit.amount = max(deposit.amount - amount, 0)

	if is_depleted():
		emit_signal("resource_depleted", position)

	return mined_amount


func has_resource(id: String):
	"""
	Check for given resource type on this tile
	"""
	return deposit.id == id and not is_depleted()


func is_depleted() -> bool:
	return deposit.amount <= 0


func get_world_position():
	"""
	Give the tile position as world coordinates
	"""
	return position * Global.TILE_SIZE


func has_connector() -> bool:
	"""
	Check that a connector is on that tile
	"""
	if construction:
		return construction.get_class() == "Connector" or construction.get_class() == "Storage"

	return false


func is_adjacent_to_connector() -> bool:
	"""
	Check this has some connector next to it
	"""
	for tile in direct_neighbors:
		if tile.has_connector():
			return true

	return false
