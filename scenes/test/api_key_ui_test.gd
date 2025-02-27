extends PanelContainer

@onready var line_edit: LineEdit = $LineEdit


func _on_line_edit_text_submitted(new_text: String) -> void:
	ChatManager.ApiKey = self.line_edit.text
