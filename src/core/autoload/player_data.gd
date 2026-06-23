extends Node

var stats := Attributes.new()
var gold: int = 10
var inventory := Inventory.new()


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
	stats.health = 20


func set_normal() -> void:
	stats.strength = 2
	stats.dexterity = 1
	stats.max_health = 10
	stats.health = 10


func set_hard() -> void:
	stats.strength = 1
	stats.dexterity = 0
	stats.max_health = 8
	stats.health = 8

#endregion

#region Damage functions
func take_damage(damage) -> void:
	stats.health -= damage
	if PlayerData.stats.health <= 0:
		# TODO: Go to game over screen
		pass


func roll_attack() -> int:
	return randi_range(1, 20) + stats.strength


func roll_damage() -> int:
	return randi_range(1, 6) + stats.strength

#endregion
