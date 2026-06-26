extends Node

var log_text: String = ""

func enter() -> void:
	owner.label_log.text = "Enemy turn."
	await do_attack()


func do_attack() -> void:
	await enemy_roll_to_hit()
	owner.on_cooldown = true
	owner.timer.start()
	await owner.timer.timeout
	# Change to PlayerTurn state
	owner.battle_state.change_state(owner.battle_state.State.PLAYER_TURN)


func enemy_roll_to_hit() -> void:
	var roll = owner.enemy.roll_attack()
	log_text = "Enemy Roll: " + str(roll)
	
	# Run the attack animation
	owner.enemy_anim.animation = "attack_side"
	owner.enemy_anim.play()
	await owner.enemy_anim.animation_finished
	
	if roll >= PlayerData.stats.armor_class:
		var damage = owner.enemy.roll_damage()
		PlayerData.take_damage(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"
		
	# Revert back to idle
	owner.enemy_anim.animation = "idle_side"
	owner.enemy_anim.play()
	
	# Set the battle log label
	owner.label_log.text = log_text
