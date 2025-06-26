extends StaticBody2D


@export var tree_sprites: Sprite2D
@export var tree_shadows_sprites: Sprite2D
@export var collisions: Array[CollisionShape2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var frame = randi_range(0, 2)
	self.tree_sprites.frame = frame
	self.tree_shadows_sprites.frame = frame
	var collision = self.collisions[frame]
	collision.visible = true
	collision.disabled = false
	$CollisionShapeForNavmesh.disabled = true
	$CollisionShapeForNavmesh.visible = false
