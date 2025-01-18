extends CanvasLayer

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _message_text: RichTextLabel = %MessageText
@onready var _author_text: RichTextLabel = %AuthorText

@onready var h_separator_left: HSeparator = %HSeparatorLeft
@onready var h_separator_right: HSeparator = %HSeparatorRight


func _ready() -> void:
	self._animation_player.play("in")
	

func set_data(is_player: bool, author: String, message: String):
	self._set_alignment(is_player)
	self._author_text.text = "[center]{value}[/center]".format({"value": author})
	self._message_text.text = "[center]{value}[/center]".format({"value": message})


func _set_alignment(is_player: bool):
	if is_player:
		self.h_separator_left.visible = true
		self.h_separator_right.visible = false
	else:
		self.h_separator_left.visible = false
		self.h_separator_right.visible = true
