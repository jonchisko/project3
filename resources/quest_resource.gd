extends Resource
class_name QuestResource

@export var id: String = ""
@export var primary_quest: bool = false
@export var title: String = ""
@export var description: String = ""
@export var condition_expression: String = ""
@export var rewards: Array = []


func get_reward() -> String:
	if self.rewards.size() > 0:
		return self.rewards[0]
	else:
		return ""
