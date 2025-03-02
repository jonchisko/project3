extends MarginContainer

class_name ChatElement

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _message_text: RichTextLabel = %MessageText

@onready var _h_separator_left = $HBoxContainerMessage/HSeparatorLeft
@onready var _h_separator_right = $HBoxContainerMessage/HSeparatorRight


func _ready() -> void:
	self._reset_chat_element()
	self._animation_player.play("in")


func set_data(is_player: bool, message: String):
	self._set_alignment(is_player)
	
	if not self._message_text.text.is_empty():
		self._animation_player.play("text_out")
		await self._animation_player.animation_finished
		self._set_new_text(message, true)
	else:
		self._set_new_text(message, false)


func _set_alignment(is_player: bool):
	if is_player:
		self._h_separator_left.visible = true
		self._h_separator_right.visible = false
	else:
		self._h_separator_left.visible = false
		self._h_separator_right.visible = true
		

func _reset_chat_element():
	self._message_text.text = ""
	
	
func _set_new_text(text: String, with_animation: bool):
	self._message_text.text = "[center]{value}[/center]".format({"value": text})
	if with_animation:
		self._animation_player.play("text_in")
