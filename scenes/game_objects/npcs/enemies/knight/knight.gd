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
@onready var _navigation_agent_2d: NavigationAgent2D = $Navigation/NavigationAgent2D



var _current_attack_type_index: int = 0
var _attack_on_cd: bool = false
var _searching: bool = false
var _attacking: bool = false
var _player_in_attack_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self._current_attack_type_index = 0
	self._animation_player.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector2.ZERO
	if self._searching:
		direction = (-self.global_position + self._navigation_agent_2d.get_next_path_position()).normalized()
	self._velocity_component.move_in_direction(self, direction)
	
	#print(self.velocity)
	if not self._attacking:
		if self.velocity.x != 0 or self.velocity.y != 0:
			self._animation_player.play("running")
		else:
			self._animation_player.play("idle")
	
	#if self.velocity.x < 0:
		#self.scale.x = -1
	#if self.velocity.x > 0:
		#self.scale.x = 1


func _attack(attack_type: AttackType) -> void:
	self._attacking = true
	self._attack_on_cd = true
	match attack_type:
		AttackType.Basic:
			self._damage_area.damage_amount = 5
			self._animation_player.play("attack_strike")
		AttackType.Special: 
			self._damage_area.damage_amount = 15
			self._animation_player.play("attack_swing")
	await self._animation_player.animation_finished
	
	self._attacking = false
	self._attack_timer_cd.wait_time = 1.5
	self._attack_timer_cd.start()


func _get_next_attack_type() -> AttackType:
	var attack_type = self.attack_type_sequence[self._current_attack_type_index]
	self._current_attack_type_index = (self._current_attack_type_index + 1) % self.attack_type_sequence.size()
	
	return attack_type


func _on_attack_range_area_entered(area):
	print("In attack range")
	if not area.get_parent() is Player:
		return
	
	self._player_in_attack_range = true
	
	if not self._attack_on_cd:
		print("Enemy attacks")
		var attack_type = self._get_next_attack_type()
		self._attack(attack_type)


func _on_attack_range_area_exited(area: Area2D) -> void:
	if not area.get_parent() is Player:
		return
	self._player_in_attack_range = false
	

func _on_damagable_damage_detected(amount):
	self._animation_player.play("hit")
	self._health_component.damage(amount)


func _on_health_component_death():
	$Damagable/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	$DamageArea/CollisionShape2D.set_deferred("disabled", true)
	$AttackRange/CollisionShape2D.set_deferred("disabled", true)
	
	self._animation_player.play("death")


func _on_attack_timer_cd_timeout() -> void:
	self._attack_on_cd = false
	if self._player_in_attack_range:
		var attack_type = self._get_next_attack_type()
		self._attack(attack_type)


func _on_ai_controller_component_move_to(location: Vector2) -> void:
	self._searching = true
	self._navigation_agent_2d.target_position = location


func _on_navigation_agent_2d_navigation_finished() -> void:
	self._searching = false
