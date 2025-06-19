extends RefCounted

class_name MessageManager

const _role_key: String = "role"
const _content_key: String = "content"

var _static_context: Array[Message]
var _message_data: Array[Message]

func _init() -> void:
	pass
	
func messages_to_string() -> String:
	return JSON.stringify(self._message_data.map(func(x): return x.get_dictionary_form()))
	
func context_to_string() -> String:
	return JSON.stringify(self._static_context.map(func(x): return x.get_dictionary_form()))

func get_combined_message_data() -> Array:
	var combined: Array[Message] = []
	combined = self._static_context + self._message_data
	return combined

func append_static_context_with(message: Message):
	self._append_message(message, self._static_context)

func append_static_context(role: String, content: String):
	var message = MessageBuilder.new(role).with_content(content).build()
	self._append_message(message, self._static_context)

func append_static_contexts(static_contexts: Array):
	for static_context in static_contexts:
		self._append_message_dictionary(static_context, self._static_context)

func clear_static_context():
	self._static_context.clear()

func prepend_message_with(message: Message):
	self._message_data.push_front(message)

func prepend_message(role: String, content: String):
	var message = MessageBuilder.new(role).with_content(content).build()
	self._message_data.push_front(message)
	
func prepend_messages(messages: Array):
	for message in messages:
		self._append_message_dictionary(message, self._message_data, true)

func append_message_with(message: Message):
	self._append_message(message, self._message_data)

func append_message(role: String, content: String):
	var message = MessageBuilder.new(role).with_content(content).build()
	self._append_message(message, self._message_data)
	
func append_messages(messages: Array):
	for message in messages:
		self._append_message_dictionary(message, self._message_data)

func remove_newest_message():
	self._message_data.pop_back()
	
func remove_oldest_message():
	self._message_data.pop_front()
	
func clear_all_messages():
	self._message_data.clear()

func _append_message(message: Message, data: Array) -> void:
	data.append(message)
	
func _append_message_dictionary(role_content: Dictionary, data: Array, prepend: bool = false) -> void:
	var element = self._get_element_from_role_content(role_content)
	if prepend:
		data.push_front(element)
	else:
		data.append(element)

func _get_element_from_role_content(role_content: Dictionary) -> Message:
	if role_content.size() != 1:
		printerr("The role_content should be of exactly size one 
			{'some_role' : 'some_content'}, but was: ", role_content)
		return null
		
	var role = role_content.keys()[0]
	
	return MessageBuilder.new(role).with_content(role_content[role]).build()
