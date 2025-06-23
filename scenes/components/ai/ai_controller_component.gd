extends Node2D
class_name AiController


signal move_to(location: Vector2)


@export var update_frequency: float = 0.2

@onready var _patrol_timer: Timer = $PatrolTimer
@onready var _player_detector: Area2D = $PlayerDetector


var _player_reference: Node2D = null
var _patrol_origin: Vector2 = Vector2.ZERO
var _check_visibility: bool
var _stop_chase: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._player_reference = self.get_tree().get_first_node_in_group("player") as Node2D
	if self._player_reference == null:
		printerr("Player reference could not be obtained in AiControllerComponent.")
	
	self._patrol_origin = self.global_position
	self._check_visibility = false
	self._patrol_timer.wait_time = self.update_frequency


func _on_player_detector_area_entered(area: Area2D) -> void:
	if not area.get_parent() is Player:
		return
		
	self._check_visibility = true
	
	
func _on_player_detector_area_exited(area: Area2D) -> void:
	if not area.get_parent() is Player:
		return
		
	self._check_visibility = false
	
	
func _is_visible() -> bool:
	var space_state = self.get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(self.global_position, self._player_reference.global_position, 
		2, [self])
		
	var result = space_state.intersect_ray(query)
	return result.is_empty()
	


func _on_patrol_timer_timeout() -> void:
	if not self._stop_chase and self._check_visibility and self._is_visible():
		self.move_to.emit(self._player_reference.global_position)


func _on_stop_chasing_area_area_entered(area: Area2D) -> void:
	self._stop_chase = true


func _on_stop_chasing_area_area_exited(area: Area2D) -> void:
	self._stop_chase = false
