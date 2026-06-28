extends Node

# Global signals
signal quest_active_changed(active: bool)
signal help_text_changed(help_text: String)
@warning_ignore("unused_signal")
signal level_change_requested(scene_path: String)
@warning_ignore("unused_signal")
signal battle_requested(enemy: Node)

# Global variables
var debug_mode: bool = false
var met_slimey: bool = false
var quest_complete: bool = false
var transition_scene: bool = false
var _help_source: Object = null  # for help_text handling
var active_enemy: Node = null  # to track which is the active enemy

## Set of enemy IDs the player has defeated. 
# Persists across level swaps so a beaten enemy stays gone.
var defeated_enemies: Dictionary = {}

# variables with setter/getter
var quest_active: bool = false:
	set(value):
		if quest_active == value:
			# Same value, no action
			return
		# Set value, emit signal
		quest_active = value
		quest_active_changed.emit(value)
	get:
		return quest_active

#region Help Text logic
# Functions to emit help_text_changed signals, used by UI elements
func set_help_text(text: String, source: Object) -> void:
	_help_source = source
	help_text_changed.emit(text)

func clear_help_text(source: Object) -> void:
	if source == _help_source:
		_help_source = null
		help_text_changed.emit("")
#endregion

#region Defeated enemy tracking
func mark_enemy_defeated(enemy_id: String) -> void:
	defeated_enemies[enemy_id] = true


func is_enemy_defeated(enemy_id: String) -> bool:
	return defeated_enemies.has(enemy_id)
#endregion
