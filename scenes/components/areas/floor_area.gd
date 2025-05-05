extends Area2D
class_name FloorArea

@export var _foot_step_sound: AudioStream


func get_foot_step_sound() -> AudioStream:
	return self._foot_step_sound
