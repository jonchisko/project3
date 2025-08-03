extends Area2D
class_name InteractableArea

@export var interactable_type: GameTypes.InteractableType = GameTypes.InteractableType.Item
var interactable_data: InteractableResource:
	set(value):
		interactable_data = value
		self._set_layer()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.interactable_data = self.get_parent().get("interactable_data")
	if self.interactable_data == null:
		printerr("Interactable data is null. No interactable data on parent?")
	
	self._set_layer()


# There must be a better way to do this
func _set_layer() -> void:
	match self.interactable_type:
		GameTypes.InteractableType.Item:
			self.collision_layer = 16
		GameTypes.InteractableType.Npc:
			self.collision_layer = 8
