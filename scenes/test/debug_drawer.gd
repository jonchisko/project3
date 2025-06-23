extends Node2D


var from: Vector2
var to: Array[Vector2]

	
func _draw() -> void:
	for t in self.to:
		self.draw_line(self.from, t, Color.RED, 5.0)
	self.to = []
