extends MarginContainer

class_name ChatElement

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _message_text: RichTextLabel = %MessageText

@onready var _h_separator_left = $HBoxContainerMessage/HSeparatorLeft
@onready var _h_separator_right = $HBoxContainerMessage/HSeparatorRight


func _ready() -> void:
	self._animation_player.play("in")
	

func set_data(is_player: bool, message: String):
	self._set_alignment(is_player)
	self._message_text.text = "[center]{value}[/center]".format({"value": message})


func _set_alignment(is_player: bool):
	if is_player:
		self._h_separator_left.visible = true
		self._h_separator_right.visible = false
	else:
		self._h_separator_left.visible = false
		self._h_separator_right.visible = true
