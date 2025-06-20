extends Area2D

@export var current_scene: SceneSyncher
@export_file("*.tscn") var new_scene

var _changing_scene: bool = false
var _near_outpost: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self._near_outpost and Input.is_action_just_pressed("interact") and not self._changing_scene:
		print("OutpostArea2D: Changing scene")
		GameEvents.level_change.emit(GameTypes.LevelChangeType.OffLoading)
		self._changing_scene = true
		self.get_tree().change_scene_to_file(self.new_scene)


func _on_area_entered(area: Area2D) -> void:
	self._near_outpost = true
	$Label.visible = true


func _on_area_exited(area: Area2D) -> void:
	self._near_outpost = false
	$Label.visible = false
