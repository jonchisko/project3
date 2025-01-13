extends PanelContainer

class_name MessengerUi

signal text_input_entered(new_text: String)

@onready var _chat_history = $MarginContainer/VBoxContainer/Label
@onready var _text_input = $MarginContainer/VBoxContainer/LineEdit


func set_chat_history(chat: String) -> void:
	_chat_history.text = chat
	
func clear_chat_history() -> void:
	_chat_history.text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_line_edit_text_submitted(new_text: String) -> void:
	text_input_entered.emit(new_text)
