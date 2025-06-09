extends BaseGptTemplate
class_name LooseGptTemplate


func add_instructions(gpt_template: TemplateBase) -> void:
	pass


func add_player_query(gpt_template: TemplateBase, user_query: String, in_front: bool) -> void:
	if in_front:
		gpt_template.prepend_message("user", "Player's query: {player_query}"
		.format({"player_query": user_query}))
	else:
		gpt_template.append_message("user", "Player's query: {player_query}"
		.format({"player_query": user_query}))


func add_similar_data_from_history(gpt_template: TemplateBase, npc_data: NpcData, chat_history: ChatHistory, query: String) -> void:
	gpt_template.append_message("developer", "This is the list of top matches of historical conversation based on the current player’s query 
(if the list is empty, no results ranked high enough): {chat_history_similar_discussions}"
	.format({"chat_history_similar_discussions": chat_history.get_similar(npc_data.id, query)}))


func _add_template_to_gpt(gpt_template: TemplateBase, template: String) -> void:
	gpt_template.append_message("developer", template)


func _add_role(npc_data: NpcData) -> String:
	return "You are an NPC named {npc_name}. Your occupation is {npc_occupation} and you live in {npc_location}."\
	.format({"npc_name": npc_data.name, "npc_occupation": npc_data.occupation, "npc_location": npc_data.location})
	

func _add_description(npc_data: NpcData) -> String:
	return "Your in-game ID is {npc_id}. Your description is the following {npc_description}. 
	These are your relationships with other NPCs: {npc_relationships}."\
	.format({"npc_id": npc_data.id, "npc_description": npc_data.description, "npc_relationships": npc_data.relationships})


func _add_previous_life(npc_data: NpcData) -> String:
	return "Your life until now is the following: {npc_life}."\
	.format({"npc_life": npc_data.life_history})
	
	
func _add_quest(npc_data: NpcData) -> String:
	var quest_data := npc_data.quest_data[0]
	var quest_rewards = ", ".join(quest_data.rewards)
	
	if npc_data.quest_data.is_empty():
		return "You do not have any quests or goals, all of them have already been fulfilled by the player."
	else:
		return "Your current quest or goal is {quest_id}, the title {quest_title}. The quest is 
		about {quest_description}. The player gets a reward from you, if the player fulfills the quest condition: {quest_condition}.
		The quest reward in the fulfillment case is {quest_reward}."\
		.format({"quest_id": quest_data.id, "quest_title": quest_data.title, "quest_description": quest_data.description,
		"quest_condition": quest_data.condition_expression, "quest_reward": quest_rewards})
	
	
func _add_examples() -> String:
	return ""
	

func _add_function_calling() -> String:
	return ""


func _add_static_world_context() -> String:
	return "The world you live in is described in a 
well structured manner: {static_world_context}."\
	.format({"static_world_context": self._get_world_context()})


func _add_dynamic_world_context() -> String:
	return "You live in a forever changing world. Dynamic world context is the world events that have 
happened due to the player's actions. Here is the list of all the currently valid 
facts: {dynamic_world_context}."\
	.format({"dynamic_world_context": "NONE"})


func _add_history(npc_data: NpcData, chat_history: ChatHistory) -> String:
	return "Here you are able to find the conversation history you have already had with the player.
	The summary of your conversation is: {chat_history_summary}.
	The conversation of your last few chatting rounds is {chat_history_recent}."\
	.format({"chat_history_summary": chat_history.get_summary(npc_data.id), 
	"chat_history_recent": chat_history.get_recent(npc_data.id)})
