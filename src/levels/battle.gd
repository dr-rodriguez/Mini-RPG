extends Node2D
class_name Battle

# Battle signals
signal change_label_text(log_text: String)

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
@onready var health_panel: VBoxContainer = %HealthVBox
@onready var items_panel: MarginContainer = %ItemsMargin
@onready var cnt_items: VBoxContainer = %ItemsContainer


func _ready() -> void:
	# Start everyone on their idle animations
	player_anim.animation = "idle_side"
	player_anim.play()
	enemy_anim.animation = "idle_side"
	enemy_anim.play()
	
	roll_initiative()
	
	# Set initial health label
	_on_player_took_damage()
	
	# Items panel starts invisible
	items_panel.visible = false
	
	# Signal connections
	change_label_text.connect(_on_change_label_text)
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


## Helper function to wait for the timer
func run_and_await_timer() -> void:
	on_cooldown = true
	timer.start()
	await timer.timeout


func _update_items():
	# Clear all child items first
	for child in cnt_items.get_children():
		child.queue_free()
	
	# Add items specifically from the players' inventory
	for i in PlayerData.inventory.items:
		var new_item = Button.new()
		var icon = TextureRect.new()
		
		# Add the icon
		icon.texture = i.texture
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# The Hbox is buttons with icon and labels
		new_item.icon = icon
		new_item.text = i.name
		new_item.alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# Set up mouse actions and finalize the Hbox
		new_item.pressed.connect(i.use)
		cnt_items.add_child(new_item)


#region Signal functions
func _on_flee_pressed() -> void:
	var player_roll: int = randi_range(1, 20) + PlayerData.stats.dexterity
	var enemy_roll: int = randi_range(1, 20) + enemy.data.stats.dexterity
	if player_roll >= enemy_roll:
		log_text = "Flee successful!"
		change_label_text.emit(log_text)
		run_and_await_timer()
		leave_battle()
	else:
		log_text = "Failed to flee."
		change_label_text.emit(log_text)
		run_and_await_timer()
		battle_state.change_state(battle_state.State.ENEMY_TURN)


func _on_attack_pressed() -> void:
	if battle_state.current_state == battle_state.State.PLAYER_TURN:
		# Logic for attack in PlayerTurn State
		battle_state.state_node.do_attack()


func _on_timer_timeout() -> void:
	on_cooldown = false


func _on_change_label_text(text: String) -> void:
	label_log.text = text


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


func _on_item_toggled(toggled_on: bool) -> void:
	_update_items()
	if toggled_on:
		items_panel.visible = true
		health_panel.visible = false
	else:
		items_panel.visible = false
		health_panel.visible = true


#endregion
