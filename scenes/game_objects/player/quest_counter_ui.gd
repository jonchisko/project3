extends MarginContainer

@export var is_tutorial: bool = false

@onready var primary_counter: Label = %PrimaryCounter
@onready var secondary_counter: Label = %SecondaryCounter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.is_tutorial:
		self.visible = false

	QuestManager.quest_update.connect(self._on_quest_update)
	self._on_quest_update()


func _on_quest_update() -> void:
	primary_counter.text = "{v1}/{v2}".format({"v1": QuestManager.current_primary_quests_completed, "v2": QuestManager.all_primary_quests})
	secondary_counter.text = "{v1}/{v2}".format({"v1": QuestManager.current_secondary_quests_completed, "v2": QuestManager.all_secondary_quests})
