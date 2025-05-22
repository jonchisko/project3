extends Area2D
class_name Floorable


@export var items_to_be_floored: Array[CanvasItem]
@export var current_floor: FloorLevelChanger.Level = FloorLevelChanger.Level.Ground


func set_floor_level(floor: FloorLevelChanger.Level) -> void:
	self.current_floor = floor
	for item in self.items_to_be_floored:
		item.z_index = self.current_floor
