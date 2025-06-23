extends SteeringBehaviourBase
class_name ChasingBehaviour


func get_interest_map(knight: KnightNpc, interests: PackedFloat32Array) -> void:
	var vector_of_intrest: Vector2 = (- knight.global_position + knight._navigation_agent_2d.get_next_path_position()).normalized()
	var current_direction = Vector2.ZERO
	var angle_part = 2 * PI / interests.size()
	var alignment_score = 0.0
	
	for i in range(0, interests.size()):
		current_direction = Vector2.RIGHT.rotated(angle_part * i)
		alignment_score = clampf(vector_of_intrest.dot(current_direction), 0.0, 1.0)

		if interests[i] < alignment_score:
			interests[i] = alignment_score
