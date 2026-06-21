extends CharacterBody2D

@export var data: EnemyData

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.sprite_frames = data.frames
	anim.play(data.default_anim)
