extends Node2D
class_name TutorialMap

@export var player: Player
@export var player_health_component: HealthComponent
@export var player_inventory: InventoryManager
@export var chat_manager: ChatManager

var pause_menu: Resource = preload("res://scenes/ui/pause_menu.tscn")

var _finish_tutorial: bool = false

func get_spawn_node() -> Node2D:
	return $YSortedObjects/InstantiateLocation


func finish_tutorial() -> void:
	self._finish_tutorial = true


func _input(event: InputEvent) -> void:
	var event_key = event as InputEventKey
	
	if event_key != null and event_key.keycode == KEY_P and event.is_pressed() and not event_key.echo:
		var instantiated = pause_menu.instantiate() as PauseMenu
		$CanvasLayer.add_child(instantiated)
		instantiated.open()
	
	if self._finish_tutorial and event_key != null and event_key.keycode == KEY_ESCAPE and event.is_pressed() and not event_key.echo:
		self.get_tree().change_scene_to_file("res://scenes/ui/menu/main_menu_scene.tscn")
