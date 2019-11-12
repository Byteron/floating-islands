extends Node
class_name Player

var _resources := {}


func _ready() -> void:
	for resource in Global.resources.values():
		_resources[resource.id] = resource.start_value

	get_tree().call_group("Interface", "update_player", self)


func add_resource(id: String, amount: int) -> void:
	assert(_resources.has(id))

	_set_resource(id, _resources[id] + amount)


func buy(cost) -> bool:
	if can_afford(cost):
		return use_resource("basic_alloy", cost)

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


func can_afford(cost) -> bool:
	"""
	Check the player can afford the given costs
	"""
	return has_resource("basic_alloy", cost)


func has_resource(id: String, amount: int) -> bool:
	return get_resource(id) >= amount


func _set_resource(id: String, value: int) -> void:
	_resources[id] = value
	get_tree().call_group("Interface", "update_player", self)
