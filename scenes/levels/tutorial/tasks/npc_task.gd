extends Task


func _setup(tutorial_context: TutorialMap) -> void:
	var npc_data = ResourceDictionary.ResourceIdToResource["bojan_kovač"]
	var npc = self._spawned_objects[0] as Npc
	npc.interactable_data = npc_data
	tutorial_context.chat_manager.chat_closed.connect(self._on_finished_chat)


func _on_finished_chat() -> void:
	self._complete_task()
