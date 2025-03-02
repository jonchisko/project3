extends InteractableUiBase
class_name InteractableNpcUi


@onready var item_icon: TextureRect = %Icon
@onready var item_name: Label = %Name
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _disabled = false 


func remove_item():
	self._disabled = true
	self.animation_player.play("play_out")
	

func _select_item():
	self._disabled = true
	self.animation_player.play("play_selected")
	await self.animation_player.animation_finished
	self.selected.emit()
	self._disabled = false
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate = Color.TRANSPARENT


func _on_gui_input(event: InputEvent) -> void:
	if self._disabled:
		return
	
	if event.is_action_pressed("left_click"):
		self._select_item()


func _on_mouse_entered() -> void:
	if self._disabled:
		return
		
	self.animation_player.play("hover")
	await self.animation_player.animation_finished
