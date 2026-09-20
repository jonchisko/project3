extends Node
## Offline regression tests. Run in an isolated project copy: this script initializes autoloads.

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

class TestManager extends ChatManager:
	var information_reply: Message
	var information_requests: int = 0
	var granted: Array = []
	func _ready() -> void:
		pass
	func _exit_tree() -> void:
		pass
	func _refresh_static_template(_messages: Array[Message], _history: ChatHistoryRust, _npc: NpcData) -> void:
		pass
	func _give_item_to_player(item_id: String, amount: int) -> bool:
		granted.append({"item": item_id, "amount": amount})
		return true
	func _give_items_to_player(items: Dictionary) -> bool:
		for item_id in items:
			_give_item_to_player(item_id, items[item_id])
		return true
	func _request_skip_information(_quest: QuestResource, _information: Array) -> Message:
		information_requests += 1
		await Engine.get_main_loop().process_frame
		return information_reply

class TestTemplate extends TemplateBase:
	var replies: Array[CompletionResponse] = []
	func _init():
		super(null, null, MessageManager.new())
	func get_reply() -> CompletionResponse:
		await Engine.get_main_loop().process_frame
		return replies.pop_front()

var failures: int = 0
var completed: Array[String] = []
var logged: Array[String] = []
var allocations: Array[Node] = []

func _ready() -> void:
	_run.call_deferred()

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + description)
	else:
		print("PASS: " + description)

func _manager(rewards: Array) -> TestManager:
	var manager := TestManager.new()
	allocations.append(manager)
	var npc := NpcData.new()
	npc.id = "jure_hauptmann"
	var quest := QuestResource.new()
	quest.id = "collect_metal_scraps"
	quest.rewards = rewards
	npc.quest_data = [quest]
	manager._current_npc_data = npc
	manager._chat_messenger_instance = TestUi.new()
	allocations.append(manager._chat_messenger_instance)
	return manager

func _tool(tool_name: String, arguments: Dictionary) -> ToolCall:
	return ToolCall.new({"id": "test_call", "type": "function", "function": {
		"name": tool_name, "arguments": JSON.stringify(arguments)}})

func _response(content: String, calls: Array = []) -> CompletionResponse:
	var message := {"role": "assistant", "content": content}
	if not calls.is_empty():
		message["tool_calls"] = calls
	return CompletionResponse.new(true, [{"index": 0, "message": message, "finish_reason": "stop"}])

func _run() -> void:
	# Unit checks observe the event without changing the real global quest list.
	GameEvents.quest_done.disconnect(QuestManager._on_quests_completed)
	GameEvents.quest_done.connect(func(id: String): completed.append(id))
	GameEvents.log_info.connect(func(_kind, _source, content): logged.append(content))

	var manager := _manager([])
	var result: Dictionary = manager._parse_tool_call(_tool("give_item", {"item_id": "health_potion", "number": 1}))
	_check(result.call_result and completed.is_empty() and manager._pending_completion_id.is_empty(), "giving a reward does not complete a quest")
	result = manager._parse_tool_call(_tool("complete_quest", {"quest_id": "wrong_quest"}))
	_check(result.error, "reject a different quest ID")
	result = manager._parse_tool_call(_tool("complete_quest", {"quest_id": 42}))
	_check(result.error, "reject a non-string quest ID")
	result = manager._parse_tool_call(_tool("complete_quest", {"quest_id": "collect_metal_scraps"}))
	_check(result.call_result and completed.is_empty(), "queue completion until the final reply")
	manager._finish_quest("collect_metal_scraps")
	manager._finish_quest("collect_metal_scraps")
	_check(completed.size() == 1 and manager._current_npc_data.quest_data.is_empty(), "emit completion once and advance the NPC")
	_check(manager._parse_tool_call(_tool("complete_quest", {"quest_id": "collect_metal_scraps"})).error, "reject completion when no quest remains")

	for rewards in [[], ["give_item(health_potion, 2)"], ["Tell the player where Bojan is."], ["give_item(health_potion, 2)", "Tell the player where Bojan is.", "give_item(metal_bolt, 3)"]]:
		manager = _manager(rewards)
		manager.information_reply = MessageBuilder.new("assistant").with_content("Bojan is at the location described in the world context.").build()
		var before: int = completed.size()
		await manager._on_skipped_quest()
		_check(completed.size() == before + 1, "skip completes reward combination " + str(rewards))
		_check(not manager._request_pending, "skip releases the input lock")
		if rewards.size() == 3:
			_check(manager.granted.size() == 2 and manager.granted[0].amount == 2 and manager.granted[1].amount == 3, "skip grants every item reward and quantity")
			_check(manager.information_requests == 1 and manager._current_conversation_messages.size() == 1, "skip requests and retains information for dialogue logging")

	manager = _manager(["give_item(health_potion, 2)", "Tell the player where Bojan is."])
	var before: int = completed.size()
	await manager._on_skipped_quest()
	_check(completed.size() == before and manager.granted.is_empty() and not manager._current_npc_data.quest_data.is_empty(), "failed information request neither grants items nor completes quest")
	manager.information_reply = MessageBuilder.new("assistant").with_content("Here is the reward information.").build()
	await manager._on_skipped_quest()
	_check(manager.granted.size() == 1 and completed.size() == before + 1, "retry grants items once after information succeeds")
	manager = _manager(["give_item(health_potion, 1)", "give_item(missing_item, 1)"])
	await manager._on_skipped_quest()
	_check(manager.granted.is_empty(), "validate all skip rewards before granting any")

	# Exercise the real response loop with multiple tool calls followed by NPC text.
	manager = _manager(["give_item(health_potion, 1)", "Tell the player where Bojan is."])
	var template := TestTemplate.new()
	allocations.append(template)
	manager._gpt_template = template
	manager._template = LooseGptTemplate.new()
	allocations.append(manager._template)
	manager.chat_history_rust = ChatHistoryRust.new()
	allocations.append(manager.chat_history_rust)
	var item_call: Dictionary = _tool("give_item", {"item_id": "health_potion", "number": 1}).to_dictionary()
	item_call["id"] = "item_call"
	var completion_call: Dictionary = _tool("complete_quest", {"quest_id": "collect_metal_scraps"}).to_dictionary()
	completion_call["id"] = "completion_call"
	template.replies = [_response("", [item_call, completion_call]), _response("Here is the information reward.")]
	template.append_message("developer", "Keep this NPC context.")
	before = completed.size()
	await manager._on_player_message_sent("I have finished.")
	_check(completed.size() == before + 1 and manager.granted.size() == 1, "normal response loop completes through the separate tool")
	_check(manager._current_conversation_messages.back().content == "Here is the information reward.", "retain the final information reward before completion")
	_check(template.get_context()[0].content == "Keep this NPC context.", "Loose template cleanup preserves earlier context")
	_check(manager._current_conversation_messages.size() == 5, "retain user, assistant calls, both tool results, and final reply")
	_check(not manager._request_pending, "normal conversation releases the input lock")

	# A failed follow-up must preserve the queued decision and allow retrying.
	manager = _manager([])
	template = TestTemplate.new()
	allocations.append(template)
	manager._gpt_template = template
	manager._template = StrictGptTemplate.new()
	allocations.append(manager._template)
	manager.chat_history_rust = ChatHistoryRust.new()
	allocations.append(manager.chat_history_rust)
	template.replies = [_response("", [completion_call]), CompletionResponse.new(false, [])]
	template.append_message("developer", "Keep strict NPC context.")
	before = completed.size()
	await manager._on_player_message_sent("I have finished the quest without a reward.")
	_check(completed.size() == before and not manager._pending_completion_id.is_empty() and not manager._request_pending, "failed final reply leaves completion pending and permits retry")
	template.replies = [_response("The quest is complete.")]
	await manager._on_player_message_sent("Please continue.")
	_check(completed.size() == before + 1 and manager.granted.is_empty(), "retry completes a reward-free quest without giving an item")
	_check(template.get_context()[0].content == "Keep strict NPC context.", "Strict template cleanup preserves earlier context")

	# The last item must be removable without reading an erased dictionary entry.
	var inventory := InventoryManager.new()
	allocations.append(inventory)
	inventory.give_item("health_potion", 1)
	_check(inventory.get_item("health_potion", 1) != null and inventory.show_inventory().is_empty(), "remove the final required item")

	var loose := LooseGptTemplate.new()
	allocations.append(loose)
	_check(loose._add_quest(NpcData.new()).contains("do not have any quests"), "Loose template supports an NPC with no remaining quests")
	_check(logged.any(func(line): return line.contains("Skipping quest (finishing by 'button skip')")), "skip is explicitly identified in event logs")

	# Verify the existing global completion path still records a real quest.
	GameEvents.quest_done.connect(QuestManager._on_quests_completed)
	manager = _manager([])
	manager._finish_quest("collect_metal_scraps")
	_check(QuestManager.completed_quests.any(func(quest): return quest.id == "collect_metal_scraps"), "global quest manager records completion")
	_check(logged.has("Quest completed - collect_metal_scraps."), "normal completion log is preserved")
	_check(KDBService.get_triplet_data_text().contains("collect_metal_scraps"), "completion reaches the knowledge database")

	for allocation in allocations:
		allocation.free()
	print("Quest completion regression failures: ", failures)
	get_tree().quit(1 if failures else 0)
