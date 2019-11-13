extends Building
class_name Storage
"""
Handle storage logic
"""

export var efficiency_radius: int = 8

var efficiency_area : Area2D


static func instance():
	return load("res://source/construction/buildings/Storage.tscn").instance()


func init(_data: ConstructionData, _tile: Tile, _tiles: Array):
	.init(_data, _tile, _tiles)

	efficiency_area = $EfficiencyArea
	var efficiency_shape = $EfficiencyArea/CollisionShape2D as CollisionShape2D
	efficiency_area.position = get_center_position()
	efficiency_shape.shape.radius = floor(efficiency_radius * Global.TILE_SIZE / 2.0)


func _process(_delta):
	# Impact efficiency of building in range
	for area in efficiency_area.get_overlapping_areas():
		var building = area.get_parent()
		if not building is Building:
			continue


		building.efficiency = 1.0
