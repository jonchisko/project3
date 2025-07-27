extends Node
class_name InventoryManager

signal item_used(item_id: String)

@export var inventory_ui: InventoryMenuUi

var _inventory: Dictionary = {}


func has_item(item_id: String, number: int) -> bool:
	if not self._inventory.has(item_id):
		return false
	return self._inventory[item_id] >= number


func get_item(item_id: String, number: int = 1) -> InteractableResource:
	if not self.has_item(item_id, number):
		return null
		
	for _i in range(number):
		self._remove_item(item_id)
	
	return ResourceDictionary.ResourceIdToResource[item_id]
	
	
func give_item(item_id: String, number: int = 1) -> bool:
	if not ResourceDictionary.ResourceIdToResource.has(item_id):
		return false
	
	var item_data = ResourceDictionary.ResourceIdToResource[item_id]
	
	for _i in range(number):
		self._add_item(item_data)
	
	self._log_current_state()
	return true
	

func show_inventory() -> Dictionary:
	return self._inventory
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.interact_with_interactable.connect(self._on_item_picked_up)
	
	self.inventory_ui.item_used.connect(self._on_item_used)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory") and not inventory_ui.visible:
		var item_data = self._get_item_data()
		self.inventory_ui.open_inventory(item_data)
	
	if Input.is_action_just_pressed("inventory") and inventory_ui.visible:
		self.inventory_ui.close_inventory()


func _get_item_data() -> Array[Dictionary]:
	var item_data: Array[Dictionary] = []
	
	for inventory_id in self._inventory.keys():
		var resource = ResourceDictionary.ResourceIdToResource[inventory_id]
		var visual = resource.visual
		var data = resource.data
		
		item_data.push_back({
			"icon": visual.icon, 
			"id": data.id, 
			"name": data.name, 
			"description": data.description,
			"amount": self._inventory[inventory_id]})
			
	return item_data


func _on_item_used(item_id: String) -> void:
	self.item_used.emit(item_id)
	self._remove_item(item_id)


func _on_item_picked_up(interactable: InteractableArea):
	if interactable.interactable_type != GameTypes.InteractableType.Item:
		return
	
	self._add_item(interactable.interactable_data)
	
	# TODO might be better to call something on the interactable + disable the colisions etc.
	interactable.get_parent().call_deferred("queue_free")
	
	self._log_current_state()


func _add_item(item: InteractableResource):
	var visual = item.visual
	var data = item.data as ItemData
	
	if visual == null or data == null:
		return
	
	if self._inventory.has(data.id):
		self._inventory[data.id] += 1 
	else:
		self._inventory[data.id] = 1
		

func _remove_item(item_id: String):
	if not self._inventory.has(item_id):
		return
		
	self._inventory[item_id] -= 1
	if self._inventory[item_id] == 0:
		self._inventory.erase(item_id)
	
	print("Item used: ", item_id, ". Firing GameEvent(s) item_used.")
	GameEvents.item_used.emit(item_id)


func _log_current_state():
	print("Inventory: {inv}".format({"inv": self._inventory}))
	
	for inventory_id in self._inventory.keys():
		print("Id: {id}, Name: {name}".format({"id": inventory_id,
			"name": ResourceDictionary.ResourceIdToResource[inventory_id].data.name}))
