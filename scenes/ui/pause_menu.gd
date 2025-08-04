extends PanelContainer
class_name PauseMenu


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _is_closing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate = Color.TRANSPARENT
	self.scale = Vector2.ZERO


func open() -> void:
	self.animation_player.play("popin")
	await self.animation_player.animation_finished
	self.get_tree().paused = true


func _on_close_pause_button_pressed() -> void:
	if self._is_closing:
		return
	self._is_closing = true
	
	self.get_tree().paused = false
	self.animation_player.play("popout")
	await self.animation_player.animation_finished


func _on_main_menu_button_pressed() -> void:
	if self._is_closing:
		return
	self._is_closing = true
	
	self.get_tree().paused = false
	self.animation_player.play("popout")
	await self.animation_player.animation_finished
	self.get_tree().change_scene_to_file("res://scenes/ui/menu/main_menu_scene.tscn")
