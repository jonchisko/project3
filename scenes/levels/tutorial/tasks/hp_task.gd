extends Task


func _setup(tutorial_context: TutorialMap) -> void:
	tutorial_context.player_inventory.item_used.connect(self._item_used)


func _item_used(item_id: String) -> void:
	if item_id == "health_potion":
		self._complete_task()
