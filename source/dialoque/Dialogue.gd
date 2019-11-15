extends Control
class_name Dialogue

signal finished

export(Array, String, MULTILINE) var lines = []
export var fadout_time : float = 0.5
export var fadin_time : float = 1.0
export var start_delay : float = 0.0

var current = -1 setget _set_current

var kill := false

onready var text_box = $TextBox
onready var tween := $Tween

func _ready() -> void:
	modulate.a = 0
	yield(get_tree().create_timer(start_delay), "timeout")
	_fade_in()


func _process(_delta) -> void:
	if not kill:
		Global.get_game().disable_user_selection()


func _input(event: InputEvent) -> void:
	if kill:
		return

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
	assert(lines.size() > value)

	current = value
	text_box.write(lines[current])


func _fade_in() -> void:
	var __ = tween.interpolate_property(self, "modulate:a", 0, 1, fadin_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__ = tween.start()

func _fade_out() -> void:
	var __ = tween.interpolate_property(self, "modulate:a", 1, 0, fadout_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__ = tween.start()
	kill = true
	Global.get_game().enable_user_selection()

func _on_Tween_tween_all_completed() -> void:
	if kill:
		queue_free()
	elif has_next_line():
		next_line()
