extends Control

# Dictionary of available panel views in UI
@onready var views := {
	"stats": %PlayerStats,
	"inventory": %PlayerInventory,
	"options": %Options,
}

func _ready() -> void:
	# Establish signal connections, set default view
	%StatsButton.pressed.connect(_show_view.bind("stats"))
	%InventoryButton.pressed.connect(_show_view.bind("inventory"))
	%OptionsButton.pressed.connect(_show_view.bind("options"))
	_show_view("stats")

# Helper function to activate the specified view
func _show_view(view_name: String) -> void:
	for key in views:
		views[key].visible = (key == view_name)
