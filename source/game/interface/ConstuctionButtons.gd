extends Control

var closed_position : Vector2
var open_position : Vector2

onready var buttons := $Buttons as VBoxContainer
onready var tween := $Tween as Tween

func _ready() -> void:
	closed_position = rect_global_position
	open_position = rect_global_position


func add_button(button: Button) -> void:
	buttons.add_child(button)
	open_position.y = closed_position.y - button.rect_size.y * buttons.get_child_count()

func _open():
	var __ = tween.stop_all()
	__ = tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, open_position.y, 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	__ = tween.start()

func _close():
	var __ = tween.stop_all()
	__ = tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, closed_position.y, 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	__ = tween.start()

func get_buttons() -> Array:
	return buttons.get_children()

func _on_ToggleButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_open()
	else:
		_close()
