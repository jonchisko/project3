extends Node2D

@onready var kdb: KnowledgeDatabase = $KDB


# Called when the node enters the scene tree for the first time.
func _ready():
	kdb.set_quest_done("clear_the_mines")
	var triplets = kdb.get_quest_triplets()
	print(triplets)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
