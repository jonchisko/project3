extends Task


func _setup(tutorial_context: TutorialMap) -> void:
	tutorial_context.player_inventory.give_item("wajdovian_spear", 1)
	var crate_hp = self._spawned_objects[0].find_child("HealthComponent") as HealthComponent
	crate_hp.death.connect(self._on_crate_death)


func _on_crate_death() -> void:
	self._complete_task()
