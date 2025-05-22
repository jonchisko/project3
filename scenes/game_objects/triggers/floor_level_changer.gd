extends Area2D
class_name FloorLevelChanger

enum Level { Ground = -15, Floor1 = -10, Cellar1 = -20}

@export var level: FloorLevelChanger.Level = FloorLevelChanger.Level.Floor1


func _on_area_entered(area: Area2D) -> void:
	var floorable = area as Floorable
	if floorable == null:
		return
	
	print("FloorLevelChanger: changing level to:")
	print(self.level)
	floorable.set_floor_level(self.level)
