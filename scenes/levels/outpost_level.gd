extends SceneSyncher


@export var label: Label
@export var spawn_location: Node2D

var _item_resource = preload("res://resources/interactables/items/jewelry_blueprints_item.tres")
var _item_scene = preload("res://scenes/game_objects/items/item.tscn")
var _item_spawned: bool = false
var _player_in_area: bool = true


func save_scene() -> Dictionary:
	var saved_data: Dictionary = {}
	
	var player = self.get_tree().get_first_node_in_group("player") as Player
	saved_data["player"] = player.global_position
	
	var enemies: Dictionary = {}
	for enemy in self.get_tree().get_nodes_in_group("enemy"):
		enemies[enemy.get_path()] = true
	
	saved_data["enemies"] = enemies
		
	saved_data["item_spawned"] = self._item_spawned
	
	return saved_data
	

func load_scene(data: Dictionary) -> void:
	var player = self.get_tree().get_first_node_in_group("player") as Player
	player.global_position = data["player"]
	
	for enemy in self.get_tree().get_nodes_in_group("enemy"):
		if data["enemies"].has(enemy.get_path()):
			continue
		enemy.call_deferred("queue_free")
	
	self._item_spawned = data["item_spawned"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.level_change.emit(GameTypes.LevelChangeType.OnLoading)


func _process(delta: float) -> void:
	if self._player_in_area and Input.is_action_just_pressed("interact"):
		self._spawn_item()


func _spawn_item() -> void:
	if not self._item_spawned:
		print("SPAWN")
		self._item_spawned = true
		var instantiated: Node2D = self._item_scene.instantiate()
		instantiated.interactable_data = self._item_resource
		
		self.spawn_location.add_child(instantiated)
		instantiated.global_position = self.spawn_location.global_position
		
		
func _on_chest_area_area_entered(area: Area2D) -> void:
	self._player_in_area = true
	if not self._item_spawned:
		self.label.visible = true


func _on_chest_area_area_exited(area: Area2D) -> void:
	self._player_in_area = false
	self.label.visible = false


func _on_tree_entered() -> void:
	pass
	#GameEvents.level_change.emit(GameTypes.LevelChangeType.OnLoading)
