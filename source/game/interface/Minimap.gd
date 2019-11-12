extends Control

export var margin = 2
var COLORS = {
	Tile.TYPE.VOID: Color.black,
	Tile.TYPE.LAND: Color.lightgray,
	Tile.TYPE.BUILDING: Color( 0.321569, 0.2, 0.247059, 1 ),
	Tile.TYPE.CONNECTOR: Color.purple,
	Tile.TYPE.BASIC_ALLOY: Color.red,
	Tile.TYPE.SPECIAL_ALLOY: Color.darkgreen
}


func _ready():
	var map = Global.get_map()
	rect_size = map.size + Vector2(margin, margin) * 2


func _draw():
	var map = Global.get_map()

	# Draw tiles
	for x in range(map.size.x):
		for y in range(map.size.y):
			var position = Vector2(x, y)
			var type = map.get_tile_type(position)
			var color = COLORS[type]
			draw_rect(Rect2(Vector2(margin, margin) + position, Vector2(1, 1)), color)

	# Draw camera
	var camera = Global.get_camera()
	if camera:
		var position = camera.position / Global.TILE_SIZE
		var width = ProjectSettings.get_setting("display/window/size/width")
		var height = ProjectSettings.get_setting("display/window/size/height")
		var extents = Vector2(width, height) / Global.TILE_SIZE

		var draw_position = position - extents / 2

		# Prevent drawing outside of the UI (top-left)
		if draw_position.x < 0:
			extents.x += draw_position.x
			draw_position.x = 0
		if draw_position.y < 0:
			extents.y += draw_position.y
			draw_position.y = 0

		# Prevent drawing outside of the UI (bottom-right)
		if (draw_position + extents).x > map.size.x:
			extents.x -= (draw_position + extents).x - map.size.x
		if (draw_position + extents).y > map.size.y:
			extents.y -= (draw_position + extents).y - map.size.y

		draw_rect(Rect2(Vector2(margin, margin) + draw_position, extents), Color.yellow, false)


func _process(_delta):
	update()


func _on_Minimap_gui_input(event):
	"""
	Move camera on click on the minimap
	"""
	if Input.is_action_pressed("LMB"):
		var camera = Global.get_camera()
		camera.position = (event.position - Vector2(margin, margin)) * Global.TILE_SIZE
