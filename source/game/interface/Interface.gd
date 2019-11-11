extends CanvasLayer
class_name Interface

export (Resource) var construction_button

onready var construction_buttons := $HUD/ConstuctionButtons
onready var highlight_container := $HighlightContainer as Control
onready var resource_label := $HUD/Panel/MarginContainer/CenterContainer/HBoxContainer/ResourceLabel as Label


func _ready() -> void:
	_add_construction_buttons()


func update_player(player: Player):
	resource_label.text = "Resources: %d" % player.resources
	for button in construction_buttons.get_children():
		button.disabled = button.data.cost > player.resources


func _add_construction_buttons():
	for key in Global.constructions:
		var c = Global.constructions[key]
		var button = construction_button.instance()
		button.data = c
		button.connect("pressed", self, "_on_ConstructionButton_pressed", [ c ])
		button.connect("mouse_entered", self, "_on_ConstructionButton_mouse_entered", [ button ])
		button.connect("mouse_exited", self, "_on_ConstructionButton_mouse_exited", [ button ])
		construction_buttons.add_child(button)

func highlight_connected_tiles(tiles: Array):
	clear_highlights()

	for tile in tiles:
		var h := TileHighlighter.instance() as TileHighlighter
		highlight_container.add_child(h)
		h.rect_global_position = tile.get_world_position()
		h.modulate = Color("66FF33")

func highlight_lands(tiles: Array):
	clear_highlights()

	for tile in tiles:
		if tile.type == Tile.TYPE.LAND:
			var h := TileHighlighter.instance() as TileHighlighter
			highlight_container.add_child(h)
			h.rect_global_position = tile.get_world_position()

			if tile.resources:
				h.modulate = Color("FFAA00")


func clear_highlights():
	for child in highlight_container.get_children():
		highlight_container.remove_child(child)
		child.queue_free()


func _on_Generate_pressed() -> void:
	var __ = get_tree().reload_current_scene()


func _on_ConstructionButton_pressed(data: ConstructionData):
	get_tree().call_group("Game", "place_construction", data)


func _on_ConstructionButton_mouse_entered(button: Button):
	button.show_tooltip()


func _on_ConstructionButton_mouse_exited(button: Button):
	button.hide_tooltip()


func _on_Remove_pressed():
	get_tree().call_group("Game", "remove_construction")
