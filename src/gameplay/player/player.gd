extends CharacterBody2D

# Emitted the first time the player actually moves.
signal first_moved

# Movement attributes
@export var player_speed: float = 100.
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var dialogue_active: bool = false
var _has_moved: bool = false

# Animations
@onready var anim = $AnimatedSprite2D

# State machine
@onready var state_machine: StateMachine = $States

func _ready() -> void:
	# Dialogue signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _physics_process(_delta: float) -> void:
	if dialogue_active:
		# No movement if in dialogue
		return
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_speed
	move_and_slide()
	
	if direction.length() > 0:
		if not _has_moved:
			_has_moved = true
			first_moved.emit()
		state_machine.change_state(state_machine.State.MOVE)
	else:
		state_machine.change_state(state_machine.State.IDLE)

func _on_dialogue_started(_resource: DialogueResource) -> void:
	dialogue_active = true

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	dialogue_active = false

func player() -> void:
	# Only to detect if this is the player via has_method()
	pass
