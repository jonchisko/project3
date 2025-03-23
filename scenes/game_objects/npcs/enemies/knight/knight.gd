extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_damagable_damage_detected(amount):
	$HealthComponent.damage(amount)


func _on_health_component_death():
	$Damagable/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	$DamageArea/CollisionShape2D.set_deferred("disabled", true)
	
	self._animation_player.play("death")
