extends Node
class_name SpearController


@export var player: Node2D
@export var inventory: InventoryManager
## Spear throw range in pixel units
@export var spear_throw_range: int 
@export var spear_range: SpearRange

var _spear_object: PackedScene = preload("res://scenes/game_objects/items/spear/spear_object.tscn")
var _spear_throw_range_squared: int

var _is_on_cd: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._spear_throw_range_squared = self.spear_throw_range * self.spear_throw_range
	
	self.spear_range.visible = false
	self.spear_range.pixel_size = 2 * self.spear_throw_range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self._is_aiming():
		self.spear_range.visible = true
		
		if Input.is_action_just_pressed("left_click") and not self._is_on_cd:
			self._is_on_cd = true
			var spear_target = self.get_viewport().get_mouse_position()
			spear_target = self.get_viewport().canvas_transform.inverse().origin + spear_target
			if (spear_target - self.player.position).length_squared() > self._spear_throw_range_squared:
				spear_target = self.player.position + (spear_target - self.player.position).normalized() * self.spear_throw_range
			
			var instantiated = self._spear_object.instantiate() as SpearObject
			
			instantiated.global_position = self.player.position
			instantiated.target_position = spear_target
			
			self.player.add_child(instantiated)
			instantiated.owner = self.player
			
			$TimerCd.start()
	else:
		self.spear_range.visible = false
		
		
func _is_aiming() -> bool:
	return Input.is_action_pressed("right_click") and self.inventory.has_item("wajdovian_spear", 1)
		


func _on_timer_cd_timeout() -> void:
	print("Spear fire CD reached")
	self._is_on_cd = false
