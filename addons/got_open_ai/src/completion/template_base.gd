extends Node

class_name TemplateBase

const _messages_key: String = "messages"

var _configuration: ApiConfiguration
var _open_ai_request: OpenAiRequestBase
var _message_manager: MessageManager

func _init(configuration: ApiConfiguration, open_ai_request: OpenAiRequestBase, message_manager: MessageManager):
	self._configuration = configuration
	self._open_ai_request = open_ai_request
	self._message_manager = message_manager

func construct_data() -> Dictionary:
	return {}

func get_reply() -> CompletionResponse:
	var data: Dictionary = {}
	
	var messages: Array = self._message_manager.get_combined_message_data()
	messages = messages.map(func(message): return message.get_dictionary_form())
	data[self._messages_key] = messages
	
	var template_specific_data = self.construct_data()
	data.merge(template_specific_data)

	var response: CompletionResponse = await ResponseFactory.GetCompletionResponse(
		self._open_ai_request, 
		self._configuration.url(),
		self._configuration.get_content_authorization_header(), 
		self._configuration.method(), 
		data)
		
	return response

func append_static_context(role: String, content: String) -> TemplateBase:
	var message = MessageBuilder.new(role).with_content(content).build()
	self._message_manager.append_static_context_with(message)
	return self
	
func append_static_context_with(message: Message) -> TemplateBase:
	self._message_manager.append_static_context_with(message)
	return self

func append_static_contexts(static_contexts: Array) -> TemplateBase:
	self._message_manager.append_static_contexts(static_contexts)
	return self

func clear_static_context() -> TemplateBase:
	self._message_manager.clear_static_context()
	return self 

func prepend_message_with(message: Message) -> TemplateBase:
	self._message_manager.prepend_message_with(message)
	return self

func prepend_message(role: String, content: String) -> TemplateBase:
	var message = MessageBuilder.new(role).with_content(content).build()
	self._message_manager.prepend_message_with(message)
	return self

func prepend_tool_message(tool_call_id: String, tool_result: String) -> TemplateBase:
	var message = MessageBuilder.new("tool").with_tool_call_id(tool_call_id).with_content(tool_result).build()
	self._message_manager.prepend_message_with(message)
	return self
	
func prepend_messages(messages: Array) -> TemplateBase:
	self._message_manager.prepend_messages(messages)
	return self

func append_message_with(message: Message) -> TemplateBase:
	self._message_manager.append_message_with(message)
	return self

func append_message(role: String, content: String) -> TemplateBase:
	var message = MessageBuilder.new(role).with_content(content).build()
	self._message_manager.append_message_with(message)
	return self

func append_tool_message(tool_call_id: String, tool_result: String) -> TemplateBase:
	var message = MessageBuilder.new("tool").with_tool_call_id(tool_call_id).with_content(tool_result).build()
	self._message_manager.append_message_with(message)
	return self
	
func append_messages(messages: Array) -> TemplateBase:
	self._message_manager.append_messages(messages)
	return self

func remove_newest_message() -> TemplateBase:
	self._message_manager.remove_newest_message()
	return self
	
func remove_oldest_message() -> TemplateBase:
	self._message_manager.remove_oldest_message()
	return self
	
func clear_all_messages() -> TemplateBase:
	self._message_manager.clear_all_messages()
	return self

func show_messages() -> String:
	return self._message_manager.messages_to_string()
	
func get_messages() -> Array[Message]:
	return self._message_manager._static_context

func get_context() -> Array[Message]:
	return self._message_manager._message_data
