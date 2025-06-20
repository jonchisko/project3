extends Node
class_name ChatManager

var _chat_messenger_ui: PackedScene = preload("res://scenes/ui/messenger/chat_messenger_ui.tscn")
var _chat_messenger_instance: ChatMessengerUi = null

var _current_npc_data: NpcData
var _template: BaseGptTemplate
var _gpt_template: TemplateBase

@export var chat_history: ChatHistory
@export var template_factory: TemplateFactory

var _player_inventory: InventoryManager


func _ready() -> void:
	GameEvents.interact_with_interactable.connect(self._open_chat_window_for)
	self._player_inventory = self.get_tree().get_first_node_in_group("player").find_child("InventoryManager") as InventoryManager


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
func _on_player_message_sent(player_message: String) -> void:
	self._chat_messenger_instance.add_chat_element(self._current_npc_data.temporary_replies.pick_random())

	self._template.add_player_query(self._gpt_template, player_message, true)
	self._template.add_similar_data_from_history(self._gpt_template, self._current_npc_data, self.chat_history, player_message)
	self._template.add_instructions(self._gpt_template)
	self._template.add_player_query(self._gpt_template, player_message, false)

	var response: CompletionResponse = await self._gpt_template.get_reply()
	
	# First remove the similar_data_from_history and user query, so that we just keep similar history
	# for current query
	self._gpt_template.remove_oldest_message() # Remove the old message query at the top
	
	self._gpt_template.remove_newest_message() # query
	self._gpt_template.remove_newest_message() # instructions
	self._gpt_template.remove_newest_message() # similar history
	
	self._template.add_player_query(self._gpt_template, player_message, false) # re-add
	
	while true:
		if response.successful():
			var player_message_to_save: Message = MessageBuilder.new("user")\
				.with_content(player_message)\
				.build()
			self.chat_history.save_history(self._current_npc_data.id, [player_message_to_save])
			
			var choice: ChoiceResponse = response.choices()[0]
			var npc_message: Message = choice.message
			
			self._chat_messenger_instance.edit_last_chat_element(npc_message.content)
			self._gpt_template.append_message_with(npc_message)
			self.chat_history.save_history(self._current_npc_data.id, [npc_message])
			
			var tools: Array[ToolCall] = choice.message.tool_calls
			if tools.is_empty():
				break
			
			for tool in tools:
				var tool_call_result = self._parse_tool_call(tool)
				printt("Tool:", tool.name, tool.arguments, JSON.stringify(tool_call_result))
				
				var tool_message: Message = MessageBuilder.new("tool")\
					.with_tool_call_id(tool.id)\
					.with_content(JSON.stringify(tool_call_result))\
					.build()
				
				self._gpt_template.append_message_with(tool_message)
				self.chat_history.save_history(self._current_npc_data.id, [tool_message])
				
			response = await self._gpt_template.get_reply()
			
		else:
			var system_message: String = "Response from assistant was not successful.
			Player query not stored in 'long-term' history."
			
			self._chat_messenger_instance.edit_last_chat_element(system_message)
			
			break

	
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
		.with_description("Checks if the player has 'number' of item_id' in the inventory. Returns true or false.")\
		.with_property(
			PropertyBuilder.new("item_id", PropertyTypes.Type.StringJson)
				.with_description("The item_id you want inquire about.")
				.build(), 
			true)\
		.with_property(
			PropertyBuilder.new("number", PropertyTypes.Type.NumberJson)
				.with_description("How many items you want to give.")
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
	
	
func _trigger_event_tool() -> Tool:
	var trigger_event_tool: Tool = FunctionToolBuilder.new("trigger_event")\
		.with_description("Triggers the game event.")\
		.with_property(
			PropertyBuilder.new("event_id", PropertyTypes.Type.StringJson)
				.with_description("The event_id you want to trigger.")
				.build(), 
			true)\
		.build()
		
	return trigger_event_tool
	
	
func _set_chat_history() -> void:
	chat_history.max_last_exchanges = OpenAiConfiguration.history_max_last_exchanges
	chat_history.max_similar_results = OpenAiConfiguration.history_max_similar_results
	chat_history.threshold_similar_results = OpenAiConfiguration.history_threshold_similar_results


func _parse_tool_call(tool: ToolCall) -> Dictionary:
	var call_result = {"error": false, "message": "", "call_result": null}
	
	var fun_name = tool.name
	
	var parsed_arguments_data = self._parse_arguments_data(tool.arguments)
	if not parsed_arguments_data["message"].is_empty():
		call_result["error"] = true
		call_result["message"] = parsed_arguments_data["message"]
		return call_result
		
	var fun_args = parsed_arguments_data["data"]
	
	match fun_name:
		"has_item":
			if not fun_args.has("item_id") or not fun_args.has("number"):
				call_result["error"] = true
				call_result["message"] = "Missing function arguments (either 'item_id' or 'number')!"
			else:
				var has_item = self._player_inventory.has_item(fun_args["item_id"], fun_args["number"])
				call_result["call_result"] = has_item
			
		"get_item":
			if not fun_args.has("item_id") or not fun_args.has("number"):
				call_result["error"] = true
				call_result["message"] = "Missing function arguments (either 'item_id' or 'number')!"
			else:
				var item = self._player_inventory.get_item(fun_args["item_id"], fun_args["number"])
				if item == null:
					call_result["error"] = true
					call_result["message"] = "Get item was unable to obtain {item_id}".format({"item_id": fun_args["item_id"]})
				else:
					call_result["call_result"] = item
		"give_item":
			if not fun_args.has("item_id") or not fun_args.has("number"):
				call_result["error"] = true
				call_result["message"] = "Missing function arguments (either 'item_id' or 'number')!"
			else:
				var result = self._player_inventory.give_item(fun_args["item_id"], fun_args["number"])
				call_result["call_result"] = result
		"trigger_event":
			if not fun_args.has("event_id"):
				call_result["error"] = true
				call_result["message"] = "Missing function arguments (event_id)!"
			else:
				print("Triggering event {event}".format({"event": fun_args["event_id"]}))
				call_result["call_result"] = true
		_:
			call_result["error"] = true
			call_result["message"] = "Missing function. Incorrect function call name!"
	
	return call_result
	

func _parse_arguments_data(arguments: String) -> Dictionary:
	var json_parser = JSON.new()
	var error = json_parser.parse(arguments)
	if error == OK:
		var data = json_parser.data
		if typeof(data) == TYPE_DICTIONARY:
			return {"message": "", "data": data}
		return {"message": "Unknown data type of tool arguments", "data": null}
	return {"message": "Tool arguments:" + json_parser.get_error_message(), "data": null}
