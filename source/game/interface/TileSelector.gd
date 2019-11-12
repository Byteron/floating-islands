extends Control
class_name TileSelector

signal tile_selected()

onready var selectors = $Selectors

var selected_tiles : Array = []

var starting_cell : Vector2 = Vector2()

var size := Vector2(1, 1)
var map = null
var placing_connector = false
var follow_mouse = true


static func instance():
	return load("res://source/game/interface/TileSelector.tscn").instance()


func _ready() -> void:
	map = Global.get_map()
	var cell = map.world_to_map(get_global_mouse_position())
	for x in size.x:
		for y in size.y:
			_create_selector(cell, Vector2(x, y))


func _input(event: InputEvent) -> void:
	# Actual action performed
	if event.is_action_released("LMB"):
		selected_tiles = [ map.get_tile(starting_cell) ]
		emit_signal("tile_selected")
	elif event.is_action_pressed("LMB"):
		starting_cell = map.world_to_map(get_global_mouse_position())
		follow_mouse = false
		if not placing_connector:
			selected_tiles = [ map.get_tile(starting_cell) ]
			emit_signal("tile_selected")
	elif event.is_action_pressed("RMB"):
		emit_signal("tile_selected")

	accept_event()

	if not event is InputEventMouseMotion:
		return

	# Mouse movement
	rect_global_position = map.snap_position(get_global_mouse_position())

	var cell = map.world_to_map(get_global_mouse_position())
	var force_valid = false		# Force all green when map says its good to go
	var force_invalid = false	# Force all red when not over valid construction site
	if not follow_mouse:
		return

	if not placing_connector:
		force_valid = map.is_area_available(cell, size, placing_connector)
		if not force_valid:
			force_invalid = not map.is_area_over_valid_site(cell, size)

	for selector in selectors.get_children():
		selector.set_cell(cell)
		if force_valid:
			selector.set_valid()
		if force_invalid:
			selector.set_invalid()

func _create_selector(cell: Vector2, offset: Vector2=Vector2()):
	"""
	Adds a selector that will show if tile under it is valid position or not
	"""
	var selector = TileSelectorRect.instance()
	selectors.add_child(selector)

	selector.placing_connector = placing_connector
	selector.offset = offset

	selector.set_cell(cell)
