extends Node2D
class_name Battle

# Passed by the main_game script
@export var enemy: Node

@onready var turn_manager: TurnManager = $TurnManager
@onready var player_anim := %PlayerSprite
@onready var enemy_anim := %EnemySprite
@onready var timer := %Timer
@onready var label_log: Label = %LogLabel
@onready var health_label: Label = %HealthLabel
@onready var btn_attack: Button = %Attack
@onready var btn_item: Button = %Item
@onready var btn_flee: Button = %Flee
@onready var health_panel: VBoxContainer = %HealthVBox
@onready var items_panel: MarginContainer = %ItemsMargin
@onready var cnt_items: VBoxContainer = %ItemsContainer
var on_cooldown: bool = false

const SWORD_SFX = [
	"res://assets/audio/sfx/zapsplat_warfare_sword_swing_fast_whoosh_metal_001.mp3",
	"res://assets/audio/sfx/zapsplat_warfare_sword_swing_fast_whoosh_metal_002.mp3",
	"res://assets/audio/sfx/zapsplat_warfare_sword_swing_fast_whoosh_metal_003.mp3",
	"res://assets/audio/sfx/zapsplat_warfare_sword_swing_fast_whoosh_metal_004.mp3",
]

func _ready() -> void:
	# Start everyone on their idle animations
	play_player_anim("idle_side")
	play_enemy_anim("idle_side")
	
	# Inputs stay locked until the PlayerTurn state enables them on enter()
	set_inputs_enabled(false)
	
	# Inject this Battle into the turn states before any turn starts
	turn_manager.setup(self)
	roll_initiative()
	
	# Set initial health label
	_on_player_took_damage()
	
	# Items panel starts invisible
	items_panel.visible = false
	
	# Signal connections
	PlayerData.player_took_damage.connect(_on_player_took_damage)


## Helper method to do an opposed check
func opposed_check(player_mod: int, enemy_mod: int) -> bool:
	var player_roll: int = randi_range(1, 20) + player_mod
	var enemy_roll: int = randi_range(1, 20) + enemy_mod
	if player_roll >= enemy_roll:
		return true
	else:
		return false


## Roll initiave in the battle scene
func roll_initiative() -> void:
	if opposed_check(PlayerData.stats.dexterity, enemy.data.stats.dexterity):
		turn_manager.change_state(turn_manager.State.PLAYER_TURN)
	else:
		turn_manager.change_state(turn_manager.State.ENEMY_TURN)


## Leave the battle scene
func leave_battle() -> void:
	queue_free()


## Helper function to wait for the timer
func run_timer() -> void:
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

		# Button.icon takes a Texture2D directly, not a TextureRect node
		new_item.icon = i.texture
		new_item.expand_icon = true
		new_item.text = i.name
		new_item.alignment = HORIZONTAL_ALIGNMENT_CENTER

		# Set up mouse actions and finalize the Hbox
		new_item.pressed.connect(_use_item.bind(i))
		cnt_items.add_child(new_item)


## Helper function to use the item
func _use_item(item: Item) -> void:
	if on_cooldown:
		return
	
	# Compute the value from the item then determine if we apply it to player or enemy
	var value: int = item.use.call()
	match item.target:
		item.TargetType.PLAYER:
			PlayerData.take_damage(-1*value)
			set_log("Healed " + str(value))
		item.TargetType.ENEMY:
			await damage_enemy(value)
			set_log("Dealt " + str(value) + " damage")
	
	# Remove the item used
	PlayerData.inventory.remove(item)
	
	# End turn
	_on_item_toggled(false)
	await run_timer()
	turn_manager.change_state(turn_manager.State.CHECK_END)


## Helper function to play a sound effect
func play_sword_sfx(target: String) -> void:
	var index: int = randi_range(0, 3)
	var sfx: String = SWORD_SFX[index]
	var sfx_player: AudioStreamPlayer
	if target == "enemy":
		sfx_player = %EnemyFX
	else:
		sfx_player = %PlayerFX
	sfx_player.stream = load(sfx)


#region Animation logic
func play_player_anim(anim_name: String) -> void:
	player_anim.play(anim_name)


func play_enemy_anim(anim_name: String) -> void:
	enemy_anim.play(anim_name)


## Same as above, but waits for a one-shot animation to finish.
func await_player_anim(anim_name: String) -> void:
	player_anim.play(anim_name)
	await player_anim.animation_finished


func await_enemy_anim(anim_name: String) -> void:
	enemy_anim.play(anim_name)
	await enemy_anim.animation_finished
#endregion

#region Enemy state logic
func damage_enemy(damage) -> void:
	enemy.take_damage(damage)
	enemy_anim.animation = "hit_side"
	enemy_anim.play()
	await enemy_anim.animation_finished


func handle_enemy_defeated() -> void:
	set_log("Enemy defeated!")
	enemy_anim.animation = "death"
	enemy_anim.play()
	await enemy_anim.animation_finished
	enemy.queue_free()
	leave_battle()
#endregion

#region Signal functions
func _on_flee_pressed() -> void:
	if on_cooldown:
		return

	if opposed_check(PlayerData.stats.dexterity, enemy.data.stats.dexterity):
		set_log("Flee successful!")
		await run_timer()
		leave_battle()
	else:
		set_log("Failed to flee.")
		await run_timer()
		turn_manager.change_state(turn_manager.State.CHECK_END)


func _on_attack_pressed() -> void:
	if turn_manager.current_state == turn_manager.State.PLAYER_TURN:
		# Logic for attack in PlayerTurn State
		turn_manager.state_node.do_attack()


func _on_timer_timeout() -> void:
	on_cooldown = false


func set_log(text: String) -> void:
	label_log.text = text


func _on_player_took_damage() -> void:
	health_label.text = "Health: " + str(PlayerData.health) + "/" + str(PlayerData.stats.max_health)


## Enable/disable the player's action buttons. Owned by the PlayerTurn state,
## which calls this on enter() (true) and exit() (false).
func set_inputs_enabled(enabled: bool) -> void:
	btn_attack.disabled = not enabled
	btn_item.disabled = not enabled
	btn_flee.disabled = not enabled


## Handle visibility of the item panel
func _on_item_toggled(toggled_on: bool) -> void:
	_update_items()
	btn_item.button_pressed = toggled_on
	items_panel.visible = toggled_on
	health_panel.visible = not toggled_on


#endregion
