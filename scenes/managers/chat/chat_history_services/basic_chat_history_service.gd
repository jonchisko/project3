extends ChatHistoryService


var _chat_history_for_npcs: Dictionary = {} 
# {"npc_id1" : [MessageNpc, MessagePlayer, MessageNpc], "npc_id2" : [...]}


func get_history(npc_id: String) -> Array:
	if not self._chat_history_for_npcs.has(npc_id):
		return []
	return self._chat_history_for_npcs[npc_id].duplicate()
	
	
func save_history(npc_id: String, chat: Array) -> void:
	if self._chat_history_for_npcs.has(npc_id):
		var data_array = self._chat_history_for_npcs[npc_id] as Array[Message]
		data_array.append_array(chat)
	else:
		self._chat_history_for_npcs[npc_id] = chat.duplicate()


func get_all_data() -> Dictionary:
	return self._chat_history_for_npcs.duplicate()
	
	
func set_all_data(data: Dictionary) -> void:
	self._chat_history_for_npcs = data
