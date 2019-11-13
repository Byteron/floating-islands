extends Control

var closed_position : Vector2
var open_position : Vector2

var button_width := 0.0

onready var remove_button := $"../Remove" as TextureButton

onready var buttons := $Buttons as VBoxContainer
onready var tween := $Tween as Tween


func _ready() -> void:
	closed_position = rect_global_position
	open_position = rect_global_position


func add_button(button: Button) -> void:
	buttons.add_child(button)
	open_position.y = closed_position.y - button.rect_size.y * buttons.get_child_count()
	button_width = max(button_width, button.rect_size.x)


func _open():
	tween.stop_all()
	tween.interpolate_property(remove_button, "rect_global_position:x", remove_button.rect_global_position.x, button_width + 1, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, open_position.y, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.2)
	tween.start()


func _close():
	tween.stop_all()
	tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, closed_position.y, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(remove_button, "rect_global_position:x", remove_button.rect_global_position.x, remove_button.rect_size.x + 1, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.2)
	tween.start()


func get_buttons() -> Array:
	return buttons.get_children()


func _on_ToggleButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_open()
	else:
		_close()
