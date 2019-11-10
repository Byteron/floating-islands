extends Node2D
class_name Construction

var miner_radius := 0
var miner_amount := 0

var is_miner := false
var tile = null # class Tile, cyclic dependency

onready var mine_timer := $MineTimer as Timer
onready var sprite := $Sprite as Sprite


static func instance():
	return load("res://source/construction/Construction.tscn").instance()


func initialize(data: ConstructionData, tile):
	self.tile = tile

	name = data.name
	sprite.texture = data.texture

	is_miner = data.is_miner
	miner_radius = data.miner_radius
	miner_amount = data.miner_mine_amount
	if is_miner:
		mine_timer.start(data.miner_tick_time)


func mine() -> void:
	if tile.has_resources():
		var mined : int = tile.mine(miner_amount)
		get_tree().call_group("Player", "add_resources", mined)
	else:
		mine_timer.stop()

func _on_MineTimer_timeout() -> void:
	mine()
