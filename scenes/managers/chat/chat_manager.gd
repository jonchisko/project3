extends Node
class_name ChatManager

var _chat_messenger_ui: PackedScene = preload("res://scenes/ui/messenger/chat_messenger_ui.tscn")
var _chat_messenger_instance: ChatMessengerUi = null

var _current_npc_data: NpcData
var _template: BaseGptTemplate
var _gpt_template: TemplateBase

@export var chat_history: ChatHistory
@export var template_factory: TemplateFactory



var _first_message: bool = true


func _ready() -> void:
	GameEvents.interact_with_interactable.connect(self._open_chat_window_for)


func _open_chat_window_for(interactable: InteractableArea) -> void:
	var current_npc_data = interactable.interactable_data.data as NpcData
	if current_npc_data == null:
		return
	
	if self._chat_messenger_instance != null:
		self._chat_messenger_instance.close_chat()
		
	self._chat_messenger_instance = self._chat_messenger_ui.instantiate() as ChatMessengerUi
	self.add_child(self._chat_messenger_instance)
	
	self._create_open_ai_template(current_npc_data)
	
	self._chat_messenger_instance.message_created.connect(self._on_player_message_sent)
	self._current_npc_data = current_npc_data


# Done every time a message is SENT
func _on_player_message_sent(message: String) -> void:
	if not self._first_message:
		self._gpt_template.remove_oldest_message() # Remove the old message query at the top
	if self._first_message:
		self._first_message = false
		
	self._template.add_player_query(self._gpt_template, message, true)
	self._template.add_similar_data_from_history(self._gpt_template, self._current_npc_data, self.chat_history, message)
	self._template.add_instructions(self._gpt_template)
	self._template.add_player_query(self._gpt_template, message, false)
	
	self._chat_messenger_instance.add_chat_element(self._current_npc_data.temporary_replies.pick_random())
	var response = await self._gpt_template.get_reply()
	
	#print("STATIC CONTEXT")
	#for element in self._gpt_template.structured_context():
		#print(element.role, " ", element.content)
		#
	#print("MESSAGES")
	#for element in self._gpt_template.structured_messages():
		#print(element.role, " ", element.content)
	
	if response.successful():
		var choice: ChoiceResponse = response.choices()[0]
		var npc_message = choice["message"]["content"]
		var tools = choice.message.tool_calls
		print(tools)
		# First remove the similar_data_from_history and user query, so that we just keep similar history
		# for current query
		self._gpt_template.remove_newest_message() # query
		self._gpt_template.remove_newest_message() # instructions
		self._gpt_template.remove_newest_message() # similar history
		
		self._template.add_player_query(self._gpt_template, message, false) # re-add
		self._gpt_template.append_message("assistant", npc_message)
		
		self._chat_messenger_instance.edit_last_chat_element(npc_message)
		
		var data_to_save = [{"user": message}, {"assistant": npc_message}]
		print("Saving history: ", data_to_save)
		self.chat_history.save_history(self._current_npc_data.id, data_to_save)
	else:
		# First remove the similar_data_from_history and user query, so that we just keep similar history
		# for current query
		self._gpt_template.remove_newest_message() # query
		self._gpt_template.remove_newest_message() # instructions
		self._gpt_template.remove_newest_message() # similar history
		
		self._template.add_player_query(self._gpt_template, message, false) # re-add
		self._gpt_template.append_message("developer", "<No response from assistant.>")

	
# Done ONCE at the start of the chat
func _create_open_ai_template(npc_data: NpcData) -> void:
	var user_configuration = UserConfiguration.new(OpenAiConfiguration.open_ai_api_key)
	OpenAiApi.got_open_ai.user_configuration = user_configuration
	
	self._template = self.template_factory.get_template(OpenAiConfiguration.template_type)
	
	self._gpt_template = OpenAiApi.got_open_ai.GetGptCompletion()\
		.with_model(OpenAiTypes.model_version_to_string(OpenAiConfiguration.open_ai_model))\
		.with_temperature(OpenAiConfiguration.temperature)\
		.with_frequency_penalty(OpenAiConfiguration.frequency_penalty)\
		.with_auto_tool_choice()\
		.with_tool(self._get_has_item_tool())\
		.with_tool(self._get_give_item_tool())\
		.with_tool(self._get_get_item_tool())\
		.get_template()
		
	self._set_chat_history()
	
	self._template.set_up_static_template(self._gpt_template, npc_data, self.chat_history)


func _get_has_item_tool() -> Tool:
	var has_item_tool: Tool = FunctionToolBuilder.new("has_item")\
		.with_description("Obtains information how many instances of item 'item_id' the player holds (0, 1, 2, etc.).")\
		.with_property(
			PropertyBuilder.new("item_id", PropertyTypes.Type.StringJson)
				.with_description("The item_id you want inquire about.")
				.build(), 
			true)\
		.build()
		
	return has_item_tool


func _get_give_item_tool() -> Tool:
	var give_item_tool: Tool = FunctionToolBuilder.new("give_item")\
		.with_description("Gives the desired amount of item 'item_id' to player.")\
		.with_property(
			PropertyBuilder.new("item_id", PropertyTypes.Type.StringJson)
				.with_description("The item_id you want to give.")
				.build(), 
			true)\
		.with_property(
			PropertyBuilder.new("number", PropertyTypes.Type.NumberJson)
				.with_description("How many items you want to give.")
				.build(), 
			true)\
		.build()
		
	return give_item_tool


func _get_get_item_tool() -> Tool:
	var get_item_tool: Tool = FunctionToolBuilder.new("get_item")\
		.with_description("Takes the desired amount of item 'item_id' from player.")\
		.with_property(
			PropertyBuilder.new("item_id", PropertyTypes.Type.StringJson)
				.with_description("The item_id you want to take.")
				.build(), 
			true)\
		.with_property(
			PropertyBuilder.new("number", PropertyTypes.Type.NumberJson)
				.with_description("How many items you want to take.")
				.build(), 
			true)\
		.build()
		
	return get_item_tool
	
	
func _set_chat_history() -> void:
	chat_history.max_last_exchanges = OpenAiConfiguration.history_max_last_exchanges
	chat_history.max_similar_results = OpenAiConfiguration.history_max_similar_results
	chat_history.threshold_similar_results = OpenAiConfiguration.history_threshold_similar_results
