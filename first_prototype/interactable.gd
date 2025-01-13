extends Node

class_name Interactable

@export var object_to_interact: Node = null

@onready var _popup = $InteractPopup

func show_interactive() -> void:
	self._popup.enable_popup()
	
func hide_interactive() -> void:
	self._popup.disable_popup()
