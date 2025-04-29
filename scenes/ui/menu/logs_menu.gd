extends Control
class_name LogsMenu


signal logs_closed


func _ready():
	self.modulate = Color.TRANSPARENT
	$AnimationPlayer.play("global_ui/in")


func _on_audio_button_pressed():
	$AnimationPlayer.play("global_ui/out_with_free")
	await $AnimationPlayer.animation_finished
	
	self.logs_closed.emit()
