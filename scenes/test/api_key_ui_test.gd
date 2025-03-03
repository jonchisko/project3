extends PanelContainer

@onready var line_edit: LineEdit = $LineEdit
@onready var chat_manager: Node = $"../../ChatManager"


func _on_line_edit_text_submitted(new_text: String) -> void:
	chat_manager.ApiKey = self.line_edit.text
