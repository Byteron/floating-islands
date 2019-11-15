extends Control

var writing = false

export(int) var speed = 35

var visible_characters = 0.0

var tick := 0.0

onready var text_label = $Box/MarginContainer/RichTextLabel


func _process(delta):
	if is_complete():
		writing = false
	elif writing:

		visible_characters += speed * delta
		text_label.visible_characters = visible_characters

		tick += delta
		if tick > 0.08:
			tick = 0.0
			SFX.play_sfx("TypeWriter")


func write(line: String) -> void:
	text_label.text = line
	reset()
	writing = true
	# print("start writing textbox")


func stop() -> void:
	writing = false


func reset() -> void:
	visible_characters = 0.0
	text_label.visible_characters = 0
	# print("reset textbox")


func complete() -> void:
	text_label.visible_characters = len(text_label.text)
	# print("complete textbox")


func is_complete() -> bool:
	return text_label.visible_characters >= len(text_label.text)
	# print("textbox is complete")
