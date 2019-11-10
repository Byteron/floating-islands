extends Object
class_name Tile

enum TYPE { LAND, VOID }

var type := 0

var index := 0
var position := Vector2()
var cell := Vector2()

var resources := 0

var construction : Construction = null

var neighbors := []

func is_surrounded_by_land() -> bool:
	if neighbors.size() < 8:
		return false

	for n in neighbors:
		if n.type != TYPE.LAND:
			return false

	return true
