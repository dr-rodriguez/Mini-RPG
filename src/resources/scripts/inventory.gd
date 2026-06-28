class_name Inventory
extends Node

var items: Array[Item]

## Add an item
func add(item: Item) -> void:
	items.append(item)

## Remove an item
func remove(item: Item) -> void:
	items.erase(item)

## Count the number of the specified item
func count(item: Item) -> int:
	var total := 0
	for i in items:
		if i == item:
			total += 1
	return total

## Add items to fill up to target amount
func fill_to(item: Item, target: int) -> int:
	var to_add := maxi(0, target - count(item))
	for n in to_add:
		add(item)
	return to_add
