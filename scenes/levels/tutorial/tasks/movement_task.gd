extends Task


func _setup(tutorial_context: TutorialMap) -> void:
	(self._spawned_objects[0] as DesignatedSpot).player_entered.connect(self._complete_task)
