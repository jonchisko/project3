extends RefCounted

class_name MessageResponse

var role: String
var content: String
var refusal: String
var tool_calls: Array[ToolCall]

func _init(data: Dictionary):
	self.role = data["role"]
	self.content = self._process_optional(data, "content")
	self.refusal = self._process_optional(data, "refusal")
	self.tool_calls = self._process_tool_calls(data)
	
func _process_optional(data: Dictionary, key: String) -> String:
	if not data.has(key) or data[key] == null:
		return ""
	return data[key]
	
func _process_tool_calls(data: Dictionary) -> Array[ToolCall]:
	var tools: Array[ToolCall] = []
	
	if not data.has("tool_calls") or data["tool_calls"] == null:
		return tools
	
	for tool in data["tool_calls"]:
		tools.push_back(ToolCall.new(tool))	
	
	return tools
