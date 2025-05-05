extends AudioStreamPlayer2D
class_name RandomAudioStreamPlayer


func set_walk_stream(stream: AudioStream):
	self.stream = stream


func play_stream():
	var pitch = randf_range(0.85, 1.15)
	self.pitch_scale = pitch
	self.play()
