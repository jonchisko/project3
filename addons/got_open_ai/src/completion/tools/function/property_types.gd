class_name PropertyTypes

enum Type {
	StringJson,
	NumberJson,
	IntegerJson,
	ObjectJson,
	ArrayJson,
	BooleanJson,
	NullJson
}

static func json_object_to_string(type: Type) -> String:
	match type:
		Type.StringJson:
			return "string"
		Type.NumberJson:
			return "number"
		Type.IntegerJson:
			return "integer"
		Type.ObjectJson:
			return "object"
		Type.ArrayJson:
			return "array"
		Type.BooleanJson:
			return "boolean"
		Type.NullJson:
			return "null"
		_:
			return "null"
