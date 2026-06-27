extends Node

@onready var battle: Battle = owner

var log_text: String = ""


func enter() -> void:
	battle.set_log("Your turn.")


func do_attack() -> void:
	if battle.on_cooldown:
		return
	await player_roll_to_hit()
	if not is_instance_valid(battle.enemy) or battle.enemy.health <= 0:
		return
	await battle.run_timer()
	# Change to ENEMY_TURN state
	battle.battle_state.change_state(battle.battle_state.State.ENEMY_TURN)


func player_roll_to_hit() -> void:
	var roll = PlayerData.roll_attack()
	log_text = "Your Roll: " + str(roll)

	# Run the attack animation
	battle.player_anim.animation = "attack_side"
	battle.player_anim.play()
	await battle.player_anim.animation_finished

	if roll >= battle.enemy.data.stats.armor_class:
		var damage = PlayerData.roll_damage()
		await battle.damage_enemy(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"

	# Revert back to idle
	battle.player_anim.animation = "idle_side"
	battle.player_anim.play()

	# Set the battle log label
	battle.set_log(log_text)
