extends Node

@export var interactable_detector: InteractableDetector
@export var ui_manager: InteractableMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_detector.interactable_entered.connect(self._on_interactable_area_entered)
	interactable_detector.interactable_left.connect(self._on_interactable_area_exited)
	self.ui_manager.interactable_picked.connect(self._on_elements_picked)


func _on_element_picked(element: InteractableArea):
	GameEvents.interact_with_interactable.emit(element)


func _on_interactable_area_entered(interactable_area: InteractableArea) -> void:
	self.ui_manager.add_interactable(interactable_area)


func _on_interactable_area_exited(interactable_area: InteractableArea) -> void:
	self.ui_manager.remove_interactable(interactable_area)
