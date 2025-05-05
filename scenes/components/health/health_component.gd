extends Node
class_name HealthComponent

signal death
signal life_change(current_life: int)

@export var max_health_points: int = 100

var _health_points: int = 100


func _ready() -> void:
	self._health_points = self.max_health_points


func damage(amount: int) -> void:
	self._health_points = clamp(self._health_points - amount, 0, self.max_health_points)
	self.life_change.emit(_health_points)
	
	if self._health_points == 0:
		self.death.emit()


func heal(amount: int) -> void:
	self._health_points = clamp(self._health_points + amount, 0, self.max_health_points)
	self.life_change.emit(_health_points)
