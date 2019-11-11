extends Node
class_name Connector
"""
Handle a rail logic
"""

var tile := null		# Tile on which this connector is
# warning-ignore:unused_class_variable
var tiles setget , get_tiles
# warning-ignore:unused_class_variable
var connected_to_storage: bool = false


func get_tiles():
	return [tile]


func get_class():
	# Required because of ciclyc depandency not handled in GDScript
	return "Connector"


func _init(_tile: Tile):
	assert(_tile) # Assume all tiles have valid neighbors list

	tile = _tile
