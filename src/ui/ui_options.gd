extends MarginContainer

# Difficulty buttons
@onready var easy := %Easy
@onready var normal := %Normal
@onready var hard := %Hard
@onready var btn_exit := %Exit


func _ready() -> void:
	var help_texts := {
		%Easy: "Change attributes to make it easier.",
		%Normal: "Change attributes to normal defaults.",
		%Hard: "Change attributes to make it harder.",
		%Exit: "Quit the game."
	}
	for btn in help_texts:
		btn.mouse_entered.connect(GameState.set_help_text.bind(help_texts[btn], btn))
		btn.mouse_exited.connect(GameState.clear_help_text.bind(btn))


func _on_easy_pressed() -> void:
	PlayerData.set_easy()


func _on_normal_pressed() -> void:
	PlayerData.set_normal()


func _on_hard_pressed() -> void:
	PlayerData.set_hard()


func _on_quit_pressed() -> void:
	get_tree().quit()
