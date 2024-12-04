@tool
extends EditorPlugin

const _custom_type_name: String = "OpenAi"

func _enter_tree() -> void:
	add_custom_type(
		_custom_type_name, 
		"Node",
		preload("res://addons/got_open_ai/src/got_open_ai.gd"),
		preload("res://icon.svg")
		)

func _exit_tree() -> void:
	remove_custom_type(_custom_type_name)	
