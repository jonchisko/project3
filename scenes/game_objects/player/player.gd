extends CharacterBody2D

@onready var _velocity_component: VelocityComponent = $VelocityComponent

func _physics_process(delta: float) -> void:
	var direction = self._get_direction()
	self._velocity_component.move_in_direction(self, direction)
	
	
func _get_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1	
		
	return direction.normalized()
