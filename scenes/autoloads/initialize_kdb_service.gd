extends Node


func _ready():
	for npc_id in ResourceDictionary.npc_ids:
		var npc_resource: InteractableResource = ResourceDictionary.ResourceIdToResource[npc_id]
		for quest in npc_resource.data.quest_data:
			var item_data = HelperQuests.parse_quest_reward(quest.get_reward())
			if item_data["item"].is_empty():
				continue
			KDBService.update_ownership_quantity(item_data["item"], npc_resource.data.id, item_data["amount"])
