extends SteeringBehaviourBase
class_name AvoidingBehaviour

@export var obstacle_range: float = 20.0

func get_danger_map(knight: KnightNpc, dangers: PackedFloat32Array) -> void:
	var current_direction = Vector2.ZERO
	var angle_part = 2 * PI / dangers.size()
	var space_state = knight.get_world_2d().direct_space_state
	
	var obstacle_direction = Vector2.ZERO
	
	for i in range(0, dangers.size()):
		current_direction = Vector2.RIGHT.rotated(angle_part * i)
		var max_alignment_value = 0.0
		for obstacle in knight.nearby_obstacles:
			var distance = (-knight.global_position + obstacle.global_position).length()
			if distance >= self.obstacle_range:
				continue
			obstacle_direction = (-knight.global_position + obstacle.global_position).normalized()
			var alignment_value = clampf(current_direction.dot(obstacle_direction)/(distance*0.5), 0.0, 1.0)
			if alignment_value >= max_alignment_value:
				max_alignment_value = alignment_value
				
		dangers[i] = max_alignment_value
