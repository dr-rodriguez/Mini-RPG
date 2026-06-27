extends Node

var battle: Battle  # injected via setup()

var log_text: String = ""


func setup(b: Battle) -> void:
	battle = b


func enter() -> void:
	battle.set_log("Enemy turn.")
	await do_attack()


func do_attack() -> void:
	await enemy_roll_to_hit()
	await battle.run_timer()
	# Check for end of battle
	battle.turn_manager.change_state(battle.turn_manager.State.CHECK_END)


func enemy_roll_to_hit() -> void:
	var roll = battle.enemy.roll_attack()
	log_text = "Enemy Roll: " + str(roll)

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
