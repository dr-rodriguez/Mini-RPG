extends Node

var battle: Battle  # injected via setup()
var manager: TurnManager  # injected via setup()

var log_text: String = ""


func setup(b: Battle, m: TurnManager) -> void:
	battle = b
	manager = m


func enter() -> void:
	battle.set_log("Enemy turn.")
	await do_attack()


func exit() -> void:
	pass


func do_attack() -> void:
	await enemy_roll_to_hit()
	await battle.run_timer()
	# Check for end of battle
	manager.change_state(TurnManager.State.CHECK_END)


func enemy_roll_to_hit() -> void:
	var roll = battle.enemy.roll_attack()
	log_text = "Enemy Roll: " + str(roll)
	
	# Play sound effect (skeleton attack takes longer)
	battle.play_sword_sfx("enemy")
	
	# Run the attack animation
	await battle.await_enemy_anim("attack_side")
	
	if roll >= PlayerData.stats.armor_class:
		var damage = battle.enemy.roll_damage()
		PlayerData.take_damage(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"
	
	# Revert back to idle
	battle.play_enemy_anim("idle_side")
	
	# Set the battle log label
	battle.set_log(log_text)
