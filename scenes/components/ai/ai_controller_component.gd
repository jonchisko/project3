extends Node2D
class_name AiController

# Patrolling, Searching, Chasing
# Patrolling -> Random locations withing some radius from given point. Go there, wait 1-3 secs, go next
# Searching -> when player out of detection range, go from chasing to searching -> go to
# last known position, wait there for 1-3 seconds and start patrolling
# chasing -> when player within detection range, start chasing to some distance, stay at that distance
# attacking done by the main script

enum BehaviourStat {
	Patrol,
	Search,
	Chase,
}

var _player_reference: Node2D = null
var _current_behaviour: BehaviourStat = BehaviourStat.Patrol
var _patrol_origin: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._player_reference = self.get_tree().get_first_node_in_group("player") as Node2D
	if self._player_reference == null:
		printerr("Player reference could not be obtained in AiControllerComponent.")
	
	self._patrol_origin = self.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
