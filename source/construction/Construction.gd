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


func initialize(data: ConstructionData, _tile):
	self.tile = _tile

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
		_make_popup(mined)
	else:
		for n_tile in tile.neighbors:
			if n_tile.has_resources():
				var mined : int = n_tile.mine(miner_amount)
				get_tree().call_group("Player", "add_resources", mined)
				_make_popup(mined)
				return

		mine_timer.stop()

func _make_popup(value: int) -> void:
	var popup := PopupLabel.instance() as PopupLabel
	popup.text = "+%d" % value
	popup.color = Color("00FF00")
	popup.rect_global_position = global_position
	get_tree().current_scene.add_child(popup)

func _on_MineTimer_timeout() -> void:
	mine()
