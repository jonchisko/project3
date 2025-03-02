extends PanelContainer
class_name InteractableUiBase


signal selected


func set_data(icon: Texture2D, name: String):
	self.item_icon.texture = icon
	self.item_name.text = name


func remove_item():
	pass
