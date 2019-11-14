extends Control

var closed_position : Vector2
var open_position : Vector2

var button_width := 0.0

onready var remove_button := $"../Remove" as TextureButton

onready var toggle_button := $ToggleButton

onready var buttons := $Buttons as VBoxContainer
onready var tween := $Tween as Tween

onready var close_timer := $CloseTimer as Timer


func _ready() -> void:
	closed_position = rect_global_position
	open_position = rect_global_position
	remove_button.connect("mouse_entered", self, "_on_Button_mouse_entered")
	remove_button.connect("mouse_exited", self, "_on_Button_mouse_exited")
	toggle_button.connect("mouse_entered", self, "_on_Button_mouse_entered")
	toggle_button.connect("mouse_exited", self, "_on_Button_mouse_exited")

func add_button(button: Button) -> void:
	buttons.add_child(button)
	button.connect("mouse_entered", self, "_on_Button_mouse_entered")
	button.connect("mouse_exited", self, "_on_Button_mouse_exited")
	open_position.y = closed_position.y - button.rect_size.y * buttons.get_child_count()
	button_width = max(button_width, button.rect_size.x)


func _open():
	var __ = tween.stop_all()
	__ = tween.interpolate_property(remove_button, "rect_global_position:x", remove_button.rect_global_position.x, button_width + 1, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	__ = tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, open_position.y, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.2)
	__ = tween.start()
	close_timer.start()


func _close():
	var __ = tween.stop_all()
	__ = tween.interpolate_property(self, "rect_global_position:y", rect_global_position.y, closed_position.y, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	__ = tween.interpolate_property(remove_button, "rect_global_position:x", remove_button.rect_global_position.x, remove_button.rect_size.x + 1, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.2)
	__ = tween.start()
	toggle_button.pressed = false


func get_buttons() -> Array:
	return buttons.get_children()


func _on_ToggleButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_open()
	else:
		_close()


func _on_CloseTimer_timeout() -> void:
	_close()


func _on_Button_mouse_entered() -> void:
	close_timer.stop()


func _on_Button_mouse_exited() -> void:
	close_timer.start()
