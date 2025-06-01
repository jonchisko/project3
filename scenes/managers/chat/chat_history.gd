extends Node
class_name ChatHistory


@export var chatHistoryService: ChatHistoryService


func get_history(npc_id: String) -> Array:
	return self.chatHistoryService.get_history(npc_id)
	
	
func save_history(npc_id: String, chat: Array) -> void:
	self.chatHistoryService.save_history(npc_id, chat)


func get_summary(npc_id: String) -> Array:
	return []
	

func get_similar(npc_id: String, query: String, threshold: float = 0.5) -> Array:
	return []


func get_recent(npc_id: String) -> Array:
	return self.get_history(npc_id)
