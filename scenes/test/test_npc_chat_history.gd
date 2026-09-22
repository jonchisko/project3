extends Node
## Run in an isolated project copy; no live LLM calls.

var checks := 0
var failures := 0

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + label)

func call_history(manager: ChatManager, arguments: Dictionary) -> Dictionary:
	return manager._parse_tool_call(ToolCall.new({"id": "history_test", "type": "function",
		"function": {"name": "get_npc_chat_history", "arguments": JSON.stringify(arguments)}}))

func _ready() -> void:
	var manager := ChatManager.new()
	var history := ChatHistoryRust.new()
	manager.chat_history_rust = history
	check(not call_history(manager, {"npc_id": "jurij_vindiš"}).error, "optional offset")
	check(call_history(manager, {"npc_id": "jurij_vindiš"}).call_result.messages.is_empty(), "empty history")
	for args in [{}, {"npc_id": "missing"}, {"npc_id": 3}, {"npc_id": "jurij_vindiš", "offset": -1}, {"npc_id": "jurij_vindiš", "offset": 0.5}, {"npc_id": "jurij_vindiš", "offset": "0"}, {"npc_id": "jurij_vindiš", "offset": 2147483648}]:
		check(call_history(manager, args).error, "invalid arguments")
	var messages: Array = []
	for i in range(22):
		messages.append({"role": "user" if i % 2 == 0 else "assistant", "content": "Dialogue " + str(i)})
	messages.append({"role": "tool", "content": "Other NPC history must not be copied"})
	messages.append({"role": "assistant", "content": ""})
	history.save_conversation("jurij_vindiš", messages)
	history.save_conversation("miha_sitar", [{"role": "assistant", "content": "Different NPC"}])
	var first: Dictionary = call_history(manager, {"npc_id": "jurij_vindiš"}).call_result
	check(first.messages.size() == 20 and first.total_messages == 22 and first.next_offset == 20, "first page and filtered count")
	check(first.messages[0].speaker == "player" and first.messages[1].speaker == "jurij_vindiš", "speaker attribution")
	var last: Dictionary = call_history(manager, {"npc_id": "jurij_vindiš", "offset": first.next_offset}).call_result
	check(last.messages.size() == 2 and last.next_offset == null and last.messages[0].content == "Dialogue 20", "last page chronological")
	check(call_history(manager, {"npc_id": "jurij_vindiš", "offset": 23}).error, "out of bounds")
	check(call_history(manager, {"npc_id": "miha_sitar"}).call_result.messages.size() == 1, "NPC isolation")
	var restored := ChatHistoryRust.new()
	restored.set_history_data(history.get_history_data())
	manager.chat_history_rust = restored
	check(call_history(manager, {"npc_id": "jurij_vindiš"}).call_result == first, "scene-state history roundtrip")
	var strict := StrictGptTemplate.new()
	var loose := LooseGptTemplate.new()
	check(strict._add_function_calling().contains("get_npc_chat_history"), "strict tool instructions included")
	for name in ["has_item", "get_item", "give_item", "complete_quest", "get_npc_chat_history"]:
		check(loose._add_function_calling().contains(name), "loose tool: " + name)
	check(manager._get_npc_chat_history_tool() != null, "tool schema builds")
	strict.free()
	loose.free()
	manager.free()
	history.free()
	restored.free()
	print("NPC history checks: %d; failures: %d" % [checks, failures])
	get_tree().quit(1 if failures else 0)
