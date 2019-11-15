extends Button

func _ready() -> void:
	pass

func _pressed() -> void:
	SFX.play_sfx("ButtonClick")


func _on_MenuButton_mouse_entered() -> void:
	SFX.play_sfx("ButtonHover")
