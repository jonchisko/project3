extends CanvasLayer

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _message_text: RichTextLabel = %MessageText
@onready var _author_text: RichTextLabel = %AuthorText



func _ready() -> void:
	self._animation_player.play("in")
	

func set_data(author: String, message: String):
	self._author_text.text = "[center]{value}[/center]".format({"value": author})
	self._message_text.text = "[center]{value}[/center]".format({"value": message})
