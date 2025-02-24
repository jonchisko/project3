extends Control
class_name InteractableMenu


signal interactable_picked(interactable: InteractableArea)

var interactables: Dictionary


func add_interactable(interactable: InteractableArea):
	if self.interactables.size() >= 1:
		self.visible = true
	

func remove_interactable(interactable: InteractableArea):
	if self.interactables.size() < 1:
		self.visible = false
