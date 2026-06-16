extends CharacterBody2D

# Movement attributes
@export var player_speed: float = 100.
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

# Animations
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * player_speed
	move_and_slide()
	
	# TODO: Rework this to a StateManager
	if direction.length() > 0:
		move_animation()
	else:
		idle_animation()

func move_animation() -> void:
	# Helper function to handle animation based on direction

	# Regular movement
	if direction.x < 0:
		anim.animation = "walk_side"
		anim.flip_h = true
	elif direction.x > 0:
		anim.animation = "walk_side"
		anim.flip_h = false
	elif direction.y < 0:
		anim.animation = "walk_back"
	elif direction.y > 0:
		anim.animation = "walk_front"
	
	anim.play()
	
	# Direction for idle
	last_direction = direction

func idle_animation() -> void:
	# Idle animations
	
	if last_direction.x < 0:
		anim.animation = "idle_side"
		anim.flip_h = true
	elif last_direction.x > 0:
		anim.animation = "idle_side"
		anim.flip_h = false
	elif last_direction.y < 0:
		anim.animation = "idle_back"
	elif last_direction.y > 0:
		anim.animation = "idle_front"
	
	anim.play()
