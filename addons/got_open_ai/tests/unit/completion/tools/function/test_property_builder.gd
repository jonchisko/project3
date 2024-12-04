extends GutTest

const _property_name: String = "DefaultName"
const _type_key: String = "type"
const _description_key: String = "description"
const _enum_key: String = "enum"

#func before_each():
	#_property_builder = PropertyBuilder.new(
		#_property_name, 
		#PropertyTypes.Type.NullJson)

#func after_each():
	#gut.p("ran teardown", 2)
#
#func before_all():
	#gut.p("ran run setup", 2)
#
#func after_all():
	#gut.p("ran run teardown", 2)
	
func test_create_default_basic_property():
	# Arrange
	var property: Property = PropertyBuilder.new(self._property_name, PropertyTypes.Type.NullJson).build()
	var nullJson: String = PropertyTypes.json_object_to_string(PropertyTypes.Type.NullJson)
	
	# Act
	var data: Dictionary = property.get_property_data()
	
	# Assert
	assert_true(data.has(self._property_name), "Property name is missing from data.")
	assert_true(data[self._property_name].has(self._type_key), "Property type is missing from data.")
	assert_eq(nullJson, data[self._property_name][self._type_key], "Property type should be 'NullJson'.")
	

func test_create_property_with_all_aditional_fields():
	# Arrange
	var property: Property = PropertyBuilder.new(self._property_name, PropertyTypes.Type.StringJson)\
	.with_description("Property description.")\
	.with_enum_values(["AUTO", "BUS"])\
	.build()
	var stringJson: String = PropertyTypes.json_object_to_string(PropertyTypes.Type.StringJson)
	
	# Act
	var data: Dictionary = property.get_property_data()
	
	# Assert
	assert_true(data.has(self._property_name), "Property name is missing from data.")
	assert_true(data[self._property_name].has(self._type_key), "Property type is missing from data.")
	assert_eq(stringJson, data[self._property_name][self._type_key], "Property type should be '{type}'.".format({"type": stringJson}))
	assert_true(data[self._property_name].has(self._description_key), "Property description is missing from data.")
	assert_eq("Property description.", data[self._property_name][self._description_key], "Description not the same.")
	assert_true(data[self._property_name].has(self._enum_key), "Property enum is missing from data.")
	assert_eq(["AUTO", "BUS"], data[self._property_name][self._enum_key], "Enum values not the same.")
	
var parameter_types_test = ParameterFactory.named_parameters(
	["parameter_type", "expected"],
	[
		[PropertyTypes.Type.StringJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.StringJson)],
		[PropertyTypes.Type.NumberJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.NumberJson)],
		[PropertyTypes.Type.IntegerJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.IntegerJson)],
		[PropertyTypes.Type.ObjectJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.ObjectJson)],
		[PropertyTypes.Type.ArrayJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.ArrayJson)],
		[PropertyTypes.Type.BooleanJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.BooleanJson)],
		[PropertyTypes.Type.NullJson, PropertyTypes.json_object_to_string(PropertyTypes.Type.NullJson)]
	])
	
func test_create_property_with_all_types(params=use_parameters(parameter_types_test)):
	# Arrange
	var property: Property = PropertyBuilder.new(self._property_name, params.parameter_type).build()
	
	# Act
	var data: Dictionary = property.get_property_data()
	
	# Assert
	assert_true(data.has(self._property_name), "Property name is missing from data.")
	assert_true(data[self._property_name].has(self._type_key), "Property type is missing from data.")
	assert_eq(params.expected, data[self._property_name][self._type_key], "Property type should be '{type}'.".format({"type": params.expected}))
