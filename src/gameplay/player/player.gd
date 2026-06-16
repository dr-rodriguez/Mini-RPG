extends CharacterBody2D

# Movement attributes
@export var player_speed: float = 100.
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

# Animations
@onready var anim = $AnimatedSprite2D

# State machine
@onready var state_machine: StateMachine = $States


func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * player_speed
	move_and_slide()
	
	if direction.length() > 0:
		state_machine.change_state(state_machine.State.MOVE)
	else:
		state_machine.change_state(state_machine.State.IDLE)
