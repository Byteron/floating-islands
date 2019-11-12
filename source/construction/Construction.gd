extends Node2D
class_name Construction

var texture_active : Texture = null
var texture_inactive : Texture = null

var miner_radius := 0
var miner_amount := 0

var is_miner := false

var origin : Tile = null
var tiles: Array = []

var data: ConstructionData				# Construction data
var connected_to_storage: bool = false setget _set_connected_to_storage	# Does not produce until linked to a storage

onready var mine_timer := $MineTimer as Timer
onready var sprite := $Sprite as Sprite


static func instance():
	return load("res://source/construction/Construction.tscn").instance()


func initialize(_data: ConstructionData, _origin: Tile, _tiles: Array):
	"""
	Expect construction data and list of tiles affected by this build
	"""
	self.origin = _origin
	self.tiles = _tiles
	self.data = _data

	name = data.name

	texture_active = data.texture
	sprite.texture = data.texture

	if data.texture_inactive:
		texture_inactive = data.texture_inactive

	sprite.offset = data.texture_offset

	is_miner = data.is_miner
	miner_radius = data.miner_radius
	miner_amount = data.miner_mine_amount

	if is_miner:
		mine_timer.start(data.miner_tick_time)

	add_to_group(_data.id)

func get_id() -> String:
	return data.id


func mine() -> void:
	if not connected_to_storage:
		return

	# Get target deposit
	var mining_on = null
	for tile in tiles:
		if tile.has_resources():
			mining_on = tile
			break

		for n_tile in tile.neighbors:
			if n_tile.has_resources():
				mining_on = n_tile
				break

	if mining_on:
		var mined : int = mining_on.mine(miner_amount)
		get_tree().call_group("Player", "add_resources", mined)
		Global.get_game().display_resource_popup(mined, global_position)
	else:
		mine_timer.stop()


func _set_connected_to_storage(value: bool) -> void:
	connected_to_storage = value

	if value and texture_active:
		sprite.texture = texture_active
	elif not value and texture_inactive:
		sprite.texture = texture_inactive

func _on_MineTimer_timeout() -> void:
	mine()
