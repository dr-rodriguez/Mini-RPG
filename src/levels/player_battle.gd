extends Node2D

@export var data: EnemyData

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var audio_player: AudioStreamPlayer = %PlayerFX

func _ready() -> void:
	# Connect the frame changed signal
	player_sprite.frame_changed.connect(_on_frame_changed)

func _on_frame_changed() -> void:
	# Check the current frame index and play sound if it matches
	# (Frame indexes start at 0, so frame 3 is the 4th visual frame)
	if player_sprite.frame == 1 and player_sprite.animation == "attack_side": 
		audio_player.play()
