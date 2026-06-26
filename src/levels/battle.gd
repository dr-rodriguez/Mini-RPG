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
@onready var btn_attack: Button = %Attack
@onready var btn_item: Button = %Item
@onready var btn_flee: Button = %Flee

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
	battle_state.player_turn.connect(_on_player_turn)
	battle_state.enemy_turn.connect(_on_enemy_turn)
	PlayerData.player_took_damage.connect(_on_player_took_damage)


## Roll initiave in the battle scene
func roll_initiative() -> void:
	var player_roll: int = randi_range(1, 20) + PlayerData.stats.dexterity
	var enemy_roll: int = randi_range(1, 20) + enemy.data.stats.dexterity
	print("Initiative: ", player_roll, " vs ", enemy_roll)
	if player_roll >= enemy_roll:
		battle_state.change_state(battle_state.State.PLAYER_TURN)
	else:
		battle_state.change_state(battle_state.State.ENEMY_TURN)


## Leave the battle scene
func leave_battle() -> void:
	queue_free()


#region Signal functions
func _on_flee_pressed() -> void:
	# TODO: Add check to see if Flee is successful
	var player_roll: int = randi_range(1, 20) + PlayerData.stats.dexterity
	var enemy_roll: int = randi_range(1, 20) + enemy.data.stats.dexterity
	if player_roll >= enemy_roll:
		label_log.text = "Flee successful!"
		on_cooldown = true
		timer.start()
		await timer.timeout
		leave_battle()
	else:
		label_log.text = "Failed to flee."
		battle_state.change_state(battle_state.State.ENEMY_TURN)


func _on_attack_pressed() -> void:
	if battle_state.current_state == battle_state.State.PLAYER_TURN:
		# Logic for attack in PlayerTurn State
		battle_state.state_node.do_attack()


func _on_timer_timeout() -> void:
	on_cooldown = false


func _on_player_took_damage() -> void:
	health_label.text = "Health: " + str(PlayerData.health) + "/" + str(PlayerData.stats.max_health)


func _on_player_turn() -> void:
	btn_attack.disabled = false
	btn_item.disabled = false
	btn_flee.disabled = false


func _on_enemy_turn() -> void:
	btn_attack.disabled = true
	btn_item.disabled = true
	btn_flee.disabled = true

#endregion
