extends Control
class_name TileSelector

signal tile_selected()

onready var selectors = $Selectors

var selected_tiles : Array = []

var starting_cell : Vector2 = Vector2()

var size := Vector2(1, 1)
var map = null
var placing_connector = false
var follow_mouse = true			# The selection should follow the mouse
var removing_tool = false		# Are we destroying buildings?
var efficiency_impact = false	# Display selector on heatmap?

var placement_data = null		# What is being placed?


static func instance():
	return load("res://source/game/interface/TileSelector.tscn").instance()


func _ready() -> void:
	map = Global.get_map()

	if not placement_data:
		removing_tool = true
	else:
		placing_connector = placement_data.is_connector
		size = placement_data.size
		efficiency_impact = placement_data.id == "Storage"

	var cell = map.world_to_map(get_global_mouse_position())
	for x in size.x:
		for y in size.y:
			_create_selector(cell, Vector2(x, y))


func _input(event: InputEvent) -> void:
	# We released the action after a multiple selection for connectors
	if event.is_action_released("select"):
		# The action_pressed hasnt been trigerred yet
		if follow_mouse:
			return

		selected_tiles = []
		for selector in selectors.get_children():
			selected_tiles.append(map.get_tile(selector.cell))
		emit_signal("tile_selected")

	elif event.is_action_pressed("select"):
		starting_cell = map.world_to_map(get_global_mouse_position())
		follow_mouse = false
		if not placing_connector and not removing_tool:
			selected_tiles = [ map.get_tile(starting_cell) ]
			emit_signal("tile_selected")

	# Cancel selection
	elif event.is_action_pressed("cancel"):
		emit_signal("tile_selected")

	accept_event()

	if not event is InputEventMouseMotion:
		return

	# Global.get_map().efficiency_overlay.generate(efficiency_impact)

	# Mouse movement
	var cell = map.world_to_map(get_global_mouse_position())

	# Display path of rails from starting cell to current cell
	if not follow_mouse:
		if placing_connector:
			display_rail_path(starting_cell, cell)
		elif removing_tool:
			display_rectangle_selection(starting_cell, cell)
		return

	var force_valid = false				# Force all green when map says its good to go
	var force_invalid = removing_tool	# Force all red when not over valid construction site

	if not placing_connector:
		force_valid = map.is_area_available(cell, size, placing_connector)
		if not force_valid:
			force_invalid = force_invalid or not map.is_area_over_valid_site(cell, size)

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


func clear_selectors():
	"""
	Remove placed selection previews
	"""
	for selector in selectors.get_children():
		selectors.remove_child(selector)
		selector.queue_free()


func display_rail_path(from: Vector2, to: Vector2):
	"""
	Display a path going from the given from to the given to
	Each one of them showing if the path is valid or not
	"""
	clear_selectors()

	var final_offset = to - from

	# Because range works only with positive values
	var direction = Vector2(1, 1)
	if final_offset.x < 0:
		direction.x = -1
	if final_offset.y < 0:
		direction.y = -1

	for x in range(abs(final_offset.x)):
		_create_selector(from, Vector2(x, 0) * direction)

	for y in range(abs(final_offset.y) + 1):
		_create_selector(from, Vector2(abs(final_offset.x), y) * direction)

	# Make sure the valid/invalid display takes valid construction site into consideration
	var check_all_invalid = true
	var all_invalid = false
	for selector in selectors.get_children():
		if check_all_invalid:
			selector.update_validity(true)
			all_invalid = not selector.is_valid()
			check_all_invalid = false

		# If this is invalid placement, check that following ones are valid or not
		if not selector.is_valid():
			check_all_invalid = true

		if all_invalid or removing_tool:
			selector.set_invalid()


func display_rectangle_selection(from: Vector2, to: Vector2):
	"""
	Create a rectangle selection with the given extents
	Only used for removing
	"""
	clear_selectors()

	var area_size = to - from
	area_size = Vector2(abs(area_size.x) + 1, abs(area_size.y) + 1)

	var start = Vector2(from.x, from.y)
	if to.x <= from.x:
		start.x = to.x
	if to.y <= from.y:
		start.y = to.y

	for x in range(area_size.x):
		for y in range(area_size.y):
			_create_selector(start, Vector2(x, y))

	for selector in selectors.get_children():
		selector.set_invalid()
