extends CanvasLayer
class_name Interface

export (Resource) var construction_button

onready var construction_buttons := $HUD/ConstuctionButtons
onready var highlight_container := $HighlightContainer as Control
onready var basic_alloy_display := $HUD/Panel/MarginContainer/ResourceContainer/basic_alloy
onready var special_alloy_display := $HUD/Panel/MarginContainer/ResourceContainer/special_alloy
onready var building_status := $HUD/BuildingStatus
onready var tile_info := $HUD/TileInfo

var tile_selector : TileSelector = null


func _ready() -> void:
	_add_construction_buttons()

	hide_building_status()
	hide_tile_info()


func update_player(player: Player):
	"""
	Update interface based on change occuring in player
	"""
	var resources = player.get_resources()
	basic_alloy_display.set_value(resources)
	special_alloy_display.set_value(resources)

	for button in construction_buttons.get_children():
		button.disabled = not player.can_afford(button.data.get_costs())


func _add_construction_buttons():
	for key in Global.constructions:
		var c = Global.constructions[key]
		var button = construction_button.instance()
		button.data = c
		button.connect("pressed", self, "_on_ConstructionButton_pressed", [ c ])
		button.connect("mouse_entered", self, "_on_ConstructionButton_mouse_entered", [ button ])
		button.connect("mouse_exited", self, "_on_ConstructionButton_mouse_exited", [ button ])
		construction_buttons.add_child(button)


func highlight_connected_tiles(tiles: Array):
	clear_highlights()

	for tile in tiles:
		highlight(tile, "66FF33")


func highlight_tiles(tiles):
	clear_highlights()

	for tile in tiles:
		highlight(tile, Color.white)


func highlight_lands(tiles: Array):
	clear_highlights()

	for tile in tiles:
		if tile.type == Tile.TYPE.LAND:
			var color = Color.white
			if tile.deposit.amount > 0:
				color = Color("FFAA00")

			highlight(tile, color)


func highlight(tile: Tile, color: Color):
	"""
	Highlight the given tile
	"""
	var h := TileHighlighter.instance() as TileHighlighter
	highlight_container.add_child(h)
	h.rect_global_position = tile.get_world_position()
	h.modulate = color


func clear_highlights():
	for child in highlight_container.get_children():
		highlight_container.remove_child(child)
		child.queue_free()


func _on_Generate_pressed() -> void:
	clear_selection()
	var __ = get_tree().reload_current_scene()


func _on_ConstructionButton_pressed(data: ConstructionData):
	clear_selection()
	Global.get_game().place_construction(data)


func _on_ConstructionButton_mouse_entered(button: Button):
	button.show_tooltip()


func _on_ConstructionButton_mouse_exited(button: Button):
	button.hide_tooltip()


func _on_Remove_pressed():
	clear_selection()
	Global.get_game().remove_construction()


func show_building_status(building: Building):
	"""
	Display informations about the selected building
	"""
	building_status.set_building(building)
	building_status.show()


func show_tile_info(tile: Tile):
	"""
	Show information about the given tile
	"""
	tile_info.set_tile(tile)
	tile_info.show()


func hide_tile_info():
	tile_info.set_tile(null)
	tile_info.hide()


func hide_building_status():
	building_status.set_building(null)
	building_status.hide()


func clear_selection():
	"""
	Remove any selection made
	"""
	clear_highlights()
	hide_building_status()
	hide_tile_info()


func show_tile_selector(removing_tool: bool, _size: Vector2, placing_connector=false) -> TileSelector:
	hide_tile_selector()

	tile_selector = TileSelector.instance() as TileSelector
	tile_selector.size = _size
	tile_selector.placing_connector = placing_connector
	tile_selector.removing_tool = removing_tool
	Global.get_map().add_child(tile_selector)

	return tile_selector


func hide_tile_selector() -> void:
	if not tile_selector:
		return

	Global.get_map().remove_child(tile_selector)
	tile_selector.queue_free()
	tile_selector = null
