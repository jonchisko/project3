extends Node
class_name ChatHistory


@export var chatHistoryService: ChatHistoryService


func get_history(npc_id: String) -> Array:
	return self.chatHistoryService.get_history(npc_id)
	
	
func save_history(npc_id: String, chat: Array) -> void:
	self.chatHistoryService.save_history(npc_id, chat)
