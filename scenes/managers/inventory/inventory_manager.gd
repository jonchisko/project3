extends Node
class_name InventoryManager

signal item_picked_up(item_id: String)
signal item_used(item_id: String)

@export var inventory_ui: InventoryMenuUi

var _inventory: Dictionary = {}


func has_item(item_id: String, number: int) -> bool:
	if number <= 0 or not self._inventory.has(item_id):
		return false
	return self._inventory[item_id] >= number


func get_item(item_id: String, number: int = 1) -> InteractableResource:
	if not _valid_item(item_id) or not self.has_item(item_id, number):
		return null
	if not _set_quantity(item_id, _inventory[item_id] - number):
		return null
	
	GameEvents.log_info.emit(
		GodotProjectLogger.LogType.GameEvent,
		self.name,
		"Getting item from player - {item_id}, amount {amount}.".format({"item_id": item_id, "amount": number}))
	
	return ResourceDictionary.ResourceIdToResource[item_id]
	
	
func give_item(item_id: String, number: int = 1) -> bool:
	if number <= 0 or not _valid_item(item_id):
		return false
	if not _set_quantity(item_id, _inventory.get(item_id, 0) + number):
		return false
	
	GameEvents.log_info.emit(
		GodotProjectLogger.LogType.GameEvent,
		self.name,
		"Giving item to player - {item_id}, amount {amount}.".format({"item_id": item_id, "amount": number}))
	
	self._log_current_state()
	return true


func receive_items_from_npc(npc_id: String, items: Dictionary) -> bool:
	return _transfer_items(npc_id, items, true)


func give_item_to_npc(npc_id: String, item_id: String, amount: int) -> bool:
	return _transfer_items(npc_id, {item_id: amount}, false)


func _transfer_items(npc_id: String, items: Dictionary, to_player: bool) -> bool:
	if not ResourceDictionary.npc_ids.has(npc_id):
		return false
	var next_inventory: Dictionary = _inventory.duplicate()
	for item_id in items:
		var amount = items[item_id]
		if not item_id is String or not _valid_item(item_id) or not amount is int:
			return false
		if amount <= 0 or amount > 2147483647:
			return false
		var current: int = _inventory.get(item_id, 0)
		# Refuse a transfer if the database no longer agrees with the physical inventory.
		if KDBService.get_ownership_quantity(item_id, "player") != current:
			push_error("Player ownership is out of sync for " + item_id)
			return false
		var next: int = current + (amount if to_player else -amount)
		if next < 0 or next > 2147483647:
			return false
		if next == 0:
			next_inventory.erase(item_id)
		else:
			next_inventory[item_id] = next
	var source: String = npc_id if to_player else "player"
	var recipient: String = "player" if to_player else npc_id
	if not KDBService.transfer_ownership(source, recipient, items):
		return false
	# No awaits or signals between the database commit and this local assignment.
	_inventory = next_inventory
	for item_id in items:
		GameEvents.log_info.emit(GodotProjectLogger.LogType.GameEvent, name,
			"Transferred {amount} {item} from {source} to {recipient}.".format({
				"amount": items[item_id], "item": item_id, "source": source, "recipient": recipient}))
	return true


func restore_inventory(items: Dictionary) -> bool:
	var restored: Dictionary = {}
	for item_id in items:
		var amount = items[item_id]
		if not item_id is String or not _valid_item(item_id) or not amount is int:
			return false
		if amount < 0 or amount > 2147483647:
			return false
		if amount > 0:
			restored[item_id] = amount
	if not KDBService.replace_ownership("player", restored):
		return false
	_inventory = restored
	return true


func _valid_item(item_id: String) -> bool:
	if not ResourceDictionary.item_ids.has(item_id):
		return false
	var resource: InteractableResource = ResourceDictionary.ResourceIdToResource[item_id]
	return resource.data is ItemData


func _set_quantity(item_id: String, quantity: int) -> bool:
	if quantity < 0 or quantity > 2147483647:
		return false
	if not KDBService.update_ownership_quantity(item_id, "player", quantity):
		return false
	if quantity == 0:
		_inventory.erase(item_id)
	else:
		_inventory[item_id] = quantity
	return true
	

func show_inventory() -> Dictionary:
	return self._inventory.duplicate()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# A new player starts empty; level restoration replaces this with its saved snapshot.
	if not restore_inventory(_inventory):
		push_error("Could not synchronize the player's initial inventory")
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
	if get_item(item_id, 1) != null:
		self.item_used.emit(item_id)
		GameEvents.item_used.emit(item_id)
	if is_instance_valid(inventory_ui):
		inventory_ui.refresh_inventory(_get_item_data())


func _on_item_picked_up(interactable: InteractableArea):
	if interactable.interactable_type != GameTypes.InteractableType.Item:
		return
	if interactable.get_parent().is_queued_for_deletion():
		return
	var item_id: String = interactable.interactable_data.data.id
	if not give_item(item_id, 1):
		return
	
	KDBService.add_action(KDBService.GameAction.InteractsWith, "player", interactable.interactable_data.data.id)
	
	# TODO might be better to call something on the interactable + disable the colisions etc.
	interactable.get_parent().queue_free()
	self.item_picked_up.emit(item_id)
	
	self._log_current_state()


func _log_current_state():
	print("Inventory: {inv}".format({"inv": self._inventory}))
	
	for inventory_id in self._inventory.keys():
		print("Id: {id}, Name: {name}".format({"id": inventory_id,
			"name": ResourceDictionary.ResourceIdToResource[inventory_id].data.name}))
