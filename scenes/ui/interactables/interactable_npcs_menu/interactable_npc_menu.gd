extends InteractableMenu


func _ready():
	self.ui_scene = preload("res://scenes/ui/interactables/interactable_npcs_menu/interactable_npc_ui.tscn")
	self.container = %NpcContainer
