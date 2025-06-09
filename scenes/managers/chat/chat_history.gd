extends Node
class_name ChatHistory


@export var chatHistoryService: ChatHistoryService


var max_last_exchanges: int = 5:
	set(value):
		max_last_exchanges = clamp(value, 1, 10)


var max_similar_results: int = 10:
	set(value):
		max_similar_results = clamp(value, 1, 20)


var threshold_similar_results: float = 0.6:
	set(value):
		threshold_similar_results = clampf(value, 0.0, 1.0)


func get_history(npc_id: String) -> Array:
	# History is stored in pairs assistant, user, so if you want just last exachange, you still need to get 
	# the last two elements
	var history = self.chatHistoryService.get_history(npc_id)
	return history.slice(-self.max_last_exchanges * 2, history.size())
	
	
func save_history(npc_id: String, chat: Array) -> void:
	self.chatHistoryService.save_history(npc_id, chat)


func get_summary(npc_id: String) -> Array:
	return []
	

func get_similar(npc_id: String, query: String) -> Array:
	return []


func get_recent(npc_id: String) -> Array:
	return self.get_history(npc_id)
