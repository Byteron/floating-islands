extends Object
class_name Tile

enum TYPE { LAND, VOID }

var type := 0						# Type of terrain
var position : Vector2 = Vector2()	# Cell position in the tilemap
var island : Node = null			# Which island this belongs to

# warning-ignore:unused_class_variable
var resources : int = 0
# warning-ignore:unused_class_variable
var construction : Construction = null


func _init(_position: Vector2, _type, _island: Node):
	position = _position
	type = _type
	island = _island
