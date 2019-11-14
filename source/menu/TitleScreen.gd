extends Control

onready var center := get_viewport_rect().size / 2

onready var stars1 := $BG/Stars1
onready var stars2 := $BG/Stars2
onready var earth := $BG/Earth

func _ready() -> void:
	Music.play_song("Loop")


func _process(delta: float) -> void:
	var offset = get_global_mouse_position() - center
	stars1.rect_position = -offset * 0.08
	stars2.rect_position = -offset * 0.12
	earth.rect_position = offset * 0.04


func _on_New_Game_pressed() -> void:
	var __ = get_tree().change_scene("res://source/game/Game.tscn")


func _on_Quit_pressed() -> void:
	get_tree().quit()
