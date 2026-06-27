extends Node

# Player related signals
signal player_took_damage
signal player_died

var stats := Attributes.new()
var gold: int = 10
var inventory := Inventory.new()

var health: int:
	set(value):
		health = min(value, stats.max_health)
	get:
		return health


func _ready() -> void:
	# Set normal stats
	set_normal()
	# Set initial inventory
	inventory.add(Items.HEALTH_POTION)
	inventory.add(Items.HEALTH_POTION)
	inventory.add(Items.RED_GEM)


#region  Player stat functions
func set_easy() -> void:
	stats.strength = 4
	stats.dexterity = 2
	stats.max_health = 40
	health = stats.max_health


func set_normal() -> void:
	stats.strength = 2
	stats.dexterity = 1
	stats.max_health = 20
	health = stats.max_health


func set_hard() -> void:
	stats.strength = 1
	stats.dexterity = 0
	stats.max_health = 10
	health = stats.max_health

#endregion

#region Damage functions
func take_damage(damage) -> void:
	health -= damage
	player_took_damage.emit()
	if PlayerData.health <= 0:
		# TODO: Go to game over screen
		print_debug("player dead")
		player_died.emit()
		pass


func roll_attack() -> int:
	return randi_range(1, 20) + stats.strength


func roll_damage() -> int:
	return randi_range(1, 6) + stats.strength

#endregion
