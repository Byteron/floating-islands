extends Node2D
"""
Handle last scene of the game
"""


func _ready():
	$FadingOverlay.visible_by_default = true
	$FadingOverlay.fade_out()
