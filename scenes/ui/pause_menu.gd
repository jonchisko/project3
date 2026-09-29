extends PanelContainer
class_name PauseMenu


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _is_closing: bool = false
var _is_death_menu: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate = Color.TRANSPARENT
	self.scale = Vector2.ZERO


func open(is_death_menu: bool = false) -> void:
	_is_death_menu = is_death_menu
	if _is_death_menu:
		$MarginContainer/VBoxContainer/MarginContainer/Label.text = "YOU DIED"
		$MarginContainer/VBoxContainer/MarginContainer2/Label.text = "Your run has ended."
		$MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/ClosePauseButton.hide()
		$MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/QuitGameButton.grab_focus()
		self.get_tree().paused = true
	self.animation_player.play("popin")
	await self.animation_player.animation_finished
	self.get_tree().paused = true


func _on_close_pause_button_pressed() -> void:
	if self._is_closing or _is_death_menu:
		return
	self._is_closing = true
	
	self.get_tree().paused = false
	self.animation_player.play("popout")
	await self.animation_player.animation_finished


func _on_main_menu_button_pressed() -> void:
	if self._is_closing:
		return
	self._is_closing = true
	if _is_death_menu:
		self.get_tree().quit()
		return
	
	self.get_tree().paused = false
	self.animation_player.play("popout")
	await self.animation_player.animation_finished
	self.get_tree().quit()
