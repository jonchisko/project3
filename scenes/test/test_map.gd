extends SceneSyncher


func _ready() -> void:
	GameEvents.level_change.emit(GameTypes.LevelChangeType.OnLoading)


func save_scene() -> Dictionary:
	var saved_data: Dictionary = {}
	
	var player = self.get_tree().get_first_node_in_group("player") as Player
	saved_data["player"] = player.global_position
	
	var enemies: Dictionary = {}
	for enemy in self.get_tree().get_nodes_in_group("enemy"):
		enemies[enemy.get_path()] = true
	
	saved_data["enemies"] = enemies
		
	var items: Dictionary = {}
	for item in self.get_tree().get_nodes_in_group("pickupable_item"):
		items[item.get_path()] = true

	saved_data["items"] = items
	
	return saved_data
	

func load_scene(data: Dictionary) -> void:
	var player = self.get_tree().get_first_node_in_group("player") as Player
	player.global_position = data["player"]
	
	for enemy in self.get_tree().get_nodes_in_group("enemy"):
		if data["enemies"].has(enemy.get_path()):
			continue
		enemy.call_deferred("queue_free")
	
	for item in self.get_tree().get_nodes_in_group("pickupable_item"):
		if data["items"].has(item.get_path()):
			continue
		item.call_deferred("queue_free")
