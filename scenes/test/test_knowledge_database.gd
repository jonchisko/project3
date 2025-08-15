extends Node2D

func _ready():
	self._quest_tests()
	self._ownership_tests()
	self._action_tests()


func _quest_tests():
	self._set_valid_quest_to_done_expect_success()
	self._set_done_quest_to_done_expect_failure()
	self._set_nonvalid_quest_to_done_expect_error()
	self._quest_visualizer()


func _ownership_tests():
	self._update_ownership_of_existing_item_npc_expect_success()
	self._update_ownership_of_non_existing_item_expect_error()
	self._update_ownership_of_non_existing_entity_expect_error()
	self._update_ownership_twice_expect_success()
	self._ownership_triplets_visualizer()
	

func _action_tests():
	self._verify_all_actions_can_be_used_expect_success()
	self._add_non_existing_action_expect_error()
	self._add_action_non_existing_entity_expect_error()
	self._actions_triplets_visualizer()


func _set_valid_quest_to_done_expect_success():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	var result = kdb.set_quest_done("get_book_wotlica")
	
	# Assert
	assert(result, "Update should succeed and be true, but it is not.")
	assert(kdb.get_quest_triplets().contains("completes"), "At least one completed quest should be present, but none was.")
	
	self.remove_child(kdb)


func _set_done_quest_to_done_expect_failure():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	kdb.set_quest_done("get_book_wotlica")
	
	# Act
	var result = kdb.set_quest_done("get_book_wotlica")
	
	# Assert
	assert(not result, "Second update should fail and be false, but it is not.")
	self.remove_child(kdb)


func _set_nonvalid_quest_to_done_expect_error():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	var result = kdb.set_quest_done("i_dont_exist")
	
	# Assert
	assert(not result, "Update should fail and be false due to non-existing quest, but the result is true.")
	# Spaces to ensure it looks for this exact word
	assert(not kdb.get_quest_triplets().contains(" completes "), "No completed quest should be present, but at least one was.")
	self.remove_child(kdb)


func _quest_visualizer():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	kdb.set_quest_done("clear_the_mines")
	kdb.set_quest_done("find_robid_core")
	
	# Assert
	print(kdb.get_quest_triplets())
	self.remove_child(kdb)


func _update_ownership_of_existing_item_npc_expect_success():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	var result = kdb.update_ownership_quantity("health_potion", "peter_rudar", 1)
	
	# Assert
	assert(result, "Update should succeed, but hasn't")
	assert(kdb.get_ownership_quantity("health_potion", "peter_rudar") == 1, "Quantity should be 1")
	self.remove_child(kdb)


func _update_ownership_of_non_existing_item_expect_error():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	var result = kdb.update_ownership_quantity("i_dont_exist", "peter_rudar", 1)
	
	# Assert
	assert(not result, "Update should succeed, but hasn't")
	self.remove_child(kdb)


func _update_ownership_of_non_existing_entity_expect_error():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	var result = kdb.update_ownership_quantity("health_potion", "i_dont_exist", 1)
	
	# Assert
	assert(not result, "Update should succeed, but hasn't")
	self.remove_child(kdb)


func _update_ownership_twice_expect_success():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	kdb.update_ownership_quantity("health_potion", "peter_rudar", 1)
	var current_amount = kdb.get_ownership_quantity("health_potion", "peter_rudar")
	var result = kdb.update_ownership_quantity("health_potion", "peter_rudar", current_amount + 1)
	
	# Assert
	assert(result, "Update should succeed, but hasn't")
	assert(kdb.get_ownership_quantity("health_potion", "peter_rudar") == 2, "Quantity should be 2")
	self.remove_child(kdb)
	

func _ownership_triplets_visualizer():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	kdb.update_ownership_quantity("health_potion", "peter_rudar", 1)
	kdb.update_ownership_quantity("robid_core", "player", 3)
	
	# Assert
	print(kdb.get_ownership_triplets())
	self.remove_child(kdb)


func _verify_all_actions_can_be_used_expect_success():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	kdb.add_action(KnowledgeDatabaseService.GameAction.Owns, "peter_rudar", "a tree")
	kdb.add_action(KnowledgeDatabaseService.GameAction.HasTrait, "peter_rudar", "red face")
	kdb.add_action(KnowledgeDatabaseService.GameAction.LocatedIn, "peter_rudar", "in a house")
	kdb.add_action(KnowledgeDatabaseService.GameAction.InteractsWith, "peter_rudar", "player")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Gives, "peter_rudar", "some change")
	kdb.add_action(KnowledgeDatabaseService.GameAction.IsA, "peter_rudar", "a human")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Wears, "peter_rudar", "a dress")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Completes, "peter_rudar", "a rare quest")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Kills, "peter_rudar", "enemy_knight")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Damages, "peter_rudar", "enemy_knight")
	
	# Assert
	self.remove_child(kdb)


func _add_non_existing_action_expect_error():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	var i_dont_exist: int = 20
	
	# Act -> Continue execution, when it 'throws'
	kdb.add_action(i_dont_exist, "peter_rudar", "a tree")
	
	# Assert
	self.remove_child(kdb)


func _add_action_non_existing_entity_expect_error():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	kdb.add_action(KnowledgeDatabaseService.GameAction.Owns, "i_dont_exist", "a tree")
	
	# Assert
	self.remove_child(kdb)
	

func _actions_triplets_visualizer():
	# Arrange
	var kdb = KnowledgeDatabase.new()
	self.add_child(kdb)
	
	# Act
	kdb.add_action(KnowledgeDatabaseService.GameAction.Owns, "peter_rudar", "a tree")
	kdb.add_action(KnowledgeDatabaseService.GameAction.HasTrait, "peter_rudar", "red face")
	kdb.add_action(KnowledgeDatabaseService.GameAction.LocatedIn, "peter_rudar", "in a house")
	kdb.add_action(KnowledgeDatabaseService.GameAction.InteractsWith, "peter_rudar", "player")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Gives, "peter_rudar", "some change")
	kdb.add_action(KnowledgeDatabaseService.GameAction.IsA, "peter_rudar", "a human")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Wears, "peter_rudar", "a dress")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Completes, "peter_rudar", "a rare quest")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Kills, "peter_rudar", "enemy_knight")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Damages, "peter_rudar", "enemy_knight")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Damages, "peter_rudar", "enemy_knight")
	kdb.add_action(KnowledgeDatabaseService.GameAction.Kills, "player", "enemy_knight")
	
	# Assert
	print(kdb.get_action_triplets())
	self.remove_child(kdb)
