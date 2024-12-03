@tool
extends Area2D

@export var radius_size: int = 50
@onready var collision_shape = $CollisionShape2D

signal player_entered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = radius_size
	else:
		printerr("The collision shape is not CircleShape2D, but {shape_type}".format({"shape_type": typeof(shape)}))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		self._set_shape_radius(radius_size)


func _set_shape_radius(radius: int) -> void:
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = radius
	else:
		printerr("The collision shape is not CircleShape2D, but {shape_type}".format({"shape_type": typeof(shape)}))

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_entered.emit()
