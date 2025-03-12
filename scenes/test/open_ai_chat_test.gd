extends Node2D

@export var chatManager: ChatManager

@onready var _button: Button = %Button
@onready var _line_edit: LineEdit = %LineEdit
@onready var interactable_npc = $InteractableNpc


# Called when the node enters the scene tree for the first time.
func _ready():
	self._button.disabled = self._line_edit.text.is_empty()


func _on_button_pressed():
	GameEvents.initiate_npc_interaction.emit(interactable_npc as InteractableNpc)


func _on_line_edit_text_submitted(new_text):
	if self._button.disabled:
		self._button.disabled = false
		
	chatManager.ApiKey = self._line_edit.text
