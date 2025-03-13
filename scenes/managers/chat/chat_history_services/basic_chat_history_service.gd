extends ChatHistoryService


var _chat_history_for_npcs: Dictionary = {} 
# {"npc_id1" : [{"assistant": "ssdasd"}, {"user": "asdda}, {"a": "sa}], "npc_id2" : [...]}


func get_history(npc_id: String) -> Array:
	if not self._chat_history_for_npcs.has(npc_id):
		return []
	return self._chat_history_for_npcs[npc_id]
	
	
func save_history(npc_id: String, chat: Array) -> void:
	if self._chat_history_for_npcs.has(npc_id):
		var data_array = self._chat_history_for_npcs[npc_id] as Array[Dictionary]
		data_array.append_array(chat)
	else:
		self._chat_history_for_npcs[npc_id] = chat
