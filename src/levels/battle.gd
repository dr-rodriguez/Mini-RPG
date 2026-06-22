extends Node2D

@onready var player_anim := %PlayerSprite
@onready var enemy_anim := %EnemySprite

func _ready() -> void:
	player_anim.play()
	enemy_anim.play()
