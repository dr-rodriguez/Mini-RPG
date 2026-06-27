extends Node2D

@export var data: EnemyData

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var audio_player: AudioStreamPlayer = %PlayerFX

func _ready() -> void:
	player_sprite.frame_changed.connect(_on_frame_changed)

func _on_frame_changed() -> void:
	# Check the current frame index and play sound if it matches
	if player_sprite.frame == 1 and player_sprite.animation == "attack_side": 
		audio_player.play()
