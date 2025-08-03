extends Resource
class_name Task

signal task_finished

@export var task_description: String
@export var task_goal: String

@export_file("*.tscn") var objects: Array[String]

var _spawned_objects: Array[Node2D] = []


func setup(tutorial_context: TutorialMap) -> void:
	self.call_deferred("_instantiate_all_objects", tutorial_context)
	self.call_deferred("_setup", tutorial_context)


func _instantiate_all_objects(tutorial_context: TutorialMap) -> void:
	for scene in self.objects:
		var loaded_scene = load(scene)
		var instantiated_scene = loaded_scene.instantiate()
		var spawn_node = tutorial_context.get_spawn_node()
		
		#spawn_node.call_deferred("add_child", instantiated_scene)
		spawn_node.add_child(instantiated_scene)
		
		instantiated_scene.global_position = spawn_node.global_position +\
			Vector2(randi_range(0, 5), randi_range(0, 5))
		
		self._spawned_objects.push_back(instantiated_scene)


func _setup(tutorial_context: TutorialMap) -> void:
	pass


func _complete_task() -> void:
	self.task_finished.emit()
	
	for object in self._spawned_objects:
		if object != null:
			object.call_deferred("queue_free")
