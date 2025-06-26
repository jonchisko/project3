extends Node
class_name SteeringBehaviour

@export var knight: KnightNpc
@export var behaviours: Array[SteeringBehaviourBase] = []

var _interests: PackedFloat32Array
var _dangers: PackedFloat32Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._interests = PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	self._dangers = PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	
	
func get_direction() -> Vector2:
	var result: Vector2 = Vector2.ZERO
	
	for behaviour in self.behaviours:
		behaviour.get_interest_map(self.knight, self._interests)
		behaviour.get_danger_map(self.knight, self._dangers)

	var mask := PackedByteArray([true, true, true, true, true, true, true, true])
	
	var sorted = self._dangers.duplicate()
	sorted.sort()
	var threshold_danger = sorted[3]
	
	var angle_ratio = 2 * PI / self._interests.size()
	var max_interest = 0.0
	for i in range(0, self._interests.size()):
		if self._dangers[i] <= threshold_danger and self._interests[i] >= max_interest:
			result = Vector2.RIGHT.rotated(angle_ratio * i)
			max_interest = self._interests[i]

	self._interests = PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
	self._dangers = PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])

	return result
