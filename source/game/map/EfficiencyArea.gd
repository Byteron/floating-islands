extends Sprite

var x : int
var y : int


func _ready():
	position = Vector2(x, y) * Global.TILE_SIZE
