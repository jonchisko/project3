extends Area2D
class_name InteractableDetector


signal interactable_entered(InteractableArea)
signal interactable_left()


func _on_area_entered(area: Area2D) -> void:
	var interactable_area = area as InteractableArea
	print("Area2D hit")
	print("Is interactable? ", interactable_area)
	if interactable_area == null:
		return
	
	interactable_entered.emit(interactable_area)


func _on_area_exited(area: Area2D) -> void:
	var interactable_area = area as InteractableArea
	print("Area2D left")
	print("Is interactable? ", interactable_area)
	if interactable_area == null:
		return

	interactable_left.emit(interactable_area)
