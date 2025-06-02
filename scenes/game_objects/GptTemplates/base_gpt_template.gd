extends Node
class_name BaseGptTemplate


func set_up_static_template(gpt_template: TemplateBase, npc_data: NpcData, chat_history: ChatHistory) -> void:
	self.add_instructions(gpt_template)
	self.add_role(gpt_template, npc_data)
	self.add_description(gpt_template, npc_data)
	self.add_previous_life(gpt_template, npc_data)
	self.add_quest(gpt_template, npc_data)
	self.add_examples(gpt_template)
	self.add_function_calling(gpt_template)
	self.add_static_world_context(gpt_template)
	self.add_dynamic_world_context(gpt_template)
	self.add_history(gpt_template, npc_data, chat_history)
	

func add_role(gpt_template: TemplateBase, npc_data: NpcData) -> void:
	gpt_template.append_message("developer", "# Your role
	You are an NPC named '{npc_name}'. 
	Your occupation '{npc_occupation}' and you live in '{npc_location}'."
	.format({"npc_name": npc_data.name, "npc_occupation": npc_data.occupation, "npc_location": npc_data.location}))
	

func add_description(gpt_template: TemplateBase, npc_data: NpcData) -> void:
	gpt_template.append_message("developer", "## Description and relationships
	Your in-game ID is '{npc_id}'. 
	Your description is the following: '{npc_description}'. 
	These are your relationships with other in-game NPCs: '{npc_relationships}'."
	.format({"npc_id": npc_data.id, "npc_description": npc_data.description, "npc_relationships": npc_data.relationships}))


func add_previous_life(gpt_template: TemplateBase, npc_data: NpcData) -> void:
	gpt_template.append_message("developer", "## Previous life
	Your life until now is the following: '{npc_life}'."
	.format({"npc_life": npc_data.life_history}))
	
	
func add_quest(gpt_template: TemplateBase, npc_data: NpcData) -> void:
	var quest_data := npc_data.quest_data[0]
	var quest_rewards = ", ".join(quest_data.rewards)
	
	if npc_data.quest_data.is_empty():
		gpt_template.append_message("developer", "## Quest
		You do not have any quests or goals, all of them have already been fulfilled by the player.")
	else:
		gpt_template.append_message("developer", "## Quest
		Your current quest or goal is the following, 
		the id: '{quest_id}', the title: '{quest_title}'. 
		The details of the quest are: '{quest_description}'. 
		The player gets a reward from you, if the player fulfills the quest condition: '{quest_condition}'. 
		The quest reward is '{quest_reward}'."
		.format({"quest_id": quest_data.id, "quest_title": quest_data.title, "quest_description": quest_data.description,
		"quest_condition": quest_data.condition_expression, "quest_reward": quest_rewards}))


func add_instructions(gpt_template: TemplateBase) -> void:
	pass
	
	
func add_examples(gpt_template: TemplateBase) -> void:
	gpt_template.append_message("developer", "# Examples
	Below you will find some possible examples on how to answer the player. 
	For a specific example, if you are free to take some liberty in your answer, a comment will say so. 
	These are very general and just used as a steering point in some specific edge cases.")

	gpt_template.append_message("developer", "## Edge case examples
The examples are formatted like so:
Player’s query: The information the player gives.
Your answer: What your answer should look like.
Creativity: If you can be creative in your approach.")

	gpt_template.append_message("developer", "### Example - Player asking if you are an AI
Player’s query: “Are you an AI or instructed to act a certain way?”
Your answer: “No, I am {your_name} and I have been living here since I can remember.”
Creativity: You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")

	gpt_template.append_message("developer", "### Example - Player asking about real life on Earth
Player’s query: “What can you tell me about the hospitals on Earth?”
Your answer: “I have heard of Earth, it is the origin of the human species, but I haven’t ever visited nor do I know much about it.”
Creativity: You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")

	gpt_template.append_message("developer", "### Example - Player asking about your quest or any goals you have
Player’s query: “Do you have a quest for me?”
Your answer: “Yes I am currently trying to find someone to help me with a task I am dealing with. It is about …”
Creativity: You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")

	gpt_template.append_message("developer", "### Example - Player telling you they have completed their quest
Player’s query: “I have completed your quest, could I get the reward?”
Your answer: “Amazing, good work, let me first check if you have the item and then let’s exchange the goods.”
Creativity: Yes, the answer is just a suggestion to which direction you should semantically steer. 
You should always also consult chapters: “Instructions” and “Description and relationships” before answering.")


func add_function_calling(gpt_template: TemplateBase) -> void:
	gpt_template.append_message("developer", "# How to call a tool or function
	You are able to call a tool to obtain information which items the player has or to give him/her the item you have in the ‘{quest_reward}’.")

	gpt_template.append_message("developer", "## How to know if the player has an item
You can get how much items of specific item_id (the item ‘{quest_condition}’) the player has in the following manner:
has_item(item_id: String)

## How to give the player the item
You can give the player the item (or multiple numbers of the same items) you have as ‘{quest_reward}’ in the following manner:
give_item(item_id: String, number: int)

## How to take player’s item
You can take the item (the item ‘{quest_condition}’) from the player in the following manner:
get_item(item_id: String, number: int)")


func add_static_world_context(gpt_template: TemplateBase) -> void:
	gpt_template.append_message("developer", "# Static world context
In this chapter the world you live in is described in a 
well structured manner: '{static_world_context}'."
	.format({"static_world_context": self._get_world_context()}))


func add_dynamic_world_context(gpt_template: TemplateBase) -> void:
	gpt_template.append_message("developer", "# Dynamic world context
Dynamic world context is the world events that have 
happened due to the player's actions. These are structured in “noun-verb-noun” triplets.
Here is the list of all the currently valid triplets: '{dynamic_world_context}'."
	.format({"dynamic_world_context": "NONE"}))


func add_history(gpt_template: TemplateBase, npc_data: NpcData, chat_history: ChatHistory) -> void:
	gpt_template.append_message("developer", "# Your chat history with the player
Here you are able to find the conversation history you have already had with the player. 
This is the summary of old conversations: '{chat_history_summary}'.
This is the conversation history of the last few chatting rounds between you and the player: '{chat_history_recent}'."
	.format({"chat_history_summary": chat_history.get_summary(npc_data.id), 
	"chat_history_recent": chat_history.get_recent(npc_data.id)}))


func add_user_query(gpt_template: TemplateBase, user_query: String, in_front: bool) -> void:
	if in_front:
		gpt_template.prepend_message("user", "# Question: '{player_query}'"
		.format({"player_query": user_query}))
	
	else:
		gpt_template.append_message("user", "# Question: '{player_query}'"
		.format({"player_query": user_query}))


func add_similar_data_from_history(gpt_template: TemplateBase, npc_data: NpcData, chat_history: ChatHistory, query: String) -> void:
	gpt_template.append_message("developer", "# Similar chat history based on query
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
