extends Node
class_name BaseGptTemplate


func add_instructions(gpt_template: TemplateBase) -> void:
	pass


func add_player_query(gpt_template: TemplateBase, user_query: String, in_front: bool) -> void:
	pass


func add_similar_data_from_history(gpt_template: TemplateBase, npc_data: NpcData, chat_history: ChatHistory, query: String) -> void:
	pass


func set_up_static_template(gpt_template: TemplateBase, npc_data: NpcData, chat_history: ChatHistory) -> void:
	self.add_instructions(gpt_template)
	
	var static_template: String = ""
	static_template += self._add_role(npc_data)
	static_template += self._add_description(npc_data)
	static_template += self._add_previous_life(npc_data)
	static_template += self._add_quest(npc_data)
	static_template += self._add_examples()
	static_template += self._add_function_calling()
	static_template += self._add_static_world_context()
	static_template += self._add_dynamic_world_context()
	static_template += self._add_history(npc_data, chat_history)
	
	self._add_template_to_gpt(gpt_template, static_template)


func _add_template_to_gpt(gpt_template: TemplateBase, template: String) -> void:
	pass


func _add_role(npc_data: NpcData) -> String:
	return ""
	

func _add_description(npc_data: NpcData) -> String:
	return ""


func _add_previous_life(npc_data: NpcData) -> String:
	return ""
	
	
func _add_quest(npc_data: NpcData) -> String:
	return ""
	
	
func _add_examples() -> String:
	return ""
	

func _add_function_calling() -> String:
	return ""


func _add_static_world_context() -> String:
	return ""


func _add_dynamic_world_context() -> String:
	return ""


func _add_history(npc_data: NpcData, chat_history: ChatHistory) -> String:
	return ""

	
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
