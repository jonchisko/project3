extends CharacterBody2D
class_name Player


@export var dash_range: float = 30.0
@export var dash_cd: float  = 5.0

@onready var _velocity_component: VelocityComponent = $VelocityComponent
@onready var _health_component: HealthComponent = $HealthComponent

@onready var _sprite_2d: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

const _FrameLookingDown = 0
const _FrameLookingUp = 1
const _FrameLookingLeft = 2

var _dash_timer: float = 0.0
var _dash_start_time: float = 0.0


func _ready() -> void:
	$HUDCanvasLayer/LifeCounter.set_max_life(self._health_component.max_health_points)


func _physics_process(delta: float) -> void:
	var direction = self._get_direction()
	self._adjust_sprite_frame(direction)
	
	if Input.is_action_pressed("dash"):
		self._dash(direction)
	
	if (self.velocity.x != 0.0 or self.velocity.y != 0.0) and $WalkSoundTimer.time_left <= 0.0:
		$WalkSoundTimer.start()
		$AudioStreamPlayer2D.play_stream()
	
	self._velocity_component.move_in_direction(self, direction)
	
	
func _get_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		
	return direction.normalized()


func _adjust_sprite_frame(movement_direction: Vector2):
	if movement_direction.y > 0.0:
		self._sprite_2d.frame = self._FrameLookingDown
	if movement_direction.y < 0.0:
		self._sprite_2d.frame = self._FrameLookingUp
	
	# keeping it simple, x has the last word on how to orient the sprite
	if movement_direction.x > 0.0:
		self._sprite_2d.flip_h = true
		self._sprite_2d.frame = self._FrameLookingLeft
	if movement_direction.x < 0.0:
		self._sprite_2d.flip_h = false
		self._sprite_2d.frame = self._FrameLookingLeft


func _dash(movement_direction: Vector2):
	var current_time = Time.get_unix_time_from_system() # Could have used timer
	
	if self._dash_start_time + self.dash_cd <= current_time:
		self._dash_start_time = current_time
		
		# Check for obstacles in dash path
		var space_state = self.get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(
			self.position,
			self.position + movement_direction * self.dash_range,
			self.collision_mask,
			[self]
		)
		var result = space_state.intersect_ray(query);

		self._animation_player.play("dash_start")
		$DashAudioPlayer.play()
		await self._animation_player.animation_finished
		
		if not result.is_empty():
			self.position = result["position"] - movement_direction * Vector2(10, 10)
		else:
			self.position += movement_direction * self.dash_range
		
		self._animation_player.play("dash_end")
		
		$HUDCanvasLayer/Dash.start_cd(self.dash_cd)
		

func _on_damagable_damage_detected(amount):
	_health_component.damage(amount)


func _on_health_component_death():
	self.queue_free()


func _on_health_component_life_change(health_points: int) -> void:
	$HUDCanvasLayer/LifeCounter.change_life(health_points)
	

func _on_floor_audio_detector_area_entered(area: Area2D) -> void:
	var floor_area = area as FloorArea
	if floor_area == null:
		return
	
	$AudioStreamPlayer2D.set_walk_stream(floor_area.get_foot_step_sound())
