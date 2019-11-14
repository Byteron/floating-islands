extends Control
"""
Handles a sliding menu rising or descending out/in the screen
"""
signal gear_entered()
signal gear_exited()
signal gear_pressed()

onready var gear_button := $GearButton as TextureButton
onready var open_position := rect_global_position
onready var closed_position := rect_global_position + tween_travel

export var is_open : bool = true
export var tween_travel : Vector2 = Vector2(0.0, 68.0)
export var sliding_time : float = 0.5
export var preview_offset : Vector2 = Vector2(0.0, 5.0)
export var preview_time : float = 0.1
export var preview_scale : Vector2 = Vector2(1.25, 1.25)


func toggle() -> void:
	if not is_open:
		_open()
		is_open = true
	else:
		_close()
		is_open = false


func _open():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_global_position",
		rect_global_position, open_position, sliding_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(gear_button, "rect_rotation",
		gear_button.rect_rotation, 0, sliding_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.start()

	is_open = true


func _close():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_global_position",
		rect_global_position, closed_position, sliding_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(gear_button, "rect_rotation",
		gear_button.rect_rotation, -360, sliding_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.start()

	is_open = false


func _on_preview_enter() -> void:
	var offset = preview_offset
	if not is_open:
		offset = preview_offset * Vector2(-1, -1)

	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_global_position",
		rect_global_position, rect_global_position + offset, preview_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(gear_button, "rect_scale",
		gear_button.rect_scale, preview_scale, preview_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.start()


func _on_preview_exited() -> void:
	if $Tween.is_active():
		return

	if is_open:
		rect_global_position = open_position
	else:
		rect_global_position = closed_position

	$Tween.stop_all()
	$Tween.interpolate_property(gear_button, "rect_scale",
		gear_button.rect_scale, Vector2(1, 1), preview_time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_GearButton_pressed():
	emit_signal("gear_pressed")


func _on_GearButton_mouse_entered():
	emit_signal("gear_entered")


func _on_GearButton_mouse_exited():
	emit_signal("gear_exited")
