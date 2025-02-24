extends PanelContainer
class_name InteractableItemUi


signal selected


@onready var item_icon: TextureRect = %Icon
@onready var item_name: Label = %Name
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _disabled = false 


func set_data(icon: Texture2D, name: String):
	self.item_icon.texture = icon
	self.item_name.text = name


func select_item(delay = .0):
	self._disabled = true
	self.animation_player.play("play_out")
	await self.get_tree().create_timer(delay)
	self.selected.emit()
	
	
func remove_item(delay = .0):
	self._disabled = true
	self.animation_player.play("play_out")
	await self.get_tree().create_timer(delay)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate = Color.TRANSPARENT


func _on_gui_input(event: InputEvent) -> void:
	if self._disabled:
		return
	
	if event.is_action_pressed("left_click"):
		self.select_item()


func _on_mouse_entered() -> void:
	if self._disabled:
		return
		
	self.animation_player.play("hover")
