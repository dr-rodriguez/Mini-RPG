extends Node

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

# global signals
signal quest_active_changed(active: bool)
