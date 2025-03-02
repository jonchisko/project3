extends Control
class_name InteractableMenu


signal interactable_picked(interactable: InteractableArea)

var interactables: Dictionary
var ui_scene: PackedScene
var container: VBoxContainer


func _selected_interactable_abstract(interactable: InteractableArea):
	pass


func show_interactable(interactable: InteractableArea):
	var interactable_ui = self.ui_scene.instantiate() as InteractableUiBase
	self.container.add_child(interactable_ui)
	
	var interactable_data: DataResource = interactable.interactable_data.data
		
	interactable_ui.set_data(interactable.interactable_data.visual.icon, interactable_data.name)
	interactable_ui.selected.connect(self._on_selected_interactable.bind(interactable))
	
	self.interactables[interactable] = interactable_ui
	
	if self.interactables.size() >= 1:
		self.visible = true
	

func hide_interactable(interactable: InteractableArea):
	if self.interactables.size() >= 1:
		if self.interactables.has(interactable):
			var interactable_ui = self.interactables[interactable] as InteractableUiBase
			interactable_ui.remove_item()
			self.interactables.erase(interactable)
	self._hide_menu()


func _on_selected_interactable(interactable: InteractableArea):
	self._selected_interactable_abstract(interactable)
	self.interactable_picked.emit(interactable)


func _hide_menu():
	if self.interactables.size() < 1:
		self.visible = false
