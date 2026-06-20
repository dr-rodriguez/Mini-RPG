class_name Inventory
extends Node

var items: Array[Item]

func _ready() -> void:
	items.append(Items.HEALTH_POTION)
	items.append(Items.HEALTH_POTION)
	items.append(Items.RED_GEM)
