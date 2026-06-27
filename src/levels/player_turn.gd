extends Node

var battle: Battle  # injected via setup()

var log_text: String = ""


func setup(b: Battle) -> void:
	battle = b


func enter() -> void:
	battle.set_log("Your turn.")


func do_attack() -> void:
	if battle.on_cooldown:
		return
	await player_roll_to_hit()
	await battle.run_timer()
	# Check for end of battle
	battle.turn_manager.change_state(battle.turn_manager.State.CHECK_END)


func player_roll_to_hit() -> void:
	var roll = PlayerData.roll_attack()
	log_text = "Your Roll: " + str(roll)

	# Run the attack animation
	await battle.await_player_anim("attack_side")

	if roll >= battle.enemy.data.stats.armor_class:
		var damage = PlayerData.roll_damage()
		await battle.damage_enemy(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"

	# Revert back to idle
	battle.play_player_anim("idle_side")

	# Set the battle log label
	battle.set_log(log_text)
