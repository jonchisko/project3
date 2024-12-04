extends PropertyBase

class_name Property

var _name: String
var _type: PropertyTypes.Type
var _description: String
var _enum_values: Array[String]

func _init(name: String, type: PropertyTypes.Type, description: String, _enum_values: Array[String]):
	self._name = name
	self._type = type
	self._description = description
	self._enum_values = _enum_values

func name() -> String:
	return self._name

func get_property_data() -> Dictionary:
	return self._construct_dictionary_representation()
	
func _construct_dictionary_representation() -> Dictionary:
	var data: Dictionary = {}
	
	data[self._name] = {}
	data[self._name]["type"] = PropertyTypes.json_object_to_string(self._type)
	
	if not self._description.is_empty():
		data[self._name]["description"] = self._description
	if not self._enum_values.is_empty():
		data[self._name]["enum"] = self._enum_values

	return data
