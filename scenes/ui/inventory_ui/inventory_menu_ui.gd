extends CanvasLayer
class_name InventoryMenuUi

signal item_used(item_id: String)

@onready var item_list: ItemList = %ItemList
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var item_information_ui: PackedScene = preload("res://scenes/ui/inventory_ui/item_information.tscn")

var _item_array_data: Array[Dictionary] = []


func _ready() -> void:
	self.visible = false
	$MarginContainer.modulate = Color.TRANSPARENT
	$MarginContainer/ColorRect.modulate = Color.TRANSPARENT
	
	self.item_list.item_clicked.connect(self._on_item_in_list_clicked)


func open_inventory(item_data: Array[Dictionary]) -> void:
	self._populate_data(item_data)
	self.animation_player.play("in")
	self.animation_player.animation_finished

func close_inventory() -> void:
	self.animation_player.play("out")
	

func _populate_data(item_data: Array[Dictionary]) -> void:
	self.item_list.clear()
	self._item_array_data = item_data
	
	for item in self._item_array_data:
		var name_amount = "{n} : {a}".format({"n": item["name"], "a": item["amount"]})
		self.item_list.add_item(name_amount, item["icon"], true)
		
	
func _on_item_in_list_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_name = self._item_array_data[index]["name"]
	var item_description = self._item_array_data[index]["description"]
	var item_icon = self._item_array_data[index]["icon"]
	
	var instantiated_item_information = self.item_information_ui.instantiate() as ItemInformationUi
	self.add_child(instantiated_item_information)
	instantiated_item_information.item_used.connect(self._on_item_used)
	instantiated_item_information.set_data(index, item_name, item_description, item_icon)
	

func _on_item_used(index: int) -> void:
	var item = self._item_array_data[index]
	var item_id = item["id"]
	item["amount"] -= 1
	
	if item["amount"] > 0:
		var name_amount = "{n} : {a}".format({"n": item["name"], "a": item["amount"]})
		self.item_list.set_item_text(index, name_amount)
	else:
		self._item_array_data.remove_at(index)
		self.item_list.remove_item(index)
	
	self.item_used.emit(item_id)
	
	pass
