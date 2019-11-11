extends Control

# warning-ignore:unused_class_variable
var delay := 0.0

onready var tween := $Tween as Tween
onready var logo := $Logo
onready var topic := $Topic


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var __ = tween.stop_all()
		__ = get_tree().change_scene("res://source/menu/TitleScreen.tscn")


func _ready() -> void:
	logo.modulate.a = 0
	topic.modulate.a = 0
	_animate()


func _animate() -> void:
	var __ = tween.interpolate_property(logo, "modulate:a", 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
	__ = tween.interpolate_property(logo, "modulate:a", 1, 0, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 2)

	__ = tween.interpolate_property(topic, "modulate:a", 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 5)
	__ = tween.interpolate_property(topic, "modulate:a", 1, 0, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 7)

	__ = tween.start()

	__ = tween.interpolate_property(self, "delay", 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 8)

func _on_Tween_tween_all_completed() -> void:
	var __ = get_tree().change_scene("res://source/menu/TitleScreen.tscn")
