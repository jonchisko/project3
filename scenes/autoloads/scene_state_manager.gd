extends Node


var _scene_data: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.level_change.connect(self._on_level_change)


func _on_level_change(level_change_type: GameTypes.LevelChangeType) -> void:
	var current_scene: SceneSyncher = self.get_tree().get_first_node_in_group("level_scene")
	
	match level_change_type:
		GameTypes.LevelChangeType.OnLoading:
			print("SceneStateManager: Restoring scene state")
			if not self._scene_data.has(current_scene.name):
				print("SceneStateManager: scene {s} doesnt have data stored yet.".format({"s": current_scene}))
				return
			current_scene.load_scene(self._scene_data[current_scene.name])
		GameTypes.LevelChangeType.OffLoading:
			print("SceneStateManager: Saving scene state")
			self._scene_data[current_scene.name] = current_scene.save_scene()


func _on_tree_exited() -> void:
	GameEvents.level_change.disconnect(self._on_level_change)
