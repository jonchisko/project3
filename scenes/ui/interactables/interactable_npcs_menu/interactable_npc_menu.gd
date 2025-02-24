extends InteractableMenu


@onready var npc_container: VBoxContainer = %NpcContainer

var _ui_npc_scene: PackedScene = preload("res://scenes/ui/interactables/interactable_npcs_menu/interactable_npc_ui.tscn")


func add_interactable(interactable: InteractableArea):
	var npc_ui = self._ui_npc_scene.instantiate() as InteractableNpcUi
	self.item_container.add_child(npc_ui)
	
	var item_data = interactable.interactable_data.data as ItemData
	if item_data == null:
		printerr("Item data is null, because interactable is not ItemData, but should be. 
		Means the physical layer masks are incorrect.")
		
	npc_ui.set_data(interactable.interactable_data.visual.icon, item_data.name)
	npc_ui.selected.connect(self._on_selected_npc.bind(interactable))
	
	self.interactables[interactable] = npc_ui


func remove_interactable(interactable: InteractableArea):
	if not self.interactables.has(interactable):
		return
		
	var npc_ui = self.interactables[interactable]
	npc_ui.remove_item()
	self.interactables.erase(interactable)


func _on_selected_npc(interactable: InteractableArea):
	self.interactable_picked.emit(interactable)
