extends RefCounted

class_name MessageManager

const _role_key: String = "role"
const _content_key: String = "content"

var _static_context: Array[Dictionary]
var _message_data: Array[Dictionary]

func _init() -> void:
	pass
	
func show_messages() -> String:
	return JSON.stringify(self._message_data)
	
func show_context() -> String:
	return JSON.stringify(self._static_context)

func get_combined_message_data() -> Array[Dictionary]:
	var combined: Array[Dictionary] = []
	combined = self._static_context + self._message_data
	return combined

func append_static_context(role: String, content: String):
	self._append_message(role, content, self._static_context)

func append_static_context_dictionary(role_content: Dictionary):
	self._append_message_dictionary(role_content, self._static_context)

func append_static_contexts(static_contexts: Array[Dictionary]):
	for static_context in static_contexts:
		self.append_static_context_dictionary(static_context)

func clear_static_context():
	self._static_context.clear()

func prepend_message(role: String, content: String):
	self._message_data.push_front({self._role_key: role, self._content_key: content})
	
func prepend_message_dictionary(role_content: Dictionary):
	if not role_content.has(self._role_key) or not role_content.has(self._content_key):
		return
	self._message_data.push_front(role_content)
	
func prepend_messages(messages: Array[Dictionary]):
	for message in messages:
		self.prepend_message_dictionary(message)

func append_message(role: String, content: String):
	self._append_message(role, content, self._message_data)
	
func append_message_dictionary(role_content: Dictionary):
	self._append_message_dictionary(role_content, self._message_data)
	
func append_messages(messages: Array[Dictionary]):
	for message in messages:
		self.append_message_dictionary(message)

func remove_newest_message():
	self._message_data.pop_back()
	
func remove_oldest_message():
	self._message_data.pop_front()
	
func clear_all_messages():
	self._message_data.clear()

func _append_message(role: String, content: String, data: Array[Dictionary]) -> void:
	data.append({self._role_key: role, self._content_key: content})
	
func _append_message_dictionary(role_content: Dictionary, data: Array[Dictionary]) -> void:
	if not role_content.has(self._role_key) or not role_content.has(self._content_key):
		return
	data.append(role_content)
