extends CanvasLayer
class_name Interface

onready var highlight_container := $HighlightContainer as Control

func highlight_lands(tiles: Array):
	clear_highlights()

	for tile in tiles:
		if tile.type == Tile.TYPE.LAND:
			var h := TileHighlighter.instance() as TileHighlighter
			highlight_container.add_child(h)
			h.rect_global_position = tile.position

			if tile.resources:
				h.modulate = Color("FFAA00")

func clear_highlights():
	for child in highlight_container.get_children():
		highlight_container.remove_child(child)
		child.queue_free()

func _on_Generate_pressed() -> void:
	get_tree().reload_current_scene()
