extends Panel
"""
Display deposit information on a tile
"""

var tile

onready var icon = $MarginContainer/Icon
onready var value_label = $MarginContainer/Value


func _process(_delta):
	update_value()


func set_tile(value: Tile):
	"""
	Set tile to show informations
	"""
	tile = value


func update_value():
	"""
	Update displayed values
	"""
	if not tile:
		return

	icon.texture = Global.resources[tile.deposit.id].icon
	value_label.text = str(tile.deposit.amount)
