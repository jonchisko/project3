extends Node

@export var music: AudioStream
@export var bus: String = "MenuMusic"


func _ready():
	$AudioStreamPlayer.stream = self.music
	$AudioStreamPlayer.bus = self.bus
	$AudioStreamPlayer.playing = true
