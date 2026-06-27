extends Node2D

@export var data: EnemyData

@onready var enemy_sprite: AnimatedSprite2D = %EnemySprite
@onready var audio_player: AudioStreamPlayer = %EnemyFX

func _ready() -> void:
	enemy_sprite.frame_changed.connect(_on_frame_changed)

func _on_frame_changed() -> void:
	# Check the current frame index and play sound if it matches
	if enemy_sprite.frame == 3 and enemy_sprite.animation == "attack_side": 
		audio_player.play()
