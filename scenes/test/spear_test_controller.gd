extends Node2D


var spear_object: PackedScene = preload("res://scenes/game_objects/items/spear/spear_object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		#print(self.get_viewport().get_mouse_position())
		
		var instantiated = self.spear_object.instantiate() as SpearObject
		
		instantiated.global_position = self.position
		instantiated.target_position = $"../TargetPosition".position
		
		self.add_child(instantiated)
		instantiated.owner = self
		
		#instantiated.target = self.get_viewport().get_mouse_position()
