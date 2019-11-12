extends Construction
class_name Connector
"""
Handle a rail logic
"""

var tile := null		# Tile on which this connector is


func get_tiles():
	return [tile]


func _init(_data: ConstructionData, _tile: Tile):
	assert(_tile) # Assume all tiles have valid neighbors list

	data = _data
	print(data)
	tile = _tile
