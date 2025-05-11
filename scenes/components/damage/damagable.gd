extends Area2D
class_name Damagable

signal damage_detected(amount: int)


func _on_area_entered(area):
	var damage = area as DamageArea
	if damage == null:
		return
		
	print("Damagable: emitting damage!")
	self.damage_detected.emit(damage.damage_amount)
