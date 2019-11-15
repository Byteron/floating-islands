extends Control

onready var center := get_viewport_rect().size / 2

onready var tween := $Tween as Tween

onready var stars1 := $BG/Stars1
onready var stars2 := $BG/Stars2
onready var earth := $BG/Earth

onready var cover := $Cover/ColorRect
onready var title := $Title
onready var menu := $CenterContainer

func _ready() -> void:
	Music.play_song("Loop", 2.0)

	title.modulate.a = 0
	menu.modulate.a = 0

	var __ = tween.interpolate_property(cover, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__ = tween.interpolate_property(title, "modulate:a", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	__ = tween.interpolate_property(menu, "modulate:a", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.3)
	__ = tween.start()

func _process(delta: float) -> void:
	var offset = get_global_mouse_position() - center
	stars1.rect_position = -offset * 0.08
	stars2.rect_position = -offset * 0.12
	earth.rect_position = offset * 0.04


func _on_New_Game_pressed() -> void:
	var __ = get_tree().change_scene("res://source/game/Game.tscn")


func _on_Quit_pressed() -> void:
	get_tree().quit()
