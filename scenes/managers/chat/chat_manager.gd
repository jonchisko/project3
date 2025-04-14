extends Node
class_name ChatManager

var _chat_messenger_ui: PackedScene = preload("res://scenes/ui/messenger/chat_messenger_ui.tscn")
var _chat_messenger_instance: ChatMessengerUi = null

var _current_npc_data: NpcData
var _gpt_template: TemplateBase

@export var chatHistory: ChatHistory
@export var apiKey: String = ""

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
	
	print("STATIC CONTEXT")
	for element in self._gpt_template.structured_context():
		print(element.role, " ", element.content)
	
	if response.successful():
		var npc_message = response.choices()[0]["message"]["content"]
		self._gpt_template.append_message("assistant", npc_message)
		self._chat_messenger_instance.edit_last_chat_element(npc_message)
		
		var data_to_save = [{"user": message}, {"assistant": npc_message}]
		print("Saving history: ", data_to_save)
		self.chatHistory.save_history(self._current_npc_data.id, data_to_save)
	else:
		self._gpt_template.append_message("system", "<No response from assistant.>")

	

func _create_open_ai_template(npcData: NpcData) -> void:
	# TODO insert history context from HistoryManager?!
	var user_configuration = UserConfiguration.new(self.apiKey)
	OpenAiApi.got_open_ai.user_configuration = user_configuration
	self._gpt_template = OpenAiApi.got_open_ai.GetGptCompletion()\
		.get_template()\
		.append_static_context("system", "You role-play as the non-player-character. Impersonate the chracter and do not talk about the character 
			itself.")\
		.append_static_context("system", "This is the context of the world you live in: '{world_context}'.".format({"world_context": ""}))\
		.append_static_context("system", "The name of your character is '{name}'.
			The following is your character's life until now: '{life_events}'.
			This is your character's description (physical and characteristics, ambitions etc.): '{description}'"
			.format({"name": npcData.name, "life_events": "", "description": npcData.context}))\
		.append_static_context("system", "This is your current quest: '{quest_title}'. Description of the quest: '{quest_description}'.
			Quest condition for the reward for the player: '{quest_condition}'. Quest reward, if condition fulfilled: '{quest_reward}'.
			Do not give the quest to user unless he asks about your ambitions and goals or if you need something done."
			.format({'quest_title': "", 'quest_description': "", "quest_condition": "", "quest_reward": ""}))
		
	var history_data = self.chatHistory.get_history(npcData.id)
	if not history_data.is_empty():
		print("Appending history data: ", history_data)
		self._gpt_template.append_static_context("system", "If you already held any conversation with the user, the history of the conversation 
			now follows:")
		self._gpt_template.append_static_contexts(history_data)
		self._gpt_template.append_static_context("system", "The history of the conversation stops here.")
		
	self._gpt_template.append_static_context("system", "Rules: stay within the context of the game world and if the user asks you anything 
		outside of the domain of
		the gameworld, tell him or her that you do not know what that is. 

		Here are some example user inputs and your potential outputs:
		User: Hi! We have talked yesterday already and you had some quest that I have done for you, do you have any new quests for me today?
		You: Hej [PLAYER_NAME]! Indeed I do! I have lost [ITEM] in the forests north of the town, could you bring them back?
		You return my [ITEM] and I will reward you with [REWARD]!")
	
	print("This is accesing the private properties of the gpt_template, static context:")
	print(self._gpt_template._message_manager._static_context)
