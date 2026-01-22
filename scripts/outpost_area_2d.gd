extends Area2D

@export var current_scene: SceneSyncher
@export_file("*.tscn") var new_scene


@onready var label_no_access: Label = $TargetNode/LabelNoAccess
@onready var label_allowed: Label = $TargetNode/LabelAllowed


var _changing_scene: bool = false
var _near_outpost: bool = false


var _player_inventory: InventoryManager


func _ready() -> void:
	self._player_inventory = self.get_tree().get_first_node_in_group("player").find_child("InventoryManager") as InventoryManager


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self._near_outpost and self._player_inventory.has_item("outpost_keycode", 1) and Input.is_action_just_pressed("interact") and not self._changing_scene:
		print("OutpostArea2D: Changing scene")
		GameEvents.level_change.emit(GameTypes.LevelChangeType.OffLoading)
		self._changing_scene = true
		self.get_tree().change_scene_to_file(self.new_scene)


func _on_area_entered(area: Area2D) -> void:
	self._near_outpost = true
	if self._player_inventory.has_item("outpost_keycode", 1):
		self.label_allowed.visible = true
	else:
		self.label_no_access.visible = true


func _on_area_exited(area: Area2D) -> void:
	self._near_outpost = false
	if self.label_allowed.visible:
		self.label_allowed.visible = false
	if self.label_no_access.visible:
		self.label_no_access.visible = false
