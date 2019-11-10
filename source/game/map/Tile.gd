extends Object
class_name Tile

signal resource_depleted(cell)

enum TYPE { BUILDING, RESOURCE, LAND, VOID }

var type := 0						# Type of terrain
var position : Vector2 = Vector2()	# Cell position in the tilemap
var island : Node = null			# Which island this belongs to
var neighbors: Array = []			# List of adjacent tiles

# warning-ignore:unused_class_variable
var resources : int = 0
# warning-ignore:unused_class_variable
var construction : Construction = null


func _init(_position: Vector2, _type, _island: Node):
	position = _position
	type = _type
	island = _island


func mine(amount: int) -> int:
	var prev = resources
	resources = clamp(resources - amount, 0, resources)

	if not has_resources():
		emit_signal("resource_depleted", position)

	return prev - resources


func has_resources() -> bool:
	return resources > 0


func get_world_position():
	"""
	Give the tile position as world coordinates
	"""
	return position * Global.TILE_SIZE
