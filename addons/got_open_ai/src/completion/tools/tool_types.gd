class_name ToolTypes

enum Type {
	Function
}

static func json_object_to_string(type: Type) -> String:
	match type:
		Type.Function:
			return "function"
		_:
			return "function"
