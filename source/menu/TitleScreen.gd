extends Panel


func _ready() -> void:
	Music.play_song("Loop")


func _on_New_Game_pressed() -> void:
	var __ = get_tree().change_scene("res://source/game/Game.tscn")


func _on_Quit_pressed() -> void:
	get_tree().quit()
