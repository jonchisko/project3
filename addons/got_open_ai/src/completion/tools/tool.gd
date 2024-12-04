extends RefCounted

class_name Tool

var _type: ToolTypes.Type
var _name: String = ""
var _description: String = ""

func _init(type: ToolTypes.Type, name: String, description: String):
	self._type = type
	self._name = name
	self._description = description
	
func get_tool_data() -> Dictionary:
	return {}
