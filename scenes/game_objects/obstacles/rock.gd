extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_index = randi_range(0, 3)
	$Sprite2D.frame = random_index
	$Shadow.frame = random_index
