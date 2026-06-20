extends Node

var health: int = 10
var max_health: int = 10
var strength: int = 2
var dexterity: int = 1
var gold: int = 10
var inventory := Inventory.new()

# Set up initial inventory
func _ready() -> void:
	inventory.add(Items.HEALTH_POTION)
	inventory.add(Items.HEALTH_POTION)
	inventory.add(Items.RED_GEM)

# Player Data functions
func armor_class() -> int:
	return 10 + dexterity
