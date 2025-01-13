extends AudioStreamPlayer

@export var streams: Array[AudioStream]
var t = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.streams.is_empty():
		printerr(self.name + ": " + "Streams is empty.")
		return
	
	self.stream = self.streams.pick_random()
	self.pitch_scale = randf_range(0.9, 1.1)
