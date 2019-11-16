extends Construction
class_name Building
"""
Handle building logic
"""

onready var mine_timer := $MineTimer as Timer
onready var sprite := $Sprite as Sprite

var hitbox : Area2D
var efficiency : float

var mined := 0

var mining_on = true

var active := true setget _set_active

var constant_resource_miner := false

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

	if is_miner and data.miner_tick_time:
		mine_timer.start(data.miner_tick_time)
	elif not data.miner_tick_time:
		constant_resource_miner = true
	add_to_group(data.id)

	if constant_resource_miner:
		call_deferred("mine")

func cleanup():
	if constant_resource_miner and mined:
		get_tree().call_group("Player", "use_resource", data.target_resource, mined, constant_resource_miner)
		Global.get_game().display_resource_popup(
			-mined, data.target_resource,
			global_position,
			get_center_position()
		)

func mine() -> void:
	"""
	Try to gather resource around itslef
	"""
	if not connected_to_storage or not is_miner:
		return

	if _mine_const():
		return

	# Get target deposit
	mining_on = null
	for tile in tiles:
		if tile.has_resource(data.target_resource):
			mining_on = tile
			break

		for n_tile in tile.neighbors:
			if n_tile.has_resource(data.target_resource):
				mining_on = n_tile
				break

	if mining_on:
		mined = mining_on.mine(miner_amount * efficiency)
		get_tree().call_group("Player", "add_resource", data.target_resource, mined)
		Global.get_game().display_resource_popup(
			mined, data.target_resource,
			global_position,
			get_center_position()
		)
	else:
		mine_timer.stop()
		_set_active(false)
		SFX.play_sfx("DeactivateBuilding")

func _mine_const() -> bool:
	if not constant_resource_miner:
		return false

	var visited := tiles.duplicate()

	var count := 0

	for tile in tiles:
		if tile.has_resource(data.target_resource):
			count += 1

		for n_tile in tile.neighbors:
			if visited.has(n_tile):
				continue
			visited.append(n_tile)
			if n_tile.has_resource(data.target_resource):
				count += 1

	print("Count: %d" % count)
	mined = miner_amount * count
	get_tree().call_group("Player", "add_resource", data.target_resource, mined)
	Global.get_game().display_resource_popup(
		mined, data.target_resource,
		global_position,
		get_center_position()
	)
	return constant_resource_miner

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
	_set_active(value and mining_on != null)


func _process(_delta):
	update_efficiency()


func update_efficiency():
	"""
	Compute efficiency based on nearly efficiency booster (like storage)
	"""
	if not connected_to_storage:
		efficiency = 0
		return

	efficiency = minimal_efficiency

	# Compute efficiency of this building
	for area in hitbox.get_overlapping_areas():
		var building = area.get_parent()
		if not building.has_method("compute_efficiency"):
			continue

		var new_efficiency = building.compute_efficiency(get_center_world_position())
		if new_efficiency > efficiency:
			efficiency = new_efficiency


func _set_active(value: bool) -> void:
	active = value

	if value and texture_active:
		sprite.texture = texture_active
	elif not value and texture_inactive:
		sprite.texture = texture_inactive
