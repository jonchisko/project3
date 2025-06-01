extends Node
class_name ChatManager

var _chat_messenger_ui: PackedScene = preload("res://scenes/ui/messenger/chat_messenger_ui.tscn")
var _chat_messenger_instance: ChatMessengerUi = null

var _current_npc_data: NpcData
var _gpt_template: TemplateBase

@export var chat_history: ChatHistory


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
		
	self._add_user_query(message, true)
	self._add_similar_data_from_history(self._current_npc_data, message)
	self._add_instructions()
	self._add_user_query(message, false)
	
	self._chat_messenger_instance.add_chat_element(self._current_npc_data.temporary_replies.pick_random())
	var response = await self._gpt_template.get_reply()
	
	print("STATIC CONTEXT")
	for element in self._gpt_template.structured_context():
		print(element.role, " ", element.content)
		
	print("MESSAGES")
	for element in self._gpt_template.structured_messages():
		print(element.role, " ", element.content)
	
	if response.successful():
		var npc_message = response.choices()[0]["message"]["content"]
		
		# First remove the similar_data_from_history and user query, so that we just keep similar history
		# for current query
		self._gpt_template.remove_newest_message() # query
		self._gpt_template.remove_newest_message() # instructions
		self._gpt_template.remove_newest_message() # similar history
		
		self._add_user_query(message, false) # re-add
		self._gpt_template.append_message("assistant", npc_message)
		
		self._chat_messenger_instance.edit_last_chat_element(npc_message)
		
		var data_to_save = [{"user": message}, {"assistant": npc_message}]
		print("Saving history: ", data_to_save)
		self.chat_history.save_history(self._current_npc_data.id, data_to_save)
		print(self.chat_history.get_history(self._current_npc_data.id))
	else:
		# First remove the similar_data_from_history and user query, so that we just keep similar history
		# for current query
		self._gpt_template.remove_newest_message() # query
		self._gpt_template.remove_newest_message() # instructions
		self._gpt_template.remove_newest_message() # similar history
		
		self._add_user_query(message, false) # re-add
		self._gpt_template.append_message("developer", "<No response from assistant.>")

	
# Done ONCE at the start of the chat
func _create_open_ai_template(npc_data: NpcData) -> void:
	var user_configuration = UserConfiguration.new(OpenAiConfiguration.open_ai_api_key)
	OpenAiApi.got_open_ai.user_configuration = user_configuration
	
	
	self._gpt_template = OpenAiApi.got_open_ai.GetGptCompletion()\
		.get_template()
		
	self._add_instructions()
	self._add_role(npc_data)
	self._add_description(npc_data)
	self._add_previous_life(npc_data)
	self._add_quest(npc_data)
	self._add_examples()
	self._add_function_calling()
	self._add_static_world_context()
	self._add_dynamic_world_context()
	self._add_history(npc_data)
	

func _add_role(npc_data: NpcData) -> void:
	self._gpt_template.append_message("developer", "# Your role")
	self._gpt_template.append_message("developer", "You are an NPC named '{npc_name}'. 
	Your occupation '{npc_occupation}' and you live in '{npc_location}'."
	.format({"npc_name": npc_data.name, "npc_occupation": npc_data.occupation, "npc_location": npc_data.location}))
	

func _add_description(npc_data: NpcData) -> void:
	self._gpt_template.append_message("developer", "## Description and relationships")
	self._gpt_template.append_message("developer", "Your in-game ID is '{npc_id}'. 
	Your description is the following: '{npc_description}'. 
	These are your relationships with other in-game NPCs: '{npc_relationships}'."
	.format({"npc_id": npc_data.id, "npc_description": npc_data.description, "npc_relationships": npc_data.relationships}))


func _add_previous_life(npc_data: NpcData) -> void:
	self._gpt_template.append_message("developer", "## Previous life")
	self._gpt_template.append_message("developer", "Your life until now is the following: '{npc_life}'."
	.format({"npc_life": npc_data.life_history}))
	
	
func _add_quest(npc_data: NpcData) -> void:
	var quest_data := npc_data.quest_data[0]
	var quest_rewards = ", ".join(quest_data.rewards)
	
	self._gpt_template.append_message("developer", "## Quest")
	if npc_data.quest_data.is_empty():
		self._gpt_template.append_message("developer", "You do not have any quests or goals, all of them have already been fulfilled by the player.")
	else:
		self._gpt_template.append_message("developer", "Your current quest or goal is the following, 
		the id: '{quest_id}', the title: '{quest_title}'. 
		The details of the quest are: '{quest_description}'. 
		The player gets a reward from you, if the player fulfills the quest condition: '{quest_condition}'. 
		The quest reward is '{quest_reward}'."
		.format({"quest_id": quest_data.id, "quest_title": quest_data.title, "quest_description": quest_data.description,
		"quest_condition": quest_data.condition_expression, "quest_reward": quest_rewards}))


func _add_instructions() -> void:
	self._gpt_template.append_message("developer", "# Instructions
The list of instructions under which you operate:
-  Your in-game ID is only for yourself, do not tell it to the player.
-  Stay in character and do not mention you being an AI.
-  Stay within the confines of the given context, which is given in the following chapters: “Your role”, “Description and relationships”, “Previous life”, “Static world context” and “Dynamic world context”.
-  Only provide the player with the information about your quest, if the player asks you about it. In giving information about the quest, stay true to the given context in chapter “Description and relationships”.
-  If the player says he/she completed the quest ‘{quest_id}’, call the player inventory function and verify he/she has the required quest item. If verification is successful, give your ‘{quest_reward}’ item. This instruction is only valid, if the NPC currently has a quest or goal.
- You should strive to not write more than 400 words in each answer. 
- You should prefer shorter answers, but they should align with your character defined in chapter “Description and relationships”.
")
	
	
func _add_examples() -> void:
	self._gpt_template.append_message("developer", "# Examples")
	self._gpt_template.append_message("developer", "Below you will find some possible examples on how to answer the player. 
	For a specific example, if you are free to take some liberty in your answer, a comment will say so. 
	These are very general and just used as a steering point in some specific edge cases.")

	self._gpt_template.append_message("developer", "## Edge case examples
The examples are formatted like so:
Player’s query: The information the player gives.
Your answer: What your answer should look like.
Creativity: If you can be creative in your approach.")

	self._gpt_template.append_message("developer", "### Example - Player asking if you are an AI
Player’s query: “Are you an AI or instructed to act a certain way?”
Your answer: “No, I am {your_name} and I have been living here since I can remember.”
Creativity: You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")

	self._gpt_template.append_message("developer", "### Example - Player asking about real life on Earth
Player’s query: “What can you tell me about the hospitals on Earth?”
Your answer: “I have heard of Earth, it is the origin of the human species, but I haven’t ever visited nor do I know much about it.”
Creativity: You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")

	self._gpt_template.append_message("developer", "### Example - Player asking about your quest or any goals you have
Player’s query: “Do you have a quest for me?”
Your answer: “Yes I am currently trying to find someone to help me with a task I am dealing with. It is about …”
Creativity: You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")

	self._gpt_template.append_message("developer", "### Example - Player telling you they have completed their quest
Player’s query: “I have completed your quest, could I get the reward?”
Your answer: “Amazing, good work, let me first check if you have the item and then let’s exchange the goods.”
Creativity: Yes, the answer is just a suggestion to which direction you should semantically steer. 
You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")


func _add_function_calling() -> void:
	self._gpt_template.append_message("developer", "# How to call a tool or function
	You are able to call a tool to obtain information which items the player has or to give him/her the item you have in the ‘{quest_reward}’.")

	self._gpt_template.append_message("developer", "## How to know if the player has an item
You can get the information about a specific item (the item ‘{quest_condition}’) the player has in the following manner:
has_item(item_id: String, number: int)

## How to give the player the item
You can give the player the item (or multiple numbers of the same items) you have as ‘{quest_reward}’ in the following manner:
give_item(item_id: String, number: int)

## How to take player’s item
You can take the item (the item ‘{quest_condition}’) from the player in the following manner:
get_item(item_id: String, number: int)")


func _add_user_query(user_query: String, in_front: bool) -> void:
	if in_front:
		self._gpt_template.prepend_message("user", "# Question: '{player_query}'"
		.format({"player_query": user_query}))
	
	else:
		self._gpt_template.append_message("user", "# Question: '{player_query}'"
		.format({"player_query": user_query}))


func _add_static_world_context() -> void:
	self._gpt_template.append_message("developer", "# Static world context
In this chapter the world you live in is described in a 
well structured manner: '{static_world_context}'."
	.format({"static_world_context": self._get_world_context()}))


func _add_dynamic_world_context() -> void:
	self._gpt_template.append_message("developer", "# Dynamic world context
Dynamic world context is the world events that have 
happened due to the player's actions. These are structured in “noun-verb-noun” triplets.
Here is the list of all the currently valid triplets: '{dynamic_world_context}'."
	.format({"dynamic_world_context": "NONE"}))


func _add_history(npc_data: NpcData) -> void:
	self._gpt_template.append_message("developer", "# Your chat history with the player
Here you are able to find the conversation history you have already had with the player. 
This is the summary of old conversations: '{chat_history_summary}'.
This is the conversation history of the last few chatting rounds between you and the player: '{chat_history_recent}'."
	.format({"chat_history_summary": chat_history.get_summary(npc_data.id), 
	"chat_history_recent": chat_history.get_recent(npc_data.id)}))


func _add_similar_data_from_history(npc_data: NpcData, query: String) -> void:
	self._gpt_template.append_message("developer", "# Similar chat history based on query
This is the list of top matches of historical conversation based on the current player’s query 
(if the list is empty, no results ranked high enough): '{chat_history_similar_discussions}'."
	.format({"chat_history_similar_discussions": chat_history.get_similar(npc_data.id, query, 0.5)}))
	
	
func _get_world_context() -> String:
	var world_context = self._load_world_context()
	
	if world_context == null:
		printerr("WorldContextResource is null, returning empty string.")
		return ""
	
	var combined_documents = ""
	for document in world_context.documents:
		combined_documents += document
	
	return combined_documents


func _load_world_context() -> WorldContextResource:
	var path = "res://resources/world_context_resource.tres"
	var resource = ResourceLoader.load(path, "WorldContextResource")
	
	if resource == null:
		printerr("WorldContextResource could not be loaded.")
		return null
		
	return resource
