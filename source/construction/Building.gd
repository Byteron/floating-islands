extends Construction
class_name Building
"""
Handle building logic
"""

onready var mine_timer := $MineTimer as Timer
onready var sprite := $Sprite as Sprite
var hitbox : Area2D
var efficiency : float

export (float, 0, 1) var minimal_efficiency = 0.1


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

	hitbox = $Hitbox
	var collision_shape := $Hitbox/CollisionShape2D as CollisionShape2D
	hitbox.position = get_center_position()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.extents = get_center_position()

	texture_active = data.texture

	if data.texture_inactive:
		texture_inactive = data.texture_inactive

	is_miner = data.is_miner
	miner_radius = data.miner_radius
	miner_amount = data.miner_mine_amount

	update_efficiency()


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
		var mined : int = mining_on.mine(miner_amount * efficiency)
		get_tree().call_group("Player", "add_resource", data.target_resource, mined)
		Global.get_game().display_resource_popup(
			mined, data.target_resource,
			global_position,
			get_center_position()
		)
	else:
		mine_timer.stop()


func get_center_world_position() -> Vector2:
	"""
	Same as get_center_position but returns world coordinates
	"""
	return global_position + get_center_position()


func get_center_position() -> Vector2:
	"""
	Get the position of the center of this building
	"""
	return Global.get_rect_center(data.size)


func _on_MineTimer_timeout() -> void:
	mine()


func _set_connected_to_storage(value: bool) -> void:
	._set_connected_to_storage(value)

	if value and texture_active:
		sprite.texture = texture_active
	elif not value and texture_inactive:
		sprite.texture = texture_inactive


func _process(_delta):
	update_efficiency()


func update_efficiency():
	"""
	Compute efficiency based on nearly efficiency booster (like storage)
	"""
	efficiency = minimal_efficiency

	# Compute efficiency of this building
	for area in hitbox.get_overlapping_areas():
		var building = area.get_parent()
		if not building.has_method("compute_efficiency"):
			continue

		var new_efficiency = building.compute_efficiency(get_center_world_position())
		if new_efficiency > efficiency:
			efficiency = new_efficiency
