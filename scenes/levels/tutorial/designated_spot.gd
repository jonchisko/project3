extends Node2D
class_name DesignatedSpot

signal player_entered


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		self.player_entered.emit()
