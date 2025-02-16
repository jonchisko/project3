extends Node
class_name VelocityComponent


@export var max_speed = 500.0
@export var acceleration = 2000.0
@export var deacceleration = 2000.0

	
func move_in_direction(character_body: CharacterBody2D, direction: Vector2):
	var target_velocity = direction * self.max_speed
	var delta = self.get_process_delta_time()
	
	character_body.velocity.x = self._adjust_velocity(character_body.velocity.x, target_velocity.x, delta)
	character_body.velocity.y = self._adjust_velocity(character_body.velocity.y, target_velocity.y, delta)

	character_body.move_and_slide()


func _adjust_velocity(velocity_component: float, target_velocity_component: float, delta: float) -> float:
	if target_velocity_component < 0.0:
		velocity_component = max(velocity_component - self.acceleration * delta, target_velocity_component)
	elif target_velocity_component > 0.0:
		velocity_component = min(velocity_component + self.acceleration * delta, target_velocity_component)
	else:
		if velocity_component > 0:
			velocity_component = max(velocity_component - self.deacceleration * delta, 0.0)
		if velocity_component < 0:
			velocity_component = min(velocity_component + self.deacceleration * delta, 0.0)
	
	return velocity_component
