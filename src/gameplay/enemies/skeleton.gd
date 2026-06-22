extends CharacterBody2D

@export var data: EnemyData
@export var random_movement: bool = false  # whether to move randomly or to Marker2D
@export var move_distance: float = 50. # how many pixels to move

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO  # needed for IDLE state animation
var start_location: Vector2
var target_location: Vector2
var distance_threshold: float = 2. # how many pixels for threshold
enum PHASE {IDLE, WALK_OUT, WALK_BACK}
var current_phase: PHASE = PHASE.IDLE
var prior_phase: PHASE = PHASE.IDLE

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $States
@onready var idle_timer: Timer = $IdleTimer


func _ready() -> void:
	# Start the sprite animation
	anim.sprite_frames = data.frames
	anim.play(data.default_anim)
	
	# Record the starting position
	start_location = self.global_position
	# Set random target location and start walking
	_get_target_location(random_movement)
	current_phase = PHASE.WALK_OUT


func _physics_process(_delta: float) -> void:
	# Check if in idling time
	if current_phase == PHASE.IDLE:
		return
	elif current_phase == PHASE.WALK_OUT:
		_get_direction(target_location)
		prior_phase = PHASE.WALK_OUT
	elif current_phase == PHASE.WALK_BACK:
		_get_direction(start_location)
		prior_phase = PHASE.WALK_BACK
	
	velocity = direction.normalized() * data.speed
	
	# Switch between MOVE/IDLE state
	state_machine.change_state(state_machine.State.MOVE)
	
	# Actually move
	move_and_slide()
	
	# Check if arrived at location
	if current_phase == PHASE.WALK_OUT:
		_check_arrival(target_location)
	else:
		_check_arrival(start_location)


func _check_arrival(target_loc):
	if abs(global_position.distance_to(target_loc)) <= distance_threshold:
		# Start timer
		idle_timer.start()
		# Stop moving
		velocity = Vector2.ZERO
		# Go into IDLE state
		state_machine.change_state(state_machine.State.IDLE)
		current_phase = PHASE.IDLE


func _get_target_location(use_random: bool = true):
	# Set target location to walk to (randomized or Marker2D)
	if use_random:
		var x: float = randf_range(-1, 1)
		var y: float = randf_range(-1, 1)
		target_location = start_location + Vector2(x, y).normalized() * move_distance
	else:
		target_location = $Marker2D.global_position


func _get_direction(loc: Vector2):
	# Get direction to specified location
	direction = global_position.direction_to(loc)


func _on_idle_timer_timeout() -> void:
	# End of Idle timer, set PHASE
	if prior_phase == PHASE.WALK_OUT:
		current_phase = PHASE.WALK_BACK
	else:
		current_phase = PHASE.WALK_OUT


func _on_hurt_box_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.has_method("player"):
		# Store attributes
		GameState.scene_position = body.global_position
		
		# Go to battle screen
		GameState.battle_requested.emit()
