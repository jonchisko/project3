extends RefCounted

class_name MessageManager

const _role_key: String = "role"
const _content_key: String = "content"

var _static_context: Array[Dictionary]
var _message_data: Array[Dictionary]

func _init() -> void:
	pass
	
func messages_to_string() -> String:
	return JSON.stringify(self._message_data)
	
func context_to_string() -> String:
	return JSON.stringify(self._static_context)
	
func get_structured_messages() -> Array[StructuredMessage]:
	var messages: Array[StructuredMessage] = []
	for message in self._message_data:
		messages.push_back(StructuredMessage.new(message[self._role_key], message[self._content_key]))
	
	return messages

func get_structured_context() -> Array[StructuredMessage]:
	var contextes: Array[StructuredMessage] = []
	for context in self._static_context:
		contextes.push_back(StructuredMessage.new(context[self._role_key], context[self._content_key]))
	
	return contextes

func get_combined_message_data() -> Array:
	var combined: Array[Dictionary] = []
	combined = self._static_context + self._message_data
	return combined

func append_static_context(role: String, content: String):
	self._append_message(role, content, self._static_context)

func append_static_context_dictionary(role_content: Dictionary):
	self._append_message_dictionary(role_content, self._static_context)

func append_static_contexts(static_contexts: Array):
	for static_context in static_contexts:
		self.append_static_context_dictionary(static_context)

func clear_static_context():
	self._static_context.clear()

func prepend_message(role: String, content: String):
	self._message_data.push_front({self._role_key: role, self._content_key: content})
	
func prepend_message_dictionary(role_content: Dictionary):
	var element = self._get_element_from_role_content(role_content)
	self._message_data.push_front(element)
	
func prepend_messages(messages: Array):
	for message in messages:
		self.prepend_message_dictionary(message)

func append_message(role: String, content: String):
	self._append_message(role, content, self._message_data)
	
func append_message_dictionary(role_content: Dictionary):
	self._append_message_dictionary(role_content, self._message_data)
	
func append_messages(messages: Array):
	for message in messages:
		self.append_message_dictionary(message)

func remove_newest_message():
	self._message_data.pop_back()
	
func remove_oldest_message():
	self._message_data.pop_front()
	
func clear_all_messages():
	self._message_data.clear()

func _append_message(role: String, content: String, data: Array) -> void:
	data.append({self._role_key: role, self._content_key: content})
	
func _append_message_dictionary(role_content: Dictionary, data: Array) -> void:
	var element = self._get_element_from_role_content(role_content)
	data.append(element)

func _get_element_from_role_content(role_content: Dictionary) -> Dictionary:
	if role_content.size() != 1:
		printerr("The role_content should be of exactly size one 
			{'some_role' : 'some_content'}, but was: ", role_content)
		return {}
		
	var role = role_content.keys()[0]
	var element = {self._role_key: role, self._content_key: role_content[role]}
	
	return element
