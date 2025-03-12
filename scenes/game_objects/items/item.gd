extends Node2D

@export var interactable_data: InteractableResource

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	self.sprite_2d.texture = self.interactable_data.visual.world_visual
