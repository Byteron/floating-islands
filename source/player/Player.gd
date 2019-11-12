extends Node
class_name Player

<<<<<<< HEAD
var resources := 0 setget _set_resources

export var start_resources := 1000
# warning-ignore:unused_class_variable
export(float, 0, 1) var refund_percentage := 0.75
=======
var _resources := {}
>>>>>>> d8fe55a50ca3490d4a7bfe294b16e78d1647ea81


func _ready() -> void:
	for resource in Global.resources.values():
		_resources[resource.id] = resource.start_value

	get_tree().call_group("Interface", "update_player", self)


func add_resource(id: String, amount: int) -> void:
	assert(_resources.has(id))

	_set_resource(id, _resources[id] + amount)


func buy(costs: Dictionary) -> bool:
	if can_afford(costs):
		for id in costs:
			return use_resource(id, costs[id])

	return false


func use_resource(id: String, amount: int) -> bool:
	"""
	Use some resource, return true if success
	"""
	if has_resource(id, amount):
		add_resource(id, -amount)
		return true

	return false


func get_resource(id: String) -> int:
	assert(_resources.has(id))

	return _resources[id]


func get_resources() -> Dictionary:
	return _resources


func can_afford(costs: Dictionary) -> bool:
	"""
	Check the player can afford the given costs
	"""
	var has_enough = true
	for id in costs:
		 has_enough = has_enough and has_resource(id, costs[id])

	return has_enough

func has_resource(id: String, amount: int) -> bool:
	return get_resource(id) >= amount


func _set_resource(id: String, value: int) -> void:
	_resources[id] = value
	get_tree().call_group("Interface", "update_player", self)
