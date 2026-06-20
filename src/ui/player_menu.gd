extends Control

# Dictionary of available panel views in UI
@onready var views := {
	"stats": %UIStats,
	"inventory": %UIInventory,
	"options": %UIOptions,
}
# Label for help text
@onready var help_label := %HelpLabel


func _ready() -> void:
	# Establish signal connections, set default view
	%StatsButton.pressed.connect(_show_view.bind("stats"))
	%InventoryButton.pressed.connect(_show_view.bind("inventory"))
	%OptionsButton.pressed.connect(_show_view.bind("options"))
	_show_view("stats")
	
	# Set player stats
	_set_stats_labels()
	
	# Connect and set help text label
	GameState.help_text_changed.connect(_on_options_help_text_changed.bind())


# Helper function to activate the specified view
func _show_view(view_name: String) -> void:
	for key in views:
		views[key].visible = (key == view_name)
	
	if view_name == "inventory":
		for x in PlayerData.inventory.items:
			print_debug(x)
	
	# Update the stats,just in case
	if view_name == "stats":
		_set_stats_labels()

# Helper function to call set_stats for the PlayerStats view
func _set_stats_labels() -> void:
	%UIStats.set_stats()

# Helper function to set the help text
func _on_options_help_text_changed(help_text: String) -> void:
	help_label.text = help_text
