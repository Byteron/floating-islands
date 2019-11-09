extends Node2D
class_name Construction

onready var sprite := $Sprite as Sprite

static func instance():
	return load("res://source/construction/Construction.tscn").instance()

func initialize(data: ConstructionData):
	name = data.name
	sprite.texture = data.texture
