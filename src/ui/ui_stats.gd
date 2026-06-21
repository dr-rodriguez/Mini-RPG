extends MarginContainer

# Label values for player stats
@onready var health_value := %HealthValue
@onready var ac_value := %ACValue
@onready var strength_value := %StrengthValue
@onready var dexterity_value := %DexterityValue
@onready var cnt_health := %HealthContainer
@onready var cnt_ac := %ACContainer
@onready var cnt_str := %StrengthContainer
@onready var cnt_dex := %DexterityContainer

func _ready() -> void:
	# Prepare help text
	var help_texts := {
		%HealthContainer: "Health is how much damage you can take.",
		%ACContainer: "Armor class is how well you dodge.",
		%StrengthContainer: "Strength improves chance to hit and damage.",
		%DexterityContainer: "Dexterity improves your armor class."
	}
	for cnt in help_texts:
		cnt.mouse_entered.connect(GameState.set_help_text.bind(help_texts[cnt], cnt))
		cnt.mouse_exited.connect(GameState.clear_help_text.bind(cnt))


# Helper function to set player data labels
func set_stats() -> void:
	health_value.text = str(PlayerData.stats.health) + "/" + str(PlayerData.stats.max_health)
	ac_value.text = str(PlayerData.stats.armor_class)
	strength_value.text = str(PlayerData.stats.strength)
	dexterity_value.text = str(PlayerData.stats.dexterity)
