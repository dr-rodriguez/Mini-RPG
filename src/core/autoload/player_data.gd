extends Node

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
	stats.max_health = 20
	# TODO: Figure out why this doesn't respect the health setter when going from hard to easy
	health = 20


func set_normal() -> void:
	stats.strength = 2
	stats.dexterity = 1
	stats.max_health = 10
	health = 10


func set_hard() -> void:
	stats.strength = 1
	stats.dexterity = 0
	stats.max_health = 8
	health = 8

#endregion

#region Damage functions
func take_damage(damage) -> void:
	health -= damage
	if PlayerData.health <= 0:
		# TODO: Go to game over screen
		print_debug("player dead")
		pass


func roll_attack() -> int:
	return randi_range(1, 20) + stats.strength


func roll_damage() -> int:
	return randi_range(1, 6) + stats.strength

#endregion
