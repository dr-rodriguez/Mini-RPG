extends Node2D

# Passed by the main_game script
@export var enemy: Node

@onready var battle_state: BattleState = $BattleState
@onready var player_anim := %PlayerSprite
@onready var enemy_anim := %EnemySprite
@onready var timer := %Timer
@onready var on_cooldown: bool = false
@onready var label_log: Label = %LogLabel
@onready var log_text: String = ""
@onready var health_label: Label = %HealthLabel

func _ready() -> void:
	# Start everyone on their idle animations
	player_anim.animation = "idle_side"
	player_anim.play()
	enemy_anim.animation = "idle_side"
	enemy_anim.play()
	
	roll_initiative()
	
	# Set initial health label
	_on_player_took_damage()
	
	# Global signal connections
	PlayerData.player_took_damage.connect(_on_player_took_damage)


func roll_initiative() -> void:
	var player_roll: int = randi_range(1, 20) + PlayerData.stats.dexterity
	var enemy_roll: int = randi_range(1, 20) + enemy.data.stats.dexterity
	print("Initiative: ", player_roll, " vs ", enemy_roll)
	if player_roll >= enemy_roll:
		battle_state.change_state(battle_state.State.PLAYER_TURN)
	else:
		battle_state.change_state(battle_state.State.ENEMY_TURN)


func damage_player(damage) -> void:
	PlayerData.take_damage(damage)


func leave_battle() -> void:
	# Wait for timer
	on_cooldown = true
	timer.start()
	await timer.timeout
	queue_free()


#region Signal functions
func _on_flee_pressed() -> void:
	# TODO: Add check to see if Flee is successful
	label_log.text = "Flee successful!"
	leave_battle()


func _on_attack_pressed() -> void:
	if battle_state.current_state == battle_state.State.PLAYER_TURN:
		# Logic for attack in PlayerTurn State
		battle_state.state_node.do_attack()


func _on_timer_timeout() -> void:
	on_cooldown = false


func _on_player_took_damage() -> void:
	health_label.text = "Health: " + str(PlayerData.health) + "/" + str(PlayerData.stats.max_health)

#endregion
