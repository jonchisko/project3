extends Node
class_name InventoryManager

var _inventory: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.interact_with_interactable.connect(self._on_item_picked_up)


func _on_item_picked_up(interactable: InteractableArea):
	if interactable.interactable_type != GameTypes.InteractableType.Item:
		return
	
	var visual = interactable.interactable_data.visual
	var data = interactable.interactable_data.data as ItemData
	
	if visual == null or data == null:
		return
	
	if self._inventory.has(data.id):
		self._inventory[data.id] += 1 
	else:
		self._inventory[data.id] = 1
	
	# TODO might be better to call something on the interactable + disable the colisions etc.
	interactable.get_parent().call_deferred("queue_free")
	
	
	print("Inventory: {inv}".format({"inv": self._inventory}))
	
	for inventory_id in self._inventory.keys():
		print("Id: {id}, Name: {name}".format({"id": inventory_id,
			"name": ResourceDictionary.ResourceIdToResource[inventory_id].data.name}))
