extends Control
class_name PopupLabel

const distance := 30

var color := Color("FFFFFF")
var text := ""

onready var label := $Label
onready var tween := $Tween


static func instance():
	return load("res://source/interface/PopupLabel.tscn").instance()


func _ready() -> void:
	modulate = color
	label.text = text
	_animate()


func _animate():
	rect_scale = Vector2(0, 0)
	tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1, 1), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, rect_global_position.y - distance, 0.5, Tween.TRANS_SINE, Tween.EASE_IN, 0.5)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN, 0.5)
	tween.start()


func _on_Tween_tween_all_completed() -> void:
	queue_free()
