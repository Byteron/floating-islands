extends Control

var button_width := 0.0
# warning-ignore:unused_class_variable
var construction_actions = [
	"build_rail",
	"build_miner",
	"build_wonder",
	"build_refinery",
	"build_storage",
	"build_smeltery"
]

onready var construct_button := $SlidingMenu/ConstructButton
onready var slider := $SlidingMenu

onready var buttons := $SlidingMenu/Buttons as VBoxContainer


func _ready() -> void:
	slider.closed_position = rect_global_position
	slider.open_position = rect_global_position


func add_button(button: Button) -> void:
	buttons.add_child(button)
	slider.open_position.y = slider.closed_position.y - button.rect_size.y * buttons.get_child_count()
	button_width = max(button_width, button.rect_size.x)


func get_buttons() -> Array:
	return buttons.get_children()


func _on_RemoveButton_pressed():
	Global.get_game().interface.clear_selection()
	Global.get_game().remove_construction()
	SFX.play_sfx("ButtonClick")

func _on_ConstructButton_pressed():
	slider.toggle()
	construct_button.pressed = slider.is_open


func _on_construction_action(action: String):
	var id = action.substr("build_".length(), -1)
	print(id)
	for button in buttons.get_children():
		if button.data.id.to_lower() == id:
			Global.get_game().interface._on_ConstructionButton_pressed(button.data)
			return
