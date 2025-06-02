extends Node


var _player_inventory: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.level_change.connect(self._on_level_change)


func _on_level_change(level_change_type: GameTypes.LevelChangeType) -> void:
	var player = self._find_player_instance()
	var inventory = player.find_child("InventoryManager") as InventoryManager
	if inventory == null:
		printerr("PlayerStateManager: inventory on player not found!")
		return
	
	match level_change_type:
		GameTypes.LevelChangeType.OnLoading:
			print("PlayerStateManager: Restoring player inventory")
			for value in self._player_inventory.keys():
				inventory.give_item(value, self._player_inventory[value])
		GameTypes.LevelChangeType.OffLoading:
			print("PlayerStateManager: Saving player inventory")
			self._player_inventory = inventory.show_inventory()


func _find_player_instance() -> Player:
	var player = self.get_tree().get_first_node_in_group("player") as Player
	if player == null:
		printerr("PlayerStateManager: Player not found!")
		
	return player


func _on_tree_exited() -> void:
	GameEvents.level_change.disconnect(self._on_level_change)
