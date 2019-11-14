extends Node2D

export var lightning_particle : Resource
export var miner_sfx_radius := 180
export var miner_sfx_max_volume := 0.2

onready var player := $Player as Player

onready var map := $Map as Map
onready var interface := $Interface


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		var cell = map.world_to_map(get_global_mouse_position())
		select_tile(cell)

	elif event.is_action_pressed("cancel"):
		interface.clear_selection()

	if Input.is_action_just_pressed("toggle_building_mode"):
		interface.open_build_menu()
	elif Input.is_action_just_pressed("destruction_mode"):
		interface.enter_destruction_mode()


func _ready() -> void:
	SFX.set_sfx_volume("FactoryLoop", 0)
	SFX.play_sfx("FactoryLoop")

	var __ = map.connect("loading_complete", $LoadingScreen, "_on_level_loaded")
	__ = map.connect("construction_complete", self, "_on_construction_complete")


func _process(_delta: float) -> void:
	_process_factory_loop_volume()


func select_tile(cell: Vector2):
	"""
	Display informations about the selected tile
	If building, shows building information
	If resource under it, shows that too
	"""
	var tile = map.get_tile(cell)
	if not tile:
		return

	var highlightings = [ tile ]

	var construction = null
	var deposit = null
	if tile.construction and tile.construction is Building:
		construction = tile.construction
		highlightings = tile.construction.tiles

	if not tile.is_depleted():
		deposit = tile

	if not deposit and not construction:
		interface.hide_building_status()
		interface.hide_tile_info()

	else:
		if deposit:
			interface.show_tile_info(tile)
		else:
			interface.show_tile_info(null)

		if construction:
			interface.show_building_status(construction)
		else:
			interface.show_building_status(null)

	interface.highlight_tiles(highlightings)


func _process_factory_loop_volume() -> void:
	var camera_position : Vector2 = Global.get_camera().global_position
	var volume := 0.0

	var miners := get_tree().get_nodes_in_group("Miner")
	var refineries := get_tree().get_nodes_in_group("Refinery")

	for building in miners + refineries:
		var distance = camera_position.distance_to(building.global_position)
		var temp = clamp(1 - distance / miner_sfx_radius, 0, 1)
		volume = max(volume, temp)

	SFX.set_sfx_volume("FactoryLoop", volume * miner_sfx_max_volume)


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
	$Interface/HUD/ConstructionButtons/SlidingMenu/RemoveButton.pressed = true

	disable_user_selection()

	# Adds selection UI
	var tile_selector : TileSelector = interface.show_tile_selector(null)

	yield(tile_selector, "tile_selected")

	# Remove specific UI
	interface.hide_tile_selector()

	# We can only select one thing to destroy at a time
	for tile in tile_selector.selected_tiles:
		# Check we destroyed something
		var data = map.remove_construction(tile)
		if not data:
			continue

		var costs = {}
		for id in data.get_costs():
			costs[id] = player.refund_percentage * data.get_costs()[id]

		display_costs_popup(costs, false, tile.position * Global.TILE_SIZE, Global.get_rect_center(data.size))
		Global.get_player().refund(costs)

		SFX.play_sfx("Destroy")

	map.efficiency_overlay.generate()

	if Input.is_action_pressed("repeat"):
		call_deferred("remove_construction")
	else:
		enable_user_selection()

	$Interface/HUD/ConstructionButtons/SlidingMenu/RemoveButton.pressed = false


func place_construction(data: ConstructionData):
	"""
	Handle positioning of a specific construction
	Does the required check for possible contruction
	"""
	disable_user_selection()

	if data.is_miner or data.id == "Storage":
		interface.show_efficiency_overlay()

	# Adds selection UI
	var tile_selector : TileSelector = interface.show_tile_selector(data)
	interface.highlight_connected_tiles(map.valid_construction_sites.values())

	yield(tile_selector, "tile_selected")

	var selected_tiles = tile_selector.selected_tiles
	var costs = data.get_costs()

	# Remove specific UI
	interface.hide_tile_selector()
	interface.clear_highlights()

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

	map.efficiency_overlay.generate()

	if Input.is_action_pressed("repeat"):
		call_deferred("place_construction", data)
	else:
		enable_user_selection()
		interface.hide_efficiency_overlay()


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


func _on_construction_complete(construction: Construction):
	"""
	Called everytime someting is built
	"""
	if construction.get_id() == "Wonder":
		_on_player_won(construction.get_center_world_position())


func _on_player_won(look_at: Vector2):
	"""
	Target the place where endgame is trigerred
	"""
	remove_child(interface)

	# Focus on wonder
	var camera = Global.get_camera()
	camera.player_has_control = false
	camera.remove_limitation()
	camera.focus(look_at)

	yield(get_tree().create_timer(1.0), "timeout")

	var particles = lightning_particle.instance()
	particles.position = look_at
	particles.z_index = Global.get_map().size.x * 10
	add_child(particles)

	$FadingOverlay.bounce_in()

	yield(get_tree().create_timer($FadingOverlay.fade_in_time), "timeout")

	var __ = get_tree().change_scene("res://source/menu/Credits.tscn")
