extends Node2D

# Passed by the main_game script
@export var enemy: Node

@onready var player_anim := %PlayerSprite
@onready var enemy_anim := %EnemySprite
@onready var timer := %Timer
@onready var on_cooldown: bool = false
@onready var label_log := %LogLabel
@onready var log_text: String = ""

func _ready() -> void:
	player_anim.play()
	enemy_anim.play()


func damage_enemy(damage) -> void:
	enemy.take_damage(damage)
	if enemy.health <= 0:
		label_log.text = "Enemy defeated!"
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
	label_log.text = "Flee successful!"
	leave_battle()


func leave_battle() -> void:
	# Wait for timer
	on_cooldown = true
	timer.start()
	await timer.timeout
	queue_free()


func _on_attack_pressed() -> void:
	if not on_cooldown:
		player_roll_to_hit()
	else:
		return
	on_cooldown = true
	timer.start()


func _on_timer_timeout() -> void:
	on_cooldown = false
