extends DataResource
class_name NpcData

@export var id: String = "NoNameId"
@export var name: String = "NoName"
@export_multiline var life_history: String = "NoNameLifeHistory"
@export var description: String = "NoNameDescription"
@export var relationships: Dictionary = {} # npc_id -> relationship_description String-String
@export var quest_data: Array[QuestResource] = []
@export var temporary_replies: Array[String] = ["Wait, I am thinking ..."]
@export var system_knowledge: Array[String] = []
