extends Node

class_name ConversationManager

@export var ApiKey: String = ""

@onready var _messenger_ui: MessengerUi = $CanvasLayer/MessengerUi
@onready var _got_open_ai: GotOpenAi = $GotOpenAi

var _gpt_template: TemplateBase = null
var _interactable: Interactable = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
	
func _start_interaction(interactable: Interactable) -> void:
	if self._interactable == null and interactable.object_to_interact is Npc01:
		self._interactable = interactable
		self._interactable.hide_interactive()
		self._messenger_ui.show()
		self._create_gpt_template(self._interactable.object_to_interact as Npc01)

func _cancel_interaction() -> void:
	if self._interactable != null:
		self._interactable.show_interactive()
		self._interactable = null
		self._messenger_ui.clear_chat_history()
		self._messenger_ui.hide()
		self._gpt_template = null

func _create_gpt_template(npc: Npc01) -> void:
	var user_configuration = UserConfiguration.new(self.ApiKey)
	self._got_open_ai.user_configuration = user_configuration
	self._gpt_template = self._got_open_ai.GetGptCompletion()\
		.get_template()\
		.append_static_context("system", "You role-play as the non-player-character.")\
		.append_static_context("system", "Here is the description of your non-player-character: {desc}".format({"desc": npc.ShortDescription}))

func _on_messenger_ui_text_input_entered(new_text: String) -> void:
	self._gpt_template.append_message("user", new_text)
	self._messenger_ui.set_chat_history(self._gpt_template.show_messages())
	
	var response = await self._gpt_template.get_reply()
	print(response)
	
	if response.successful():
		self._gpt_template.append_message("assistant", response.choices()[0]["message"]["content"])
		self._messenger_ui.set_chat_history(self._gpt_template.show_messages())
	else:
		self._gpt_template.append_message("system", "<No response from assistant.>")
	# TODO get structured message data ?  + get structured static data ? get text messages / get text static context


func _on_player_start_interaction(interactable: Interactable) -> void:
	print("ConversationManager: player started interacting.")
	self._start_interaction(interactable)


func _on_player_stop_interaction() -> void:
	print("ConversationManager: player stoped interacting.")
	self._cancel_interaction()
