extends Object
class_name Isle

var size setget ,_get_size
var resource_count setget ,_get_resource_count

var tiles := []

func _get_size() -> int:
	return tiles.size()

func _get_resource_count() -> int:
	var count := 0
	for tile in tiles:
		count += tile.resources
	return count
