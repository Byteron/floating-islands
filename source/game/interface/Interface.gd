extends CanvasLayer
class_name Interface

onready var construction_buttons := $HUD/ConstuctionButtons
onready var highlight_container := $HighlightContainer as Control

onready var resource_label := $HUD/Panel/MarginContainer/CenterContainer/HBoxContainer/ResourceLabel as Label

func _ready() -> void:
	_add_construction_buttons()

func update_player(player: Player):
	resource_label.text = "Resources: %d" % player.resources

func _add_construction_buttons():
	for key in Global.constructions:
		var c = Global.constructions[key]
		var button = Button.new()
		button.name = c.name
		button.text = c.name
		button.connect("pressed", self, "_on_ConstructionButton_pressed", [ c ])
		construction_buttons.add_child(button)

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

func _on_ConstructionButton_pressed(data: ConstructionData):
	get_tree().call_group("Game", "set_process_unhandled_input", false)
	get_tree().call_group("Game", "place_construction", data)
