extends Task


var dash_counter: int = 0


func _setup(tutorial_context: TutorialMap) -> void:
	tutorial_context.player.dashed.connect(self._on_dash)


func _on_dash() -> void:
	self.dash_counter += 1
	if self.dash_counter >= 1:
		self._complete_task()
