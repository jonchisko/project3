extends CharacterBody2D

signal start_interaction(interactable: Interactable)
signal stop_interaction

@export
var speed: float = 50

@onready var interactor = $InteractorDetector

var _movement_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if self._movement_enabled:
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		
	set_velocity(velocity.normalized() * self.speed)
	move_and_slide()
	
	
	if Input.is_action_pressed("interact"):
		if interactor.has_interactor():
			print("Player start interact.")
			self._movement_enabled = false
			start_interaction.emit(interactor.get_interactor())
			
	if Input.is_action_pressed("cancel_interact"):
		if interactor.has_interactor():
			print("Player stop interact.")
			self._movement_enabled = true
			stop_interaction.emit()
