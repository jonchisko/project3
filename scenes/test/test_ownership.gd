extends Node
## Run this scene in an isolated project copy; it changes the session's ownership.

class TestChat extends ChatManager:
	func _ready() -> void:
		pass
	func _exit_tree() -> void:
		pass
	func _refresh_static_template(_messages: Array[Message], _history: ChatHistoryRust, _npc: NpcData) -> void:
		pass

class TestUi extends ChatMessengerUi:
	var messages: Array[String] = []
	func _ready() -> void:
		pass
	func set_request_pending(value: bool) -> void:
		request_pending = value
	func add_chat_element(message: String):
		messages.append(message)
	func edit_last_chat_element(message: String):
		messages[messages.size() - 1] = message

class InventoryUi extends InventoryMenuUi:
	var latest: Array[Dictionary] = []
	func _ready() -> void:
		pass
	func refresh_inventory(items: Array[Dictionary]) -> void:
		latest = items

var failures: int = 0
var checks: int = 0
var consumed: int = 0
var log_messages: Array[String] = []
var allocations: Array[Node] = []

func _ready() -> void:
	_run.call_deferred()

func _check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		printerr("FAIL: " + description)

func _quantity(owner: String, item: String) -> int:
	return KDBService.get_ownership_quantity(item, owner)

func _tool(tool_name: String, item: String, amount) -> ToolCall:
	return ToolCall.new({"id": "ownership_test", "type": "function", "function": {
		"name": tool_name, "arguments": JSON.stringify({"item_id": item, "number": amount})}})

func _run() -> void:
	GameEvents.log_info.connect(func(_kind, _source, content): log_messages.append(content))
	_check(_quantity("bojan_kovač", "health_potion") == 2, "Bojan starts with both potion rewards")
	_check(_quantity("franc_petrov", "cracked_smaragd_ring") == 1 and _quantity("franc_petrov", "book_wotlica") == 1, "Franc starts with his ring and book reward")
	for npc_id in ResourceDictionary.npc_ids:
		var npc: NpcData = ResourceDictionary.ResourceIdToResource[npc_id].data
		var initial: Dictionary = HelperQuests.get_initial_ownership(npc.quest_data, npc.starting_items)
		_check(initial.error.is_empty(), "valid reward definitions for " + npc_id)
		for item_id in initial.items:
			_check(_quantity(npc_id, item_id) == initial.items[item_id], "initial ownership matches rewards: " + npc_id + "/" + item_id)

	var quest := QuestResource.new()
	quest.id = "ownership_fixture"
	quest.rewards = ["Tell the player some information.", "give_item(health_potion, 2)", "give_item(health_potion, 3)", "give_item(metal_bolt, 1)"]
	var fixture_quests: Array[QuestResource] = [quest]
	var initial: Dictionary = HelperQuests.get_initial_ownership(fixture_quests)
	_check(initial.items == {"health_potion": 5, "metal_bolt": 1}, "aggregate every reward including repeated item IDs")
	_check(HelperQuests.get_initial_ownership(fixture_quests, {"health_potion": 1}).items.health_potion == 6, "starting stock is additional to reward stock")
	for invalid_stock in [{"unknown_item": 1}, {"health_potion": -1}, {"health_potion": 1.5}, {"health_potion": 2147483647}]:
		_check(not HelperQuests.get_initial_ownership(fixture_quests, invalid_stock).error.is_empty(), "reject invalid starting stock or combined overflow")
	quest.rewards = ["give_item(unknown_item, 1)"]
	_check(not HelperQuests.get_initial_ownership(fixture_quests).error.is_empty(), "reject unknown initialization items")
	quest.rewards = ["give_item(health_potion, -1)"]
	_check(not HelperQuests.get_initial_ownership(fixture_quests).error.is_empty(), "reject malformed initialization quantities")
	quest.rewards = []
	_check(HelperQuests.get_initial_ownership(fixture_quests).items.is_empty(), "reward-free initialization is empty")

	var inventory := InventoryManager.new()
	allocations.append(inventory)
	var ui := InventoryUi.new()
	allocations.append(ui)
	inventory.inventory_ui = ui
	inventory.item_used.connect(func(_id): consumed += 1)
	_check(inventory.restore_inventory({}), "initialize an empty player inventory")
	var world_item := Node2D.new()
	var area := InteractableArea.new()
	world_item.add_child(area)
	area.interactable_data = ResourceDictionary.ResourceIdToResource["health_potion"]
	inventory._on_item_picked_up(area)
	inventory._on_item_picked_up(area)
	_check(inventory.has_item("health_potion", 1) and _quantity("player", "health_potion") == 1, "pickup updates ownership once even with repeated interaction")
	inventory._on_item_used("health_potion")
	_check(_quantity("player", "health_potion") == 0 and inventory.show_inventory().is_empty(), "consuming the last item clears physical and recorded ownership")
	_check(consumed == 1 and ui.latest.is_empty(), "successful consumption updates effects and inventory UI")
	inventory._on_item_used("health_potion")
	_check(consumed == 1, "missing items cannot be consumed")

	_check(inventory.receive_items_from_npc("bojan_kovač", {"health_potion": 1}), "receive the first NPC reward")
	_check(_quantity("bojan_kovač", "health_potion") == 1 and _quantity("player", "health_potion") == 1, "NPC reward updates both balances")
	_check(inventory.receive_items_from_npc("bojan_kovač", {"health_potion": 1}), "receive the second NPC reward")
	_check(_quantity("bojan_kovač", "health_potion") == 0 and inventory.has_item("health_potion", 2), "NPC reward stock reaches zero")
	_check(not inventory.receive_items_from_npc("bojan_kovač", {"health_potion": 1}), "reject a reward beyond NPC ownership")
	_check(inventory.has_item("health_potion", 2) and _quantity("player", "health_potion") == 2, "failed transfer leaves player unchanged")
	_check(inventory.give_item_to_npc("bojan_kovač", "health_potion", 2), "give items back to an NPC")
	_check(_quantity("bojan_kovač", "health_potion") == 2 and _quantity("player", "health_potion") == 0, "return transfer updates both balances")
	_check(consumed == 1, "trading potions does not consume or apply them")

	_check(not inventory.receive_items_from_npc("bojan_kovač", {"health_potion": 1, "metal_bolt": 1}), "batch rewards fail when one item is unavailable")
	_check(_quantity("bojan_kovač", "health_potion") == 2 and inventory.show_inventory().is_empty(), "batch failure does not transfer an earlier reward")
	_check(not inventory.give_item("health_potion", -1) and not inventory.has_item("health_potion", 0), "reject invalid inventory quantities")
	_check(not KDBService.transfer_ownership("bojan_kovač", "player", {"health_potion": 0}), "service rejects zero transfers")
	_check(not KDBService.replace_ownership("player", {"health_potion": -1}), "service rejects negative balances")

	inventory.give_item("metal_bolt", 3)
	var snapshot: Dictionary = inventory.show_inventory()
	inventory.get_item("metal_bolt", 1)
	_check(snapshot["metal_bolt"] == 3, "saved inventory is not a live dictionary reference")
	var before_restore: int = log_messages.size()
	_check(inventory.restore_inventory(snapshot) and inventory.restore_inventory(snapshot), "restoring a level snapshot can be repeated")
	_check(_quantity("player", "metal_bolt") == 3 and inventory.show_inventory()["metal_bolt"] == 3, "restoration sets exact quantities without duplication")
	_check(log_messages.size() == before_restore, "restoration does not log newly received items")
	_check(_quantity("bojan_kovač", "health_potion") == 2, "restoration preserves NPC ownership")
	_check(inventory.restore_inventory({}) and _quantity("player", "metal_bolt") == 0, "restoring an empty snapshot clears old player balances")

	var chat := TestChat.new()
	allocations.append(chat)
	chat._player_inventory = inventory
	chat._current_npc_data = NpcData.new()
	chat._current_npc_data.id = "bojan_kovač"
	var result: Dictionary = chat._parse_tool_call(_tool("give_item", "health_potion", 1))
	_check(not result.error and _quantity("bojan_kovač", "health_potion") == 1 and _quantity("player", "health_potion") == 1, "real give_item handler uses ownership transfer")
	result = chat._parse_tool_call(_tool("get_item", "health_potion", 1))
	_check(not result.error and _quantity("bojan_kovač", "health_potion") == 2 and _quantity("player", "health_potion") == 0, "real get_item handler credits the NPC")
	for amount in [-1, 0, 0.5, "1", true, 2147483648]:
		_check(chat._parse_tool_call(_tool("give_item", "health_potion", amount)).error, "reject malformed tool quantity " + str(amount))
	_check(_quantity("bojan_kovač", "health_potion") == 2, "invalid tool arguments leave NPC ownership unchanged")

	# Both template styles expose one mutable snapshot of current world facts.
	var history := ChatHistoryRust.new()
	allocations.append(history)
	for prompt_style in [StrictGptTemplate.new(), LooseGptTemplate.new()]:
		allocations.append(prompt_style)
		var template: TemplateBase = OpenAiApi.got_open_ai.GetPreviewCompletion().get_template()
		allocations.append(template)
		chat._template = prompt_style
		chat._dynamic_world_context = prompt_style.set_up_static_template(template, chat._current_npc_data, history)
		var before_size: int = template.get_context().size()
		inventory.receive_items_from_npc("bojan_kovač", {"health_potion": 1})
		chat._refresh_dynamic_world_context()
		_check(chat._dynamic_world_context.content.contains("bojan_kovač owns 1 health_potion") and chat._dynamic_world_context.content.contains("player owns 1 health_potion"), "prompt refresh sees post-transfer balances")
		chat._refresh_dynamic_world_context()
		_check(template.get_context().size() == before_size, "refresh replaces the snapshot rather than appending stale copies")
		inventory.give_item_to_npc("bojan_kovač", "health_potion", 1)

	# Skip rewards use the same real batch transfer, with no LLM request for item-only rewards.
	GameEvents.quest_done.disconnect(QuestManager._on_quests_completed)
	chat._chat_messenger_instance = TestUi.new()
	allocations.append(chat._chat_messenger_instance)
	quest.rewards = ["give_item(health_potion, 1)", "give_item(health_potion, 1)"]
	chat._current_npc_data.quest_data = [quest]
	await chat._on_skipped_quest()
	_check(chat._current_npc_data.quest_data.is_empty() and _quantity("bojan_kovač", "health_potion") == 0 and inventory.has_item("health_potion", 2), "skip aggregates repeated rewards and debits NPC ownership")
	inventory.give_item_to_npc("bojan_kovač", "health_potion", 2)
	quest.rewards = ["give_item(health_potion, 1)", "give_item(metal_bolt, 1)"]
	chat._current_npc_data.quest_data = [quest]
	await chat._on_skipped_quest()
	_check(not chat._current_npc_data.quest_data.is_empty() and _quantity("bojan_kovač", "health_potion") == 2 and inventory.show_inventory().is_empty(), "failed skip preserves all balances and keeps its quest active")
	GameEvents.quest_done.connect(QuestManager._on_quests_completed)

	for allocation in allocations:
		allocation.free()
	print("Ownership checks: ", checks, "; failures: ", failures)
	get_tree().quit(1 if failures else 0)
