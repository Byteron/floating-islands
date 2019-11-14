extends Node2D
"""
Handle last scene of the game
"""

export var camera_movement: float = 100.0
export var camera_movement_time: float = 7.0
export var animation_time: float = 3.0
export var credit_transition_time: float = 2.0
export var credit_time: float = 10.0
export var before_reset_time: float = 2.0

var camera_start: Vector2


func _ready():
	#$FadingOverlay/CreditsStart.hide()

	var overlay = $FadingOverlay
	yield(get_tree().create_timer(1.0), "timeout")

	overlay.fade_out()

	var camera = $Camera2D
	camera_start = camera.position
	$Tween.interpolate_property(camera, "position:x",
		camera_start.x, camera_start.x + camera_movement,
		camera_movement_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()

	yield(get_tree().create_timer(animation_time), "timeout")

	overlay.color = Color.black
	overlay.fade_in_time = credit_transition_time
	overlay.fade_in()

	yield(overlay, "fading_complete")
	unroll_credits()


func unroll_credits():
	"""
	Make credits show up from below
	"""
	$Tween.stop_all()
	$Camera2D.position = camera_start
	$FadingOverlay/CreditsStart.show()

	var credits = $FadingOverlay/CreditsStart/CreditsContainer
	var credits_end = $FadingOverlay/CreditsStart/CreditsEnd
	$Tween.interpolate_property(credits, "rect_position",
		credits.rect_position, credits.rect_position + credits_end.position,
		credit_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()

	yield(get_tree().create_timer(credit_time), "timeout")
	yield(get_tree().create_timer(before_reset_time), "timeout")

	var __ = get_tree().change_scene("res://source/menu/Splash.tscn")
