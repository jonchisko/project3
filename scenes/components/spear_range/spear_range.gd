extends Node2D
class_name SpearRange


@export var pixel_size: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scale_factor = self.pixel_size / $Sprite2D.get_rect().size.x
	self.scale = Vector2(scale_factor, scale_factor)


func _on_visibility_changed() -> void:
	var scale_factor = self.pixel_size / $Sprite2D.get_rect().size.x
	self.scale = Vector2(scale_factor, scale_factor)
	print(scale_factor, self.pixel_size, self.scale)
	print($Sprite2D.get_rect().size)
	print($Sprite2D.get_rect().size * self.scale)
