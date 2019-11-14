extends CanvasLayer
"""
Fade the game out/in
"""

signal fading_complete

export var fade_in_time: float = 5.0
export var fade_out_time: float = 1.0
export var visible_by_default: bool = false

onready var screen = $Screen as ColorRect


func _ready():
	if not visible_by_default:
		screen.modulate.a = 0.0


func fade_in():
	$Tween.interpolate_property(screen, "modulate:a", 0, 1, fade_in_time, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	$Tween.start()


func fade_out():
	$Tween.interpolate_property(screen, "modulate:a", 0, 1, fade_out_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_all_completed():
	emit_signal("fading_complete")
