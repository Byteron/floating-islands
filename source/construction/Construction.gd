extends Node2D
class_name Construction

var miner_radius := 0
var miner_amount := 0

var is_miner := false
var tiles: Array = []
var data: ConstructionData				# Construction data
var connected_to_storage: bool = false	# Does not produce until linked to a storage

onready var mine_timer := $MineTimer as Timer
onready var sprite := $Sprite as Sprite


static func instance():
	return load("res://source/construction/Construction.tscn").instance()


func initialize(_data: ConstructionData, _tiles: Array):
	"""
	Expect construction data and list of tiles affected by this build
	"""
	self.tiles = _tiles
	self.data = _data

	name = data.name
	sprite.texture = data.texture

	is_miner = data.is_miner
	miner_radius = data.miner_radius
	miner_amount = data.miner_mine_amount
	if is_miner:
		mine_timer.start(data.miner_tick_time)


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
		_make_popup(mined)
	else:
		mine_timer.stop()


func _make_popup(value: int) -> void:
	var popup := PopupLabel.instance() as PopupLabel
	popup.text = "+%d" % value
	popup.color = Color("00FF00")
	popup.rect_global_position = global_position
	get_tree().current_scene.add_child(popup)
	SFX.play_sfx("Mine")

func _on_MineTimer_timeout() -> void:
	mine()
