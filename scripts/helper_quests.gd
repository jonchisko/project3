extends Node
class_name HelperQuests

static func parse_quest_reward(quest_reward: String) -> Dictionary:
	# give_item(outpost_keycode, 1)
	var first_paranthesis_index = quest_reward.find("(")
	var last_paranthesis_index = quest_reward.find(")")
	var comma_index = quest_reward.find(",")
	
	var item: String = quest_reward.substr(first_paranthesis_index + 1, comma_index - (first_paranthesis_index + 1))
	var amount: int = quest_reward.substr(comma_index + 1, last_paranthesis_index - (comma_index + 1)).to_int()
	
	return {"item": item, "amount": amount}
