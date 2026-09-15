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


func _can_access_outpost() -> bool:
	return (
		SceneStateManager.outpost_unlocked
		or self._player_inventory.has_item("outpost_keycode", 1)
	)


func _process(_delta: float) -> void:
	if not self._near_outpost or self._changing_scene:
		return

	if not Input.is_action_just_pressed("interact"):
		return

	if not self._can_access_outpost():
		return

	SceneStateManager.outpost_unlocked = true

	GameEvents.level_change.emit(GameTypes.LevelChangeType.OffLoading)
	self._changing_scene = true
	self.get_tree().change_scene_to_file(self.new_scene)


func _on_area_entered(_area: Area2D) -> void:
	self._near_outpost = true

	var allowed: bool = self._can_access_outpost()
	self.label_allowed.visible = allowed
	self.label_no_access.visible = not allowed


func _on_area_exited(area: Area2D) -> void:
	self._near_outpost = false
	if self.label_allowed.visible:
		self.label_allowed.visible = false
	if self.label_no_access.visible:
		self.label_no_access.visible = false
