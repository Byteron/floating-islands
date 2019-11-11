extends Node
class_name TrackContainer

var type := "track"

func get_core() -> AudioStreamPlayer:
	return get_child(0) as AudioStreamPlayer

func get_tracks() -> Array:
	return get_children()

func has_core() -> bool:
	return get_child_count() > 0
