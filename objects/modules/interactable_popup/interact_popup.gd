extends PanelContainer

@export var height_delta: float = 30
@export var time: float = 0.3

var _float_tween: Tween
var _end_tween: Tween

func enable_popup() -> void:
	self._enable_popup()
	self._create_float_tween()
	
func disable_popup() -> void:
	self._create_end_tween()

func _create_float_tween() -> void:
	var new_position = Vector2(self.position.x, self.position.y - self.height_delta)
	
	self._float_tween = get_tree().create_tween()
	self._float_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	
	self._float_tween.set_loops()
	self._float_tween.tween_property(self, "position", new_position, self.time).set_trans(Tween.TRANS_CUBIC)
	self._float_tween.tween_property(self, "position", self.position, self.time).set_trans(Tween.TRANS_CUBIC)

func _create_end_tween() -> void:
	self._end_tween = get_tree().create_tween()
	self._end_tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	self._end_tween.tween_callback(self._disable_popup)

func _enable_popup() -> void:
	self.process_mode = Node.ProcessMode.PROCESS_MODE_INHERIT
	self.show()

func _disable_popup() -> void:
	self.process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED
	self.hide()
