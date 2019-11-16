extends Panel

var hints := [
	"mining buildings also mine neighbored tiles.",
	"destryoing buildings refund 75% of their costs.",
	"always have enough oil at hand!",
	"the numbers 1 to 6 are shortcuts for placing buildings.",
	"press X and click on buildings to destroy them.",
	"hold SHIFT to place or destroy mutliple buildings.",
	"We love you!"
]

var current_hint := 0 setget _set_current_hint

onready var text_label := $HBoxContainer/VBoxContainer/TextBox/TextLabel
onready var pages_label := $HBoxContainer/VBoxContainer/PagesLabel

func _ready() -> void:
	randomize()
	hints.shuffle()

	_set_current_hint(0)


func next() -> void:
	var next_index = (current_hint + 1) % hints.size()
	_set_current_hint(next_index)

func prev() -> void:
	var prev_index = current_hint - 1
	if prev_index < 0:
		prev_index = hints.size() - 1
	_set_current_hint(prev_index)

func _set_current_hint(value: int) -> void:
	current_hint = value

	# assert(current_hint < hints.size())
	if text_label:
		text_label.text = hints[current_hint]
		pages_label.text = "%d / %d" % [ current_hint + 1, hints.size()]


func _on_ButtonLeft_pressed() -> void:
	prev()
	SFX.play_sfx("ButtonClick")


func _on_ButtonRight_pressed() -> void:
	next()
	SFX.play_sfx("ButtonClick")


func _on_ButtonLeft_mouse_entered() -> void:
	SFX.play_sfx("ButtonHover")


func _on_ButtonRight_mouse_entered() -> void:
	SFX.play_sfx("ButtonHover")
