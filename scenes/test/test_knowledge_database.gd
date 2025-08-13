extends Node2D

@onready var kdb: KnowledgeDatabase = $KDB

enum GameAction {
	Owns,
	HasTrait,
	LocatedIn,
	InteractsWith,
	Gives,
	IsA,
	Wears,
	Completes,
	Kills,
	Damages,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	kdb.set_quest_done("clear_the_mines")
	var triplets = kdb.get_quest_triplets()
	# game_action_id: int, source_game_entity_id: String, target_object: String
	kdb.add_action(GameAction.IsA, "peter_rudar", "A big dude")
	var action_triplets = kdb.get_action_triplets()
	
	print(triplets)
	print(action_triplets)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
