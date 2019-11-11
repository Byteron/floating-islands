extends Control

onready var tween := $Tween as Tween
onready var logo := $Logo
onready var topic := $Topic


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://source/menu/TitleScreen.tscn")


func _ready() -> void:
	logo.modulate.a = 0
	topic.modulate.a = 0
	_animate()


func _animate() -> void:
	yield(get_tree().create_timer(1), "timeout")

	tween.interpolate_property(logo, "modulate:a", 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(logo, "modulate:a", 1, 0, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 2)

	tween.interpolate_property(topic, "modulate:a", 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 4)
	tween.interpolate_property(topic, "modulate:a", 1, 0, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 6)

	tween.start()

	yield(get_tree().create_timer(8), "timeout")

	get_tree().change_scene("res://source/menu/TitleScreen.tscn")
