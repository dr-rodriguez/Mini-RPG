extends CharacterBody2D

@export var data: EnemyData
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $States


func _ready() -> void:
	anim.sprite_frames = data.frames
	anim.play(data.default_anim)


func _physics_process(_delta: float) -> void:
	# TODO: Add some random movement
	pass
