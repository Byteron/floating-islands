extends Node2D

onready var player := $Player as Player

onready var map := $Map as Map
onready var interface := $Interface as Interface


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tiles := map.get_island_tiles(get_global_mouse_position())
		interface.highlight_lands(tiles)

	if event.is_action_pressed("RMB"):
		interface.clear_highlights()


func _ready() -> void:
	SFX.set_sfx_volume("FactoryLoop", 0)
	SFX.play_sfx("FactoryLoop")


func _process(_delta: float) -> void:
	_process_factory_loop_volume()


func _process_factory_loop_volume() -> void:
	var radius := 64 # 3 tiles
	var mouse_position := get_global_mouse_position()
	var volume := 0.0

	var miners := get_tree().get_nodes_in_group("Miner")
	for miner in miners:
		var distance = mouse_position.distance_to(miner.global_position)
		var temp = clamp(0.8 - distance / radius, 0, 1)
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

	var tile = tile_selector.selected_tile

	# Remove specific UI
	map.remove_tile_selector()

	enable_user_selection()

	var data = map.remove_construction(tile)
	if data:
		var player = Global.get_player()
		var refund = floor(data.cost * player.refund_percentage)
		display_resource_popup(
			refund,
			tile.position * Global.TILE_SIZE,
			data.size * Global.TILE_SIZE / 2
		)
		player.add_resources(refund)

	SFX.play_sfx("Destroy")


func place_construction(data: ConstructionData):
	"""
	Handle positioning of a specific construction
	Does the required check for possible contruction
	"""
	disable_user_selection()

	# Adds selection UI
	var tile_selector := map.new_tile_selector(data.size)
	interface.highlight_connected_tiles(map.valid_construction_sites.values())

	yield(tile_selector, "tile_selected")

	var tile = tile_selector.selected_tile

	# Remove specific UI
	map.remove_tile_selector()
	interface.clear_highlights()

	enable_user_selection()

	# Cannot build there or nothing selected
	if not tile or not map.valid_construction_sites.values().has(tile):
		return

	# Already occupied
	if tile.construction:
		return

	# Not enough resources
	if not player.can_afford(data.get_costs()):
		return

	# Cant build on top of building or connector or void
	var type = map.get_tile_type(tile.position)
	if type == Tile.TYPE.BUILDING or type == Tile.TYPE.CONNECTOR:
		return

	# No building on the void
	if not data.is_connector and type == Tile.TYPE.VOID:
		return

	assert(player.buy(data.get_costs()))
	map.add_contruction(tile, data)

	if data.id == "Rail":
		SFX.play_sfx("BuildRail")
	else:
		SFX.play_sfx("BuildBuilding")

	if Input.is_action_pressed("shift"):
		set_process_unhandled_input(false)
		place_construction(data)


func display_resource_popup(value: int, position: Vector2, offset: Vector2=Vector2()) -> void:
	"""
	Displays a popup showing production/consumption of resource slowly fadding away
	"""
	var popup := PopupLabel.instance() as PopupLabel

	if value >= 0:
		popup.text = "+%d" % value
		popup.color = Color("00FF00")
		SFX.play_sfx("Mine")
	else:
		popup.text = "%d" % value
		popup.color = Color("FF0000")

	popup.rect_global_position = position + offset
	add_child(popup)
