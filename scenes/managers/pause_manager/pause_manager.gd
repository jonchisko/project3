extends Node
class_name PopupManager


@onready var popup_object: PopupObject = $CanvasLayer/PopupObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.popup_object.clicked_back_to_main_menu.connect(self._on_main_menu_clicked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.get_tree().paused and Input.is_action_just_pressed("pause"):
		self.popup_object.show_popup()
	elif self.get_tree().paused and Input.is_action_just_pressed("pause"):
		self.popup_object.close_popup()
	
	
func _on_main_menu_clicked():
	self.get_tree().change_scene_to_file("res://scenes/ui/menu/main_menu_scene.tscn")
