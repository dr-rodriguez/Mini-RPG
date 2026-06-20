extends Node

@onready var player_menu = %PlayerMenu
var player_menu_visible: bool = false

func _ready() -> void:
	player_menu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if player_menu_visible:
			player_menu.hide()
			player_menu_visible = false
		else:
			player_menu.show()
			player_menu_visible = true
