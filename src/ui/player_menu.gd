extends Control

@onready var stats_view = %PlayerStats
@onready var inventory_view = %PlayerInventory
@onready var options_view = %Options

func _on_stats_button_pressed() -> void:
	stats_view.show()
	inventory_view.hide()
	options_view.hide()

func _on_invetory_button_pressed() -> void:
	stats_view.hide()
	inventory_view.show()
	options_view.hide()


func _on_options_button_pressed() -> void:
	stats_view.hide()
	inventory_view.hide()
	options_view.show()
