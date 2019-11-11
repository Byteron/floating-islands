extends Node
class_name Connector
"""
Handle a rail logic
"""

var neighbors := []		# List of adjacent connectors
var tile := null		# Tile on which this connector is


func is_connected_to_storage() -> bool:
	# Check adjacent buildings
	if tile:
		for neighbor in tile.neighbors:
			if neighbor.construction and neighbor.construction.id == "Storage":
				return true

	# Check adjacent connectors
	for neighbor in neighbors:
		if neighbor.is_connected():
			return true

	return false
