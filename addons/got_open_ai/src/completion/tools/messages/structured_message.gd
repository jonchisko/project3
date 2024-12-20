extends RefCounted

class_name StructuredMessage

var role: String
var content: String

func _init(role: String, content: String) -> void:
	self.role = role
	self.content = content
