extends Control

@onready var check_button := %CheckButton

func _ready() -> void:
	check_button.button_pressed = GameState.quest_active


func _on_check_button_pressed() -> void:
	GameState.quest_active = check_button.button_pressed
