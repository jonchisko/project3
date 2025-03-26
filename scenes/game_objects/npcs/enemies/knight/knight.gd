extends CharacterBody2D


enum AttackType {
	Basic,
	Special,
}


@export var attack_type_sequence: Array[AttackType]


@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _velocity_component: VelocityComponent = $VelocityComponent
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _attack_timer_cd: Timer = $AttackTimerCd
@onready var _damage_area: DamageArea = $DamageArea


var _current_attack_type_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	self._current_attack_type_index = 0
	self._animation_player.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector2.ZERO
	self._velocity_component.move_in_direction(self, direction)
	if self._attack_timer_cd.is_stopped():
		print(self._attack_timer_cd.is_stopped())
		var attack_type = self._get_next_attack_type()
		self._attack(attack_type)


func _attack(attack_type: AttackType) -> void:
	print("attack")
	match attack_type:
		AttackType.Basic:
			self._damage_area.damage_amount = 5
			self._animation_player.play("attack_strike")
		AttackType.Special: 
			self._damage_area.damage_amount = 15
			self._animation_player.play("attack_swing")
	print("wait")
	await self._animation_player.animation_finished
	print("idle")
	self._animation_player.play("idle")
	
	self._attack_timer_cd.wait_time = 1
	self._attack_timer_cd.start()
	print("start")


func _get_next_attack_type() -> AttackType:
	var attack_type = self.attack_type_sequence[self._current_attack_type_index]
	self._current_attack_type_index = (self._current_attack_type_index + 1) % self.attack_type_sequence.size()
	
	return attack_type


func _on_attack_range_area_entered(area):
	if not area.get_parent() is Player:
		return
		
	if self._attack_timer_cd.is_stopped():
		var attack_type = self._get_next_attack_type()
		self._attack(attack_type)


func _on_damagable_damage_detected(amount):
	self._health_component.damage(amount)


func _on_health_component_death():
	$Damagable/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	$DamageArea/CollisionShape2D.set_deferred("disabled", true)
	$AttackRange/CollisionShape2D.set_deferred("disabled", true)
	
	self._animation_player.play("death")
