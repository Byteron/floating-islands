extends Construction
class_name Connector
"""
Handle a rail logic
"""



func get_tiles():
	return [tile]


func _init(_data: ConstructionData, _tile: Tile):
	# assert(_tile) # Assume all tiles have valid neighbors list

	data = _data
	tile = _tile
