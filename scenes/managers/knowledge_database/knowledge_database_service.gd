extends Node
class_name KDBService


# Source of truth for the enum is in Rust /rust_project_3/src/knowledge_database.rs
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

@onready var kdb_rust: KnowledgeDatabase = $KDBRust


func get_triplet_data_text() -> String:
	var action_triplets = self.kdb_rust.get_action_triplets()
	var quest_triplets = self.kdb_rust.get_quest_triplets()
	var ownership_triplets = self.kdb_rust.get_ownership_triplets()
	
	return "Data information triplets:\n{at}\n{qt}\n{ot}".format({"at": action_triplets, "qt": quest_triplets, "ot": ownership_triplets})


func add_action(game_action_id: GameAction, source_game_entity: String, target_object: String) -> bool:
	if not self._verify_entity_id(source_game_entity):
		return false
	
	return self.kdb_rust.add_action(game_action_id, source_game_entity, target_object)


func set_quest_to_done(quest_id: String) -> bool:
	if not QuestManager.quest_exists(quest_id):
		printerr("Quest id '{quest_id}' does not exist.".format({"quest_id": quest_id}))
		return false

	return self.kdb_rust.set_quest_done(quest_id)
	

func update_ownership_quantity(game_item_id: String, game_entity_id: String, amount: int) -> bool:
	if not self._verify_ids(game_item_id, game_entity_id):
		return false
	
	return self.kdb_rust.update_ownership_quantity(game_item_id, game_entity_id, amount)


func get_ownership_quantity(game_item_id: String, game_entity_id: String) -> int:
	if not self._verify_ids(game_item_id, game_entity_id):
		return -1
	
	return self.kdb_rust.get_ownership_quantity(game_item_id, game_entity_id)
	
	
func _verify_ids(game_item_id: String, game_entity_id: String) -> bool:
	return self._verify_game_item_id(game_item_id) and self._verify_entity_id(game_entity_id)
	
	
func _verify_game_item_id(game_item_id: String) -> bool:
	if not ResourceDictionary.item_ids.has(game_item_id):
		printerr("Game item '{game_item_id}' does not exist.".format({"game_item_id": game_item_id}))
		return false
	return true
	
	
func _verify_entity_id(game_entity_id: String) -> bool:
	if not ResourceDictionary.npc_ids.has(game_entity_id) and game_entity_id != "player" and game_entity_id != "enemy_knight":
		printerr("Game entity '{game_entity_id}' does not exist.".format({"game_entity_id": game_entity_id}))
		return false
	return true
