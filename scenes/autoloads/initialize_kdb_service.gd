extends Node


func _ready():
	for npc_id in ResourceDictionary.npc_ids:
		var npc_resource: InteractableResource = ResourceDictionary.ResourceIdToResource[npc_id]
		var initial: Dictionary = HelperQuests.get_initial_ownership(npc_resource.data.quest_data)
		if not initial.error.is_empty():
			push_error("Cannot initialize ownership for " + npc_id + ": " + initial.error)
			continue
		if not KDBService.replace_ownership(npc_id, initial.items):
			push_error("Cannot initialize ownership for " + npc_id)
