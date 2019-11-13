extends Node2D

onready var player := $Player as Player

onready var map := $Map as Map
onready var interface := $Interface


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		var tiles := map.get_island_tiles(get_global_mouse_position())
		interface.highlight_lands(tiles)

	if event.is_action_pressed("cancel"):
		interface.clear_highlights()


func _ready() -> void:
	SFX.set_sfx_volume("FactoryLoop", 0)
	SFX.play_sfx("FactoryLoop")


func _process(_delta: float) -> void:
	_process_factory_loop_volume()


func _process_factory_loop_volume() -> void:
	var radius := 256 # 16 tiles
	var camera_position : Vector2 = Global.get_camera().global_position
	var volume := 0.0

	var miners := get_tree().get_nodes_in_group("Miner")
	for miner in miners:
		var distance = camera_position.distance_to(miner.global_position)
		var temp = clamp(0.6 - distance / radius, 0, 1)
		volume = max(volume, temp)

	SFX.set_sfx_volume("FactoryLoop", volume)


func disable_user_selection():
	"""
	Disable selection and camera move
	"""
	set_process_unhandled_input(false)
	get_tree().call_group("Tooltip", "hide")


func enable_user_selection():
	"""
	Enables selection and camera move
	"""
	call_deferred("set_process_unhandled_input", true)


func remove_construction():
	"""
	Handle selection of what to remove
	"""
	disable_user_selection()

	# Adds selection UI
	var tile_selector := map.new_tile_selector(Vector2(1, 1))

	yield(tile_selector, "tile_selected")

	# We can only select one thing to destroy at a time
	var tiles = tile_selector.selected_tiles
	var tile = null
	if tiles.size() > 0:
		tile = tiles[0]

	# Remove specific UI
	map.remove_tile_selector()

	enable_user_selection()

	# Check we destroyed something
	var data = map.remove_construction(tile)
	if not data:
		return

	var costs = {}
	for id in data.get_costs():
		costs[id] = player.refund_percentage * data.get_costs()[id]

	display_costs_popup(costs, false, tile.position * Global.TILE_SIZE, Global.get_rect_center(data.size))
	Global.get_player().refund(costs)

	SFX.play_sfx("Destroy")

	if Input.is_action_pressed("repeat"):
		remove_construction()


func place_construction(data: ConstructionData):
	"""
	Handle positioning of a specific construction
	Does the required check for possible contruction
	"""
	disable_user_selection()

	# Adds selection UI
	var tile_selector := map.new_tile_selector(data.size, data.is_connector)
	interface.highlight_connected_tiles(map.valid_construction_sites.values())

	yield(tile_selector, "tile_selected")

	var selected_tiles = tile_selector.selected_tiles
	var costs = data.get_costs()

	# Remove specific UI
	map.remove_tile_selector()
	interface.clear_highlights()

	enable_user_selection()

	for tile in selected_tiles:
		# Cannot build there or nothing selected
		if not tile or not map.is_area_available(tile.position, data.size, data.is_connector):
			continue

		# Not enough resources
		if not player.can_afford(costs):
			break	# Will not be able to buy following ones then

		display_costs_popup(costs, true, tile.position * Global.TILE_SIZE, Global.get_rect_center(data.size))
		assert(player.buy(costs))
		map.add_construction(tile, data)

		if data.id == "Rail":
			SFX.play_sfx("BuildRail")
		else:
			SFX.play_sfx("BuildBuilding")

	if Input.is_action_pressed("repeat"):
		place_construction(data)


func display_costs_popup(costs: Dictionary, loose: bool, position: Vector2, offset: Vector2=Vector2()) -> void:
	"""
	Display multiple costs at once
	loose: True if this is taken from Player, false is its added to player
	"""
	var local_offset = Vector2()
	for id in costs:
		var value = costs[id]
		if loose:
			value *= -1

		if value != 0:
			display_resource_popup(value, id, position, offset + local_offset)
			local_offset.y += 16


func display_resource_popup(value: int, resource_id: String, position: Vector2, offset: Vector2=Vector2()) -> void:
	"""
	Displays a popup showing production/consumption of resource slowly fadding away
	"""
	var popup := PopupLabel.instance() as PopupLabel
	popup.texture = Global.resources[resource_id].icon

	if value >= 0:
		popup.text = "+%d" % value
		popup.color = Color("00FF00")
		# TODO: Nothing to do here
		SFX.play_sfx("Mine")
	else:
		popup.text = "%d" % value
		popup.color = Color("FF0000")

	popup.rect_global_position = position + offset
	add_child(popup)
