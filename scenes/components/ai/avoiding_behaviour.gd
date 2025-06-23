extends SteeringBehaviourBase
class_name AvoidingBehaviour

@export var obstacle_range: float = 110.0

func get_danger_map(knight: KnightNpc, dangers: PackedFloat32Array) -> void:
	var current_direction = Vector2.ZERO
	var angle_part = 2 * PI / dangers.size()
	var space_state = knight.get_world_2d().direct_space_state
	
	var obstacles: Array[Vector2] = []
	
	for i in range(0, dangers.size()):
		current_direction = Vector2.RIGHT.rotated(angle_part * i)
		var query = PhysicsRayQueryParameters2D.create(
			knight.global_position, 
			knight.global_position + self.obstacle_range * current_direction, 
			knight.collision_mask, 
			[knight])
		
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			dangers[i] = 1.0
