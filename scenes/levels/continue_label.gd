extends Label

var _color_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._color_tween = self.create_tween()
	self._color_tween.set_loops()
	self._color_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.6)
	self._color_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	self._color_tween.tween_property(self, "modulate", Color.WHITE, 0.6)
	self._color_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	self._color_tween.play()
