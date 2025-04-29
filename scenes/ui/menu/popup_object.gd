extends Control
class_name PopupObject


signal clicked_back_to_main_menu


@export var title: String = ""
@export var description: String = ""
@export var is_information_popup: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.modulate = Color.TRANSPARENT
	
	if self.is_information_popup:
		%MainMenuButton.visible = false
	else:
		%Description.visible = false
		
	%Title.text = self.title
	%Description.text = self.description


func show_popup():
	self.visible = true
	$AnimationPlayer.play("global_ui/in")
	await $AnimationPlayer.animation_finished
	self.get_tree().paused = true


func close_popup():
	self._on_close_button_pressed()


func _on_close_button_pressed():
	$AnimationPlayer.play("global_ui/out")
	await $AnimationPlayer.animation_finished
	self.get_tree().paused = false
	self.visible = false


func _on_main_menu_button_pressed():
	self.get_tree().paused = false
	self.clicked_back_to_main_menu.emit()
