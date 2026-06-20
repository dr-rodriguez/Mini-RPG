class_name Inventory
extends Node

var items: Array[Item]

func add(item: Item) -> void:
	items.append(item)

func remove(item: Item) -> void:
	items.erase(item)
