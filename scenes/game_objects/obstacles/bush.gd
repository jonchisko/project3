extends Node2D


@export var bush_sprites: Sprite2D
@export var bush_shadows_sprites: Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var frame = randi_range(0, 3)
	self.bush_sprites.frame = frame
	self.bush_shadows_sprites.frame = frame
