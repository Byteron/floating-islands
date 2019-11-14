extends Control

var button_width := 0.0

onready var remove_button := $SlidingMenu/RemoveButton as TextureButton
onready var construct_button := $SlidingMenu/ConstructButton
onready var slider := $SlidingMenu

onready var buttons := $SlidingMenu/Buttons as VBoxContainer


func _ready() -> void:
	slider.closed_position = rect_global_position
	slider.open_position = rect_global_position


func add_button(button: Button) -> void:
	buttons.add_child(button)
	var __ = button.connect("mouse_entered", self, "_on_Button_mouse_entered")
	__ = button.connect("mouse_exited", self, "_on_Button_mouse_exited")

	slider.open_position.y = slider.closed_position.y - button.rect_size.y * buttons.get_child_count()
	button_width = max(button_width, button.rect_size.x)


func get_buttons() -> Array:
	return buttons.get_children()


func _on_ConstructButton_toggled(button_pressed: bool) -> void:
	slider.toggle()


func _on_RemoveButton_pressed():
	Global.get_game().interface.clear_selection()
	Global.get_game().remove_construction()
