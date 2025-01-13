@tool
extends Area2D

@export var radius_size: int = 50
@onready var collision_shape = $CollisionShape2D

var _potential_interactable: Interactable = null

func has_interactor() -> bool:
	return self._potential_interactable != null

func get_interactor() -> Interactable:
	return self._potential_interactable

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

func _on_body_entered(body: Node) -> void:
	print("Reporter: {this}: detected: {body}".format({"this": self.name, "body": body.name}))
	if not body.has_node("Interactable"):
		return
		
	var interactable: Node = body.get_node("Interactable") as Interactable
	if self._potential_interactable == null && interactable != null:
		interactable.show_interactive()
		self._potential_interactable = interactable


func _on_body_exited(body: Node2D) -> void:
	print("Reporter: {this}: left: {body}".format({"this": self.name, "body": body.name}))
	if self._potential_interactable != null:
		self._potential_interactable.hide_interactive()
		self._potential_interactable = null
