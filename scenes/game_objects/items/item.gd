extends Node2D
class_name Item

@export var interactable_data: InteractableResource:
	set(value): 
		if self.sprite_2d != null:
			self.sprite_2d.texture = value.visual.world_visual
			$Interactable.interactable_data = value
		interactable_data = value


@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	self.sprite_2d.texture = self.interactable_data.visual.world_visual
