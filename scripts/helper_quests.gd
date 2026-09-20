extends Node
class_name HelperQuests

static func parse_quest_reward(quest_reward: String) -> Dictionary:
	var pattern := RegEx.new()
	pattern.compile("^give_item\\(\\s*([^,()]+)\\s*,\\s*([0-9]+)\\s*\\)$")
	var result: RegExMatch = pattern.search(quest_reward.strip_edges())
	if result == null:
		return {"item": "", "amount": 0}
	return {"item": result.get_string(1).strip_edges(), "amount": result.get_string(2).to_int()}


static func get_initial_ownership(quests: Array[QuestResource], starting_items: Dictionary = {}) -> Dictionary:
	var items: Dictionary = {}
	for item_id in starting_items:
		var amount = starting_items[item_id]
		if not ResourceDictionary.item_ids.has(item_id) or typeof(amount) != TYPE_INT:
			return {"items": {}, "error": "Invalid starting item or quantity: " + str(item_id)}
		if amount <= 0 or amount > 2147483647:
			return {"items": {}, "error": "Starting item quantity is out of range: " + str(item_id)}
		items[item_id] = amount
	for quest in quests:
		for reward in quest.rewards:
			var parsed: Dictionary = parse_quest_reward(str(reward))
			if parsed.item.is_empty():
				if str(reward).strip_edges().begins_with("give_item"):
					return {"items": {}, "error": "Malformed item reward in quest " + quest.id}
				continue
			if not ResourceDictionary.item_ids.has(parsed.item) or parsed.amount <= 0:
				return {"items": {}, "error": "Invalid item reward in quest " + quest.id}
			items[parsed.item] = items.get(parsed.item, 0) + parsed.amount
			if items[parsed.item] > 2147483647:
				return {"items": {}, "error": "Item reward quantity is too large"}
	return {"items": items, "error": ""}
