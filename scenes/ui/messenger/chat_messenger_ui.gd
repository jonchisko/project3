extends CanvasLayer

class_name ChatMessengerUi

signal message_created(message: String)
signal chat_closed
signal skip_quest

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _chat_element_container = %VBoxContainer
@onready var _chat_scroll: ScrollContainer = %VBoxContainer.get_parent()
@onready var _line_edit = %LineEdit
@onready var _panel_container: PanelContainer = $PanelContainer

var _chat_element: PackedScene = preload("res://scenes/ui/messenger/chat_element.tscn")

var _last_npc_chat_element: ChatElement

var is_closing: bool = false
var request_pending: bool = false
var has_quest: bool = false


func set_has_quest(value: bool) -> void:
	has_quest = value
	_update_skip_button()


func _update_skip_button() -> void:
	var button = get_node_or_null("PanelContainer2/HBoxContainer/LongPressButton")
	if button != null:
		button.disabled = request_pending or not has_quest
		button.tooltip_text = "" if has_quest else "This NPC has no quests left to skip."


func set_request_pending(value: bool) -> void:
	request_pending = value
	_line_edit.editable = not value
	_update_skip_button()
	$PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/CloseChatButton.disabled = value

# Called when the node enters the scene tree for the first time.
func _ready():
	# Follow the final layout, including replies updated after their text animation.
	_chat_scroll.get_v_scroll_bar().changed.connect(_scroll_to_latest_message)
	_update_skip_button()
	if self._animation_player.is_playing():
		await self._animation_player.animation_finished
	
	self._panel_container.modulate = Color.TRANSPARENT
	self.get_tree().paused = true
	self._animation_player.play("in")


func _scroll_to_latest_message() -> void:
	if not is_closing:
		_chat_scroll.scroll_vertical = int(_chat_scroll.get_v_scroll_bar().max_value)


func add_chat_element(message: String):
	self._last_npc_chat_element = self._create_chat_element(false, message)
	
	
func edit_last_chat_element(message: String):
	self._last_npc_chat_element.set_data(false, message)


func close_chat():
	if self.is_closing or self.get_tree() == null:
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
	if request_pending or is_closing or new_text.strip_edges().is_empty():
		return
	self._create_chat_element(true, new_text)
	(self._line_edit as LineEdit).text = ""


func _on_close_chat_button_pressed():
	if request_pending:
		return
	self.close_chat()


func _on_long_press_button_long_pressed() -> void:
	if request_pending or is_closing or not has_quest:
		return
	self.skip_quest.emit()
