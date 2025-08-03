extends Task


func _setup(tutorial_context: TutorialMap) -> void:
	var item = self._spawned_objects[0] as Item
	item.interactable_data = ResourceDictionary.ResourceIdToResource["health_potion"]
	tutorial_context.player_inventory.item_picked_up.connect(self._item_picked_up)


func _item_picked_up(_item_id: String) -> void:
	self._complete_task()
