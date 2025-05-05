extends PanelContainer
class_name LifeCounterUi

var _max_life: int = 0


func set_max_life(max_life: int):
	self._max_life = max_life
	$MarginContainer/Label.text = "{current}/{max}".format(
		{"current": self._max_life, "max": self._max_life})


func change_life(current: int):
	$AnimationPlayer.play("change")
	$MarginContainer/Label.text = "{current}/{max}".format(
		{"current": current, "max": self._max_life})
