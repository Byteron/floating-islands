extends CanvasLayer
"""
Show some nice loading screen
"""

onready var sprite = $Background/VBoxContainer/CenterContainer/Sprite

export var animation_speed : float = 1.0
export var animated_characters_count : int = 3
export var sprite_offset : Vector2 = Vector2(0, -7)

var floppy_step : float = 0 setget bounce_floppy
var sprite_initial : Vector2


func _ready():
	sprite_initial = sprite.rect_position

	var label = $Background/VBoxContainer/CenterContainer2/Label
	$Tween.interpolate_property(label, "visible_characters",
		label.text.length() - animated_characters_count,
		label.text.length(),
		animation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(self, "floppy_step",
		0, PI * 2,
		animation_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.repeat = true
	$Tween.start()


func bounce_floppy(value: float):
	sprite.rect_position = sprite_initial + sprite_offset * cos(value)


func _on_level_loaded():
	$Tween.stop_all()
	$Background.hide()
