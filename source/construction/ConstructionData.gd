extends Resource
class_name ConstructionData

# warning-ignore:unused_class_variable
export var id := ""
# warning-ignore:unused_class_variable
export var name := ""

export var cost_basic_alloy := 0
export var cost_special_alloy := 0

# warning-ignore:unused_class_variable
export var size := Vector2(1, 1)

# warning-ignore:unused_class_variable
export var is_miner := false
# warning-ignore:unused_class_variable
export var is_connector := false
# warning-ignore:unused_class_variable
export var is_storage := false

# warning-ignore:unused_class_variable
export var target_resource : String = ""
# warning-ignore:unused_class_variable
export var miner_radius := 1
# warning-ignore:unused_class_variable
export var miner_tick_time := 5
# warning-ignore:unused_class_variable
export var miner_mine_amount := 20

# warning-ignore:unused_class_variable
export var texture : Texture = null
# warning-ignore:unused_class_variable
export var texture_inactive : Texture = null

# warning-ignore:unused_class_variable
export var texture_offset := Vector2()

# warning-ignore:unused_class_variable
export var description : String = "MISSING DESCRIPTION"


func get_costs() -> Dictionary:
	return {
		"basic_alloy": cost_basic_alloy,
		"special_alloy": cost_special_alloy
	}
