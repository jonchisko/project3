extends Node
## Isolated, offline level-transition check. Run as a scene in a test project copy.

var failures: int = 0

func _ready() -> void:
	_run.call_deferred()

func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		printerr("FAIL: " + description)

func _inventory() -> InventoryManager:
	return get_tree().get_first_node_in_group("player").find_child("InventoryManager") as InventoryManager

func _change_level(path: String) -> void:
	if get_tree().current_scene != null:
		GameEvents.level_change.emit(GameTypes.LevelChangeType.OffLoading)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame

func _run() -> void:
	# Keep this runner under the root while the actual game scenes are replaced.
	get_tree().current_scene = null
	await _change_level("res://scenes/test/test_map.tscn")
	var inventory: InventoryManager = _inventory()
	_check(inventory.give_item("outpost_keycode", 1), "prepare an outpost keycode")
	_check(inventory.give_item("metal_bolt", 3), "prepare player items")
	_check(inventory.receive_items_from_npc("bojan_kovač", {"health_potion": 1}), "prepare an NPC reward before changing levels")
	await _change_level("res://scenes/levels/outpost_level.tscn")
	inventory = _inventory()
	_check(inventory.has_item("outpost_keycode", 1) and inventory.has_item("metal_bolt", 3) and inventory.has_item("health_potion", 1), "outpost restores inventory without a chat manager")
	_check(KDBService.get_ownership_quantity("health_potion", "bojan_kovač") == 1 and KDBService.get_ownership_quantity("health_potion", "player") == 1, "outpost preserves both owners' balances")
	inventory.get_item("metal_bolt", 1)
	inventory.give_item("log_books", 1)
	await _change_level("res://scenes/test/test_map.tscn")
	inventory = _inventory()
	_check(inventory.has_item("metal_bolt", 2) and not inventory.has_item("metal_bolt", 3) and inventory.has_item("log_books", 1), "leaving the outpost preserves item changes")
	_check(KDBService.get_ownership_quantity("metal_bolt", "player") == 2 and KDBService.get_ownership_quantity("log_books", "player") == 1, "returning map ownership matches inventory")
	await _change_level("res://scenes/levels/outpost_level.tscn")
	_check(_inventory().has_item("metal_bolt", 2) and KDBService.get_ownership_quantity("health_potion", "bojan_kovač") == 1, "repeated level changes do not replenish NPC rewards or duplicate items")
	print("Ownership level-transition failures: ", failures)
	get_tree().quit(1 if failures else 0)
