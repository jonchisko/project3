extends RefCounted

class_name PropertyBuilder

var _name: String = ""
var _type: PropertyTypes.Type = PropertyTypes.Type.ObjectJson
var _description: String = ""
var _enum_values: Array[String] = []

static func new(name: String, type: PropertyTypes.Type) -> PropertyBuilder:
	return PropertyBuilder.new(name, type)

func _init(name: String, type: PropertyTypes.Type):
	self._name = name
	self._type = type
	
func with_description(value: String) -> PropertyBuilder:
	self._description = value
	return self

func with_enum_values(value: Array[String]) -> PropertyBuilder:
	self._enum_values = value
	return self

func build() -> PropertyBase:
	return Property.new(self._name, self._type, self._description, self._enum_values)
