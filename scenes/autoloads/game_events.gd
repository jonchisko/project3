extends Node


signal initiate_npc_interaction(npc: InteractableNpc)
signal interact_with_interactable(interactable: InteractableArea)
signal item_used(item_id: String)
signal level_change(load_type: GameTypes.LevelChangeType)
