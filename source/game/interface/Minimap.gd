extends Control

export var margin = 2
var COLORS = [
	Color.black,
	Color.red,
	Color.white,
	Color( 0.321569, 0.2, 0.247059, 1 )
]


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
		var position = Vector2(margin, margin) + camera.position / Global.TILE_SIZE
		var width = ProjectSettings.get_setting("display/window/size/width")
		var height = ProjectSettings.get_setting("display/window/size/height")
		var extents = Vector2(width, height) / Global.TILE_SIZE

		draw_rect(Rect2(position - extents / 2, extents), Color.yellow, false)


func _process(_delta):
	update()
