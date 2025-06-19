extends RefCounted

class_name Message

var role: String
var content: String
var refusal: String
var tool_call_id: String
var tool_calls: Array[ToolCall]


func _init(role: String, content: String, refusal: String, tool_call_id: String, tool_calls: Array[ToolCall]):
	self.role = role
	self.content = content
	self.refusal = refusal
	self.tool_call_id = tool_call_id
	self.tool_calls = tool_calls

func get_dictionary_form() -> Dictionary:
	var result = {"role": self.role}
	
	if not self.content.is_empty():
		result["content"] = self.content
		
	if not self.refusal.is_empty():
		result["refusal"] = self.refusal
		
	if not self.tool_call_id.is_empty():
		result["tool_call_id"] = self.tool_call_id
		
	if not self.tool_calls.is_empty():
		result["tool_calls"] = self.tool_calls.map(func(x): return x.to_dictionary())
		
	return result
