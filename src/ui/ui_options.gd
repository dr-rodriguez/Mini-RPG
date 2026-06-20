extends MarginContainer

# Difficulty buttons
@onready var easy := %Easy
@onready var normal := %Normal
@onready var hard := %Hard
@onready var btn_exit := %Exit


func _ready() -> void:
	var help_texts := {
		%Easy: "Change to 20 health, 4 strength, 2 dexterity.",
		%Normal: "Change to 10 health, 2 strength, 1 dexterity.",
		%Hard: "Change to 8 health, 1 strength, 0 dexterity.",
		%Exit: "Quit the game."
	}
	for btn in help_texts:
		btn.mouse_entered.connect(GameState.set_help_text.bind(help_texts[btn], btn))
		btn.mouse_exited.connect(GameState.clear_help_text.bind(btn))


func _update_health():
	PlayerData.health = min(PlayerData.health, PlayerData.max_health)


func _on_easy_pressed() -> void:
	PlayerData.strength = 4
	PlayerData.dexterity = 2
	PlayerData.max_health = 20
	_update_health()


func _on_normal_pressed() -> void:
	PlayerData.strength = 2
	PlayerData.dexterity = 1
	PlayerData.max_health = 10
	_update_health()


func _on_hard_pressed() -> void:
	PlayerData.strength = 1
	PlayerData.dexterity = 0
	PlayerData.max_health = 8
	_update_health()


func _on_quit_pressed() -> void:
	get_tree().quit()
