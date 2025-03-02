extends InteractableMenu


func _ready():
	self.ui_scene = preload("res://scenes/ui/interactables/interactable_items_menu/interactable_item_ui.tscn")
	self.container = %ItemContainer


func _selected_interactable_abstract(interactable: InteractableArea):
	self.interactables.erase(interactable)
	self._hide_menu()


func _on_button_pressed() -> void:
	var items = self.get_tree().get_nodes_in_group("interactable_item_ui")
	for item in items:
		var interactable_item_ui = item as InteractableItemUi
		if interactable_item_ui == null: continue
		
		interactable_item_ui.select_item()
		
