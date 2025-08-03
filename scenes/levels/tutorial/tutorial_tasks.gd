extends Node


@export var tasks: Array[Task]
@export var tutorial_context: TutorialMap
@export var task_ui: TaskUi

var current_task: Task


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._set_new_task()


func _on_task_finished() -> void:
	if self.tasks.is_empty():
		return
	self._set_new_task()


func _set_new_task() -> void:
	self.current_task = self.tasks.pop_front()
	self.current_task.setup(self.tutorial_context)
	self.current_task.task_finished.connect(self._on_task_finished)
	
	self.task_ui.set_task_description(self.current_task.task_description)
	self.task_ui.set_task_goal(self.current_task.task_goal)
