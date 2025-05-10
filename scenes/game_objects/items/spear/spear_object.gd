extends Node2D
class_name SpearObject

var target_position: Vector2

@export var speed: int = 10
@export var elipse_b: int = 20

var _source_position: Vector2
var _x_location: float
var _direction: int = -1

var _elipse_a: float

var _throw_x: Vector2
var _throw_y: Vector2

var _circumference: float

var _is_done: bool = false

func _throw_spear(delta: float, target: Vector2):
	self._x_location += (self._direction * delta * self.speed) / self._circumference

	var y = self._throw_y * self.elipse_b * sin(self._x_location)
	var x = self._throw_x * (self._elipse_a * cos(self._x_location) + self._elipse_a)
	
	self.global_position = self._source_position + x + y
	
	var y_1 = -self._throw_y * self.elipse_b * cos(self._x_location)
	var x_1 = -self._throw_x * self._elipse_a * -sin(self._x_location)
	
	self.look_at(self.global_position + x_1 + y_1)
	
	self.visible = true
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	self._source_position = self.position
	if self._source_position.x > self.target_position.x:
		$Sprite2D.flip_v = true
		self._direction = 1
	self._x_location = PI
	
	var throw_vector = self.target_position - self._source_position
	self._throw_x = throw_vector.normalized()
	
	var rotated_by = acos(self._throw_x.dot(Vector2.RIGHT))
	if self._throw_x.y < 0.0:
		rotated_by *= -1
	self._throw_y = Vector2.UP.rotated(rotated_by).normalized()
	
	self._elipse_a = throw_vector.length() / 2
	self.elipse_b = self.elipse_b + 0.3 * self._elipse_a
	
	self._circumference = PI * (3 * (self._elipse_a + self.elipse_b) - 
		sqrt((3 * self._elipse_a + self.elipse_b) * (self._elipse_a + 3 * self.elipse_b))) / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self._throw_spear(delta, self.target_position)
	if not self._is_done and abs(self._x_location - PI) >= PI:
		self._is_done = true
		self._hit()


func _hit():
	$Sprite2D.visible = false
	$DamageArea/CollisionShape2D.set_deferred("disabled", true)
	$CPUParticles2D.emitting = true
	
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer2D.play()
	
	await $AudioStreamPlayer2D.finished
	
	self.call_deferred("queue_free")
