extends PanelContainer
class_name DashUi

@onready var _cd_foreground: ColorRect = $MarginContainer/TextureRect/ColorRect

var _original_y_size: int = 0.0
var _is_on_cd: bool = false
var _cd_duration: float = 0.0
var _cd_left: float = 0.0


func start_cd(duration: float):
	# if not yet set
	if self._original_y_size == 0.0:
		self._original_y_size = self._cd_foreground.size.y
	
	$MarginContainer/TextureRect/ColorRect.visible = true
	self._cd_foreground.offset_top = 0
	self._is_on_cd = true
	self._cd_left = duration
	self._cd_duration = duration


func _set_cd_foreground(percentage: float):
	self._cd_foreground.offset_top = int(self._original_y_size * percentage)
	if percentage >= 1.0:
		print("DASH UI CONTROLLER: DASH READY")
		$AnimationPlayer.play("dash_ready")
		$MarginContainer/TextureRect/ColorRect.visible = false
		self._is_on_cd = false


func _ready():
	$MarginContainer/TextureRect/ColorRect.visible = false


func _process(delta: float) -> void:
	if self._is_on_cd:
		self._set_cd_foreground(1.0 - self._cd_left/self._cd_duration)
		self._cd_left = maxf(self._cd_left - delta, 0.0)
