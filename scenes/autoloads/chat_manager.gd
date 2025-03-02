extends Node


var _chat_messenger_ui: PackedScene = preload("res://scenes/ui/messenger/chat_messenger_ui.tscn")
var _chat_messenger_instance: ChatMessengerUi = null

var _current_npc_data: NpcData
var _gpt_template: TemplateBase

@export var ApiKey: String = ""

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


func _on_player_message_sent(message: String) -> void:
	self._gpt_template.append_message("user", message)
	
	self._chat_messenger_instance.add_chat_element(self._current_npc_data.temporary_reply)
	var response = await self._gpt_template.get_reply()
	
	if response.successful():
		var npc_message = response.choices()[0]["message"]["content"]
		self._gpt_template.append_message("assistant", npc_message)
		self._chat_messenger_instance.edit_last_chat_element(npc_message)
	else:
		self._gpt_template.append_message("system", "<No response from assistant.>")


func _create_open_ai_template(npcData: NpcData) -> void:
	# TODO insert history context from HistoryManager?!
	var user_configuration = UserConfiguration.new(self.ApiKey)
	OpenAiApi.got_open_ai.user_configuration = user_configuration
	self._gpt_template = OpenAiApi.got_open_ai.GetGptCompletion()\
		.get_template()\
		.append_static_context("system", "You role-play as the non-player-character.")\
		.append_static_context("system", "Here is the description of your non-player-character, named '{name}': '{desc}'"
			.format({"name": npcData.name, "desc": npcData.context}))\
		.append_static_context("system", "Only stay within the knowledge of context and lord of the rings. If the users asks you anything outside of that
		domain, tell them that you dont know about it.")
