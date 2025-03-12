extends MarginContainer
class_name ItemInformationUi


signal item_used(index: int)

@onready var icon_texture: TextureRect = %IconTexture
@onready var label: Label = %Label

var _item_index: int


func set_data(item_index: int, name: String, description: String, icon: Texture2D):
	self._item_index = item_index
	self.label.text = "{name}: {description}".format({"name": name, "description": description})
	self.icon_texture.texture = icon


func _on_use_button_pressed() -> void:
	item_used.emit(self._item_index)
	self.queue_free()

func _on_close_button_pressed() -> void:
	self.queue_free()
