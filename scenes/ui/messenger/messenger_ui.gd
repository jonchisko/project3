extends CanvasLayer

class_name MessengerUi

signal message_created(message: String)

@onready var _animation_player = $AnimationPlayer
@onready var _chat_element_container = %VBoxContainer
@onready var _line_edit = %LineEdit

var _chat_element: PackedScene = preload("res://scenes/ui/messenger/chat_element.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self._animation_player.play("in")
	#self.add_chat_element("Heeej")


func add_chat_element(message: String):
	self._create_chat_element(false, message)


func _create_chat_element(is_player: bool, message: String):
	var chat_element_instance = self._chat_element.instantiate() as ChatElement
	self._chat_element_container.add_child(chat_element_instance)
	chat_element_instance.set_data(is_player, message)
	
	if is_player:
		self.message_created.emit(message)


func _on_line_edit_text_submitted(new_text):
	self._create_chat_element(true, new_text)
	(self._line_edit as LineEdit).text = ""


func _on_close_chat_button_pressed():
	self._animation_player.play("out")
