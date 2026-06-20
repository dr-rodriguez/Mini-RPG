class_name Items
extends Node

var EMPTY : Item = Item.new()
var HEALTH_POTION : Item = preload("res://src/resources/items/health_potion.tres")
var RED_GEM : Item = preload("res://src/resources/items/red_gem.tres")

var all_items = [
	EMPTY,
	HEALTH_POTION,
	RED_GEM
]

var item_registry := {}


func _ready() -> void:
	_register_items()
	EMPTY.name = "EMPTY"
	HEALTH_POTION.use = _health_potion
	RED_GEM.use = _red_gem


func _register_items() -> void:
	for item in all_items:
		item_registry[item.item_name] = item


func get_item(item_name: String) -> Item:
	return item_registry.get(item_name)


func _health_potion() -> int:
	return randi_range(1,4) + randi_range(1,4) + 2

func _red_gem() -> int:
	return randi_range(1,6) + randi_range(1,6)
