extends Node
class_name EnemyMineManager

@export var EnemyKnights: Array[KnightNpc] 

var _knights_killed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._knights_killed = 0
	
	for knight in self.EnemyKnights:
		knight.knight_death.connect(self._on_knight_death)


func _on_knight_death() -> void:
	self._knights_killed += 1
	
	if self._knights_killed == self.EnemyKnights.size():
		print("Adding action in ENEMY MINE MANAGER")
		KDBService.add_action(KDBService.GameAction.Completes, "player", "clearing of knights in the mine.")
