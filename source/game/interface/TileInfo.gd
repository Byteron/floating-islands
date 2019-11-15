extends PanelContainer
"""
Display deposit information on a tile
"""

var tile

onready var icon = $CenterContainer/Icon
onready var value_label = $CenterContainer/Value


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
	icon.texture = null
	value_label.text = ""

	if not tile:
		return

	icon.texture = Global.resources[tile.deposit.id].icon
	value_label.text = str(tile.deposit.amount)
