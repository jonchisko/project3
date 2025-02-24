extends InteractableMenu

@onready var item_container: VBoxContainer = %ItemContainer

var _ui_item_scene: PackedScene = preload("res://scenes/ui/interactables/interactable_items_menu/interactable_item_ui.tscn")


func add_interactable(interactable: InteractableArea):
	var item_ui = self._ui_item_scene.instantiate() as InteractableItemUi
	self.item_container.add_child(item_ui)
	
	var item_data = interactable.interactable_data.data as ItemData
	if item_data == null:
		printerr("Item data is null, because interactable is not ItemData, but should be. 
		Means the physical layer masks are incorrect.")
		
	item_ui.set_data(interactable.interactable_data.visual.icon, item_data.name)
	item_ui.selected.connect(self._on_selected_item.bind(interactable))
	
	self.interactables[interactable] = item_ui


func remove_interactable(interactable: InteractableArea):
	if not self.interactables.has(interactable):
		return
		
	var item_ui = self.interactables[interactable]
	item_ui.remove_item()
	self.interactables.erase(interactable)


func _on_selected_item(interactable: InteractableArea):
	self.interactables.erase(interactable)
	interactable_picked.emit(interactable)


func _on_button_pressed() -> void:
	var items = self.get_tree().get_nodes_in_group("interactable_item_ui")
	for item in items:
		var interactable_item_ui = item as InteractableItemUi
		if interactable_item_ui == null: continue
		
		interactable_item_ui.select_item()
		
