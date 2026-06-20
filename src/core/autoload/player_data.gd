extends Node

var health: int = 10
var max_health: int = 10
var strength: int = 2
var dexterity: int = 1
var gold: int = 10

# Using Inventory class
var inventory: Inventory

# Player Data functions
func armor_class() -> int:
	return 10 + dexterity
