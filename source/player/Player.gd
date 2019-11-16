extends Node
class_name Player

var _resources := {}
# warning-ignore:unused_class_variable
export(float, 0, 1) var refund_percentage := 0.75


func _ready() -> void:
	for resource in Global.resources.values():
		_resources[resource.id] = resource.start_value

	get_tree().call_group("Interface", "update_player", self)


func refund(costs: Dictionary):
	"""
	Give multiple ressources at once
	"""
	for id in costs:
		(add_resource(id, costs[id]))


func add_resource(id: String, amount: int) -> void:
	assert(_resources.has(id))

	_set_resource(id, _resources[id] + amount)


func buy(costs: Dictionary) -> bool:
	if can_afford(costs):
		for id in costs:
			var __ = use_resource(id, costs[id])
			assert(__)
		return true

	return false


func use_resource(id: String, amount: int, allow_negative := false) -> bool:
	"""
	Use some resource, return true if success
	"""
	if has_resource(id, amount) or allow_negative:
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
	return max(0, get_resource(id)) >= amount


func _set_resource(id: String, value: int) -> void:
	_resources[id] = value
	get_tree().call_group("Interface", "update_player", self)
