extends Node
class_name Connector
"""
Handle a rail logic
"""

var adjacent_connectors := []
var tile := null		# Tile on which this connector is


func _init(_tile: Tile):
	assert(_tile) # Assume all tiles have valid neighbors list

	tile = _tile
	update_adjacent_connectors()


func update_adjacent_connectors():
	"""
	Update list of neighbor connectors
	"""
	adjacent_connectors = []
	for neighbor in tile.neighbors:
		# Can't use "is Connector" in Connector :(
		if neighbor.construction and neighbor.construction.get_class() == "Connector":
			adjacent_connectors.append(neighbor)


func is_connected_to_storage() -> bool:
	# Check adjacent buildings
	for neighbor in tile.neighbors:
		if neighbor.construction and neighbor.construction.get_id() == "Storage":
			return true

	# Check adjacent connectors
	for connector in adjacent_connectors:
		if connector.is_connected_to_storage():
			return true

	return false
