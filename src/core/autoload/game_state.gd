extends Node

# global signals
signal quest_active_changed(active: bool)
signal help_text_changed(help_text: String)

# global variables
var met_slimey: bool = false
var quest_complete: bool = false

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

# help text routing with owner guard (prevents exit/enter ordering clobber)
var _help_source: Object = null

# Functions to emit help_text_changed signals, used by UI elements
func set_help_text(text: String, source: Object) -> void:
	_help_source = source
	help_text_changed.emit(text)

func clear_help_text(source: Object) -> void:
	if source == _help_source:
		_help_source = null
		help_text_changed.emit("")
