extends Node
class_name Connector
"""
Handle a rail logic
"""

var adjacent_connectors := []
var tile := null		# Tile on which this connector is
# warning-ignore:unused_class_variable
var connected_to_storage: bool = false


func _init(_tile: Tile):
	assert(_tile) # Assume all tiles have valid neighbors list

	tile = _tile
	update_adjacent_connectors()


func update_adjacent_connectors():
	"""
	Update list of neighbor connectors
	"""
	adjacent_connectors = []
	for neighbor in tile.direct_neighbors:
		# Can't use "is Connector" in Connector :(
		if neighbor.construction and neighbor.construction.get_class() == "Connector":
			adjacent_connectors.append(neighbor)
			neighbor.update_adjacent_connectors()
