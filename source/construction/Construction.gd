extends Node2D
class_name Construction

# warning-ignore:unused_class_variable
var texture_active : Texture = null
# warning-ignore:unused_class_variable
var texture_inactive : Texture = null

# warning-ignore:unused_class_variable
var miner_radius := 0
# warning-ignore:unused_class_variable
var miner_amount := 0

# warning-ignore:unused_class_variable
var is_miner := false
# warning-ignore:unused_class_variable
var tile : Tile = null		# Origin of this building
var tiles: Array = [] setget , get_tiles
var data: ConstructionData				# Construction data
var connected_to_storage: bool = false setget _set_connected_to_storage	# Does not produce until linked to a storage


func get_id() -> String:
	return data.id


func get_class():
	# Required because of ciclyc depandency not handled in GDScript
	return get_id()


func get_tiles():
	return tiles


func _set_connected_to_storage(value: bool) -> void:
	connected_to_storage = value
