extends Construction
class_name Building
"""
Handle building logic
"""

onready var mine_timer := $MineTimer as Timer
onready var sprite := $Sprite as Sprite


static func instance():
	return load("res://source/construction/Building.tscn").instance()


func init(_data: ConstructionData, _tile: Tile, _tiles: Array):
	"""
	Expect construction data and list of tiles affected by this build
	"""
	self.tile = _tile
	self.tiles = _tiles
	self.data = _data

	name = data.name

	texture_active = data.texture

	if data.texture_inactive:
		texture_inactive = data.texture_inactive

	is_miner = data.is_miner
	miner_radius = data.miner_radius
	miner_amount = data.miner_mine_amount


func _ready():
	sprite.texture = data.texture
	sprite.offset = data.texture_offset

	if is_miner:
		mine_timer.start(data.miner_tick_time)

	add_to_group(data.id)


func mine() -> void:
	"""
	Try to gather resource around itslef
	"""
	if not connected_to_storage or not is_miner:
		return

	# Get target deposit
	var mining_on = null
	for tile in tiles:
		if tile.has_resource(data.target_resource):
			mining_on = tile
			break

		for n_tile in tile.neighbors:
			if n_tile.has_resource(data.target_resource):
				mining_on = n_tile
				break

	if mining_on:
		var mined : int = mining_on.mine(miner_amount)
		get_tree().call_group("Player", "add_resource", data.target_resource, mined)
		Global.get_game().display_resource_popup(
			mined, data.target_resource,
			global_position,
			data.size * Global.TILE_SIZE / 2
		)
	else:
		mine_timer.stop()


func _on_MineTimer_timeout() -> void:
	mine()


func _set_connected_to_storage(value: bool) -> void:
	._set_connected_to_storage(value)

	if value and texture_active:
		sprite.texture = texture_active
	elif not value and texture_inactive:
		sprite.texture = texture_inactive
