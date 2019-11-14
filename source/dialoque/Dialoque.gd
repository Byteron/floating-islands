extends Control
class_name Dialoque

signal finished

export(Array, String, MULTILINE) var lines = []

var current = -1 setget _set_current

var kill := false

onready var text_box = $TextBox
onready var tween := $Tween

func _ready() -> void:
	modulate.a = 0
	yield(get_tree().create_timer(1.5), "timeout")
	_fade_in()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("select"):
		if has_next_line() and not is_writing():
			next_line()
		elif is_writing():
			complete()
		elif not has_next_line() and not is_writing():
			emit_signal("finished")
			_fade_out()


func reset():
	current = -1
	text_box.reset()


func next_line():
	current += 1
	_set_current(current)


func has_next_line():
	return current + 1 < lines.size()


func complete():
	text_box.complete()


func is_writing():
	return text_box.writing


func _set_current(value):
	current = value
	text_box.write(lines[current])


func _fade_in() -> void:
	var __ = tween.interpolate_property(self, "modulate:a", 0, 1, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__ = tween.start()

func _fade_out() -> void:
	var __ = tween.interpolate_property(self, "modulate:a", 1, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__ = tween.start()
	kill = true

func _on_Tween_tween_all_completed() -> void:
	if kill:
		queue_free()
	else:
		next_line()
