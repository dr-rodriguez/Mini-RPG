extends Node2D

# Passed by the main_game script
@export var enemy: Node

@onready var player_anim := %PlayerSprite
@onready var enemy_anim := %EnemySprite
@onready var btn_flee := %Flee
@onready var label_log := %LogLabel
@onready var log_text: String = ""

func _ready() -> void:
	player_anim.play()
	enemy_anim.play()


func damage_enemy(damage) -> void:
	enemy.take_damage(damage)
	if enemy.health <= 0:
		enemy.queue_free()
		leave_battle()


func damage_player(damage) -> void:
	PlayerData.take_damage(damage)


func player_roll_to_hit() -> void:
	var roll = PlayerData.roll_attack()
	log_text = "Roll: " + str(roll)
	if roll >= enemy.data.stats.armor_class:
		var damage = PlayerData.roll_damage()
		damage_enemy(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"
	
	# Set the battle log label
	label_log.text = log_text


func _on_flee_pressed() -> void:
	# TODO: Add check to see if Flee is successful
	leave_battle()


func leave_battle() -> void:
	queue_free()


func _on_attack_pressed() -> void:
	player_roll_to_hit()
