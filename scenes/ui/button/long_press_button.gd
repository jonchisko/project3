extends Button

signal long_pressed

@export var change_speed: float = 1

@onready var color_rect: ColorRect = $ColorRect

var _pressed: bool = false


func _ready() -> void:
	print("ready")
	pass


func _process(delta: float) -> void:
	if not self._pressed and self.color_rect.size.x > 0:
		self.color_rect.size.x = max(self.color_rect.size.x - self.change_speed * delta, 0)
		return
	
	if self._pressed:
		self.color_rect.size.x = min(self.color_rect.size.x + self.change_speed * delta, self.size.x)

		if self.color_rect.size.x >= self.size.x:
			long_pressed.emit()

			self._pressed = false
			self.color_rect.size.x = 0.0
			self.color_rect.visible = false


func _on_pressed() -> void:
	$AudioStreamPlayer.play()


func _on_button_down() -> void:
	self._pressed = true
	self.color_rect.visible = true


func _on_button_up() -> void:
	self._pressed = false
