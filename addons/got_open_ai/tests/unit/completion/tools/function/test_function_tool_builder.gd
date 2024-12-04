extends GutTest


#func before_each():
	#gut.p("ran setup", 2)

#func after_each():
	#gut.p("ran teardown", 2)
#
#func before_all():
	#gut.p("ran run setup", 2)
#
#func after_all():
	#gut.p("ran run teardown", 2)

func test_create_a_default_function():
	# Arrange
	var function: Tool = FunctionToolBuilder.new("defaultFunction").build()
	
	# Act
	var function_data: Dictionary = function.get_tool_data()
	
	# Assert
	assert_true(function_data.has("type"), "Type data is missing.")
	assert_true(function_data.has("function"), "Function data is missing.")
	assert_true(function_data["function"].has("name"), "Function 'name' is missing.")
	
	assert_eq("function", function_data["type"], "Type data does not equal 'function'.")
	assert_eq("defaultFunction", function_data["function"]["name"], "Name of the function is not 'defaultFunction'.")

func test_create_a_function_with_description():
	# Arrange
	var function: Tool = FunctionToolBuilder.new("sum").with_description("Sums two elements").build()
	
	# Act
	var function_data: Dictionary = function.get_tool_data()
	
	# Assert
	assert_eq("Sums two elements", function_data["function"]["description"], "Function 'description' is missing.")
	
# parametrize this with required non required

var property_parameters = ParameterFactory.named_parameters(
	["is_required", "name", "property_attribute_to_check"],
	[
		[true, "PropertyDouble", "PropertyDouble"],
		[false, "PropertyDouble", false]
	]
)

func test_create_a_function_with_property(params=use_parameters(property_parameters)):
	# Arrange
	var property_script = load('res://addons/got_open_ai/src/completion/tools/function/property_base.gd')
	#var enum_property_values: Array[String] = ["a", "b"]
	var property_double = double(property_script).new()
	
	stub(property_double, "name").to_return(params.name)
	stub(property_double, "get_property_data").to_return({"property_data": "data"})
	
	var function: Tool = FunctionToolBuilder.new("sum").with_property(property_double, params.is_required).build()
	
	# Act
	var function_data: Dictionary = function.get_tool_data()
	
	# Assert
	assert_true(function_data["function"].has("parameters"), "Parameters data is missing.")
	assert_true(function_data["function"]["parameters"].has("type"), "Parameters does not have 'type' data.")
	assert_eq(PropertyTypes.json_object_to_string(PropertyTypes.Type.ObjectJson), function_data["function"]["parameters"]["type"], 
	"Type of parameters is not '{type}'.".format({"type": PropertyTypes.json_object_to_string(PropertyTypes.Type.ObjectJson)}))
	
	assert_eq({"property_data": "data"}, function_data["function"]["parameters"]["properties"], "Property data not contained under properties.")
	if params.is_required:
		assert_eq([params.property_attribute_to_check], function_data["function"]["parameters"]["required"], "No properties under required.")
	else:
		assert_eq(false, function_data["function"]["parameters"].has("required"), "Required data is present.")

func test_create_a_strict_function():
	# Arrange
	var function: Tool = FunctionToolBuilder.new("sum").with_strict().build()
	
	# Act
	var function_data: Dictionary = function.get_tool_data()
	
	# Assert
	assert_eq(true, function_data["function"]["strict"], "Function data 'strict' is missing.")
