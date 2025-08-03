extends PanelContainer
class_name TaskUi

func set_task_description(text: String) -> void:
	$VBoxContainer/MarginContainer/Description.text = text


func set_task_goal(text: String) -> void:
	$VBoxContainer/MarginContainer2/Goal.text = text
