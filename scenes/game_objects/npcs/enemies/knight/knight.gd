extends CharacterBody2D
class_name KnightNpc

enum AttackType {
	Basic,
	Special,
}


@export var attack_type_sequence: Array[AttackType]
@export var floor: FloorLevelChanger.Level

var nearby_obstacles: Array[Node2D]

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _velocity_component: VelocityComponent = $VelocityComponent
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _attack_timer_cd: Timer = $AttackTimerCd
@onready var _damage_area: DamageArea = $DamageArea
@onready var _navigation_agent_2d: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var _steering_behaviour: SteeringBehaviour = $Navigation/SteeringBehaviour



var _current_attack_type_index: int = 0
var _attack_on_cd: bool = false
var _searching: bool = false
var _attacking: bool = false
var _player_in_attack_range: bool = false
var _is_dying: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	($Floorable as Floorable).set_floor_level(self.floor)
	self._current_attack_type_index = 0
	self._animation_player.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector2.ZERO
	if self._searching:
		direction = self._steering_behaviour.get_direction().normalized()
		#direction = (-self.global_position + self._navigation_agent_2d.get_next_path_position()).normalized()
	if not self._is_dying:
		self._velocity_component.move_in_direction(self, direction)
	
	#print(self.velocity)
	if not self._attacking and not self._is_dying and self._animation_player.current_animation != "hit":
		if self.velocity.x != 0 or self.velocity.y != 0:
			self._animation_player.play("running")
		else:
			self._animation_player.play("idle")
	
	if self.velocity.x < -0.1:
		$Sprite2D.flip_h = true
	if self.velocity.x > 0.1:
		$Sprite2D.flip_h = false


func _attack(attack_type: AttackType) -> void:
	self._attacking = true
	self._attack_on_cd = true
	match attack_type:
		AttackType.Basic:
			self._damage_area.damage_amount = 20
			self._animation_player.play("attack_strike")
		AttackType.Special: 
			self._damage_area.damage_amount = 40
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
	print("Knight: damage_hit")
	self._animation_player.play("hit")
	self._health_component.damage(amount)


func _on_health_component_death():
	self._is_dying = true
	
	print("Knight: death")
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


func _play_sword_sound() -> void:
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer2D.play()


func _on_ai_controller_component_obstacled_in_proximity(obstacle: Node2D) -> void:
	if obstacle != self:
		self.nearby_obstacles.push_back(obstacle)


func _on_ai_controller_component_obstacled_out_of_proximity(obstacle: Node2D) -> void:
	var index = self.nearby_obstacles.find(obstacle)
	if index >= 0:
		self.nearby_obstacles.remove_at(index)
