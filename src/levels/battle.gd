extends Node2D


@onready var player_anim := %PlayerSprite
@onready var enemy_anim := %EnemySprite
@onready var btn_flee := %Flee


func _ready() -> void:
	player_anim.play()
	enemy_anim.play()
	


func _on_flee_pressed() -> void:
	# TODO: Add check to see if Flee is successful
	leave_battle()


func leave_battle() -> void:
	queue_free()
