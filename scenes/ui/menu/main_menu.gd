extends Control
class_name MainMenu


var _options_scene = preload("res://scenes/ui/menu/options_menu.tscn")
var _logs_scene = preload("res://scenes/ui/menu/logs_menu.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = Color.TRANSPARENT
	self._enabled_menu()


func _on_play_button_pressed():
	if OpenAiConfiguration.open_ai_api_key.is_empty():
		printerr("Open AI API key is not set.")
		($PopupObject as PopupObject).show_popup()
		return
		
	self.get_tree().change_scene_to_file("res://scenes/test/test_map.tscn")
	

func _on_tutorial_button_pressed():
	if OpenAiConfiguration.open_ai_api_key.is_empty():
		printerr("Open AI API key is not set.")
		($PopupObject as PopupObject).show_popup()
		return
		
	self.get_tree().change_scene_to_file("res://scenes/levels/tutorial/tutorial_map.tscn")


func _on_options_button_pressed():
	$AnimationPlayer.play("global_ui/out")
	await $AnimationPlayer.animation_finished
	
	var instantiated = self._options_scene.instantiate() as OptionsMenu
	self.get_tree().root.add_child(instantiated)
	
	instantiated.options_closed.connect(self._enabled_menu)


func _on_logs_button_pressed():
	$AnimationPlayer.play("global_ui/out")
	await $AnimationPlayer.animation_finished
	
	var instantiated = self._logs_scene.instantiate() as LogsMenu
	self.get_tree().root.add_child(instantiated)
	
	instantiated.logs_closed.connect(self._enabled_menu)


func _on_quit_button_pressed():
	self.get_tree().quit()


func _enabled_menu():
	$AnimationPlayer.play("global_ui/in")
