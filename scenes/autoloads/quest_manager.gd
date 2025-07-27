extends Node

signal quest_update

@export var quests: Array[QuestResource]
var completed_quests: Array[QuestResource]


var all_necessary_quests_completed: bool:
	get:
		return self.current_primary_quests_completed == self.all_primary_quests


var current_primary_quests_completed: int = 0:
	get:
		return current_primary_quests_completed


var all_primary_quests: int = 0:
	get:
		return all_primary_quests


var current_secondary_quests_completed: int = 0:
	get:
		return current_secondary_quests_completed

var all_secondary_quests: int = 0:
	get:
		return all_secondary_quests


func _ready() -> void:
	var primary_quests_count: int = 0
	var secondary_quests_count: int = 0
	
	for quest in self.quests:
		if quest.primary_quest:
			primary_quests_count += 1
		else:
			secondary_quests_count += 1
	
	self.all_primary_quests = primary_quests_count
	self.all_secondary_quests = secondary_quests_count
	
	GameEvents.quest_done.connect(self._on_quests_completed)
	

func _on_quests_completed(quest_id: String) -> void:
	var finished_quest: QuestResource = null
	
	for quest in self.quests:
		if quest.id == quest_id:
			finished_quest = quest
			break
	
	if finished_quest != null:
		self.quests.erase(finished_quest)
	else:
		printerr("Could not find quest '{quest}' in the non finished quests array.".format({"quest": quest_id}))
	
	if finished_quest.primary_quest:
		self.current_primary_quests_completed += 1
	else:
		self.current_secondary_quests_completed += 1
	
	self.completed_quests.push_back(finished_quest)
	
	self.quest_update.emit()
