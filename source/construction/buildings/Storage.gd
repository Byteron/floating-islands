extends Building
class_name Storage
"""
Handle storage logic
"""

export var efficiency_radius: int = 8
export var efficiency_curve: Curve

var efficiency_area : Area2D
var efficiency_shape : CollisionShape2D


static func instance():
	return load("res://source/construction/buildings/Storage.tscn").instance()


func init(_data: ConstructionData, _tile: Tile, _tiles: Array):
	.init(_data, _tile, _tiles)

	efficiency_area = $EfficiencyArea
	efficiency_shape = $EfficiencyArea/CollisionShape2D

	efficiency_area.position = get_center_position()
	efficiency_shape.shape.radius = floor(efficiency_radius * Global.TILE_SIZE / 2.0)


func compute_efficiency(building_position: Vector2) -> float:
	"""
	Given a building position, compute what would be its efficiency
	"""
	var max_distance = efficiency_shape.shape.radius + Global.TILE_SIZE
	var distance = get_center_world_position().distance_to(building_position)

	if distance > max_distance:
		return 0.0

	return efficiency_curve.interpolate(distance / max_distance)
