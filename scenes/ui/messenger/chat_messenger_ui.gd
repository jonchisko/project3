extends CanvasLayer

class_name ChatMessengerUi

signal message_created(message: String)
signal chat_closed

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _chat_element_container = %VBoxContainer
@onready var _line_edit = %LineEdit
@onready var _panel_container: PanelContainer = $PanelContainer

var _chat_element: PackedScene = preload("res://scenes/ui/messenger/chat_element.tscn")

var _last_npc_chat_element: ChatElement

var is_closing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if self._animation_player.is_playing():
		await self._animation_player.animation_finished
	
	self._panel_container.modulate = Color.TRANSPARENT
	self.get_tree().paused = true
	self._animation_player.play("in")


func add_chat_element(message: String):
	self._last_npc_chat_element = self._create_chat_element(false, message)
	
	
func edit_last_chat_element(message: String):
	self._last_npc_chat_element.set_data(false, message)


func close_chat():
	if self.is_closing:
		return
	
	self.is_closing = true
	
	self.get_tree().paused = false
	self._animation_player.play("out")
	await self._animation_player.animation_finished
	self.chat_closed.emit()


func _create_chat_element(is_player: bool, message: String) -> ChatElement:
	var chat_element_instance = self._chat_element.instantiate() as ChatElement
	self._chat_element_container.add_child(chat_element_instance)
	chat_element_instance.set_data(is_player, message)
	
	if is_player:
		self.message_created.emit(message)
		
	return chat_element_instance


func _on_line_edit_text_submitted(new_text):
	self._create_chat_element(true, new_text)
	(self._line_edit as LineEdit).text = ""


func _on_close_chat_button_pressed():
	self.close_chat()
