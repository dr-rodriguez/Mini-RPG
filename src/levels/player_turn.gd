extends Node

var log_text: String = ""

func enter() -> void:
	owner.label_log.text = "Your turn."


func do_attack() -> void:
	if owner.on_cooldown:
		return
	await player_roll_to_hit()
	owner.on_cooldown = true
	owner.timer.start()
	await owner.timer.timeout
	# Change to ENEMY_TURN state
	owner.battle_state.change_state(owner.battle_state.State.ENEMY_TURN)


func use_item(_item_name: String) -> void:
	# TODO: Implement item use logic
	pass


func player_roll_to_hit() -> void:
	var roll = PlayerData.roll_attack()
	log_text = "Your Roll: " + str(roll)
	
	# Run the attack animation
	owner.player_anim.animation = "attack_side"
	owner.player_anim.play()
	await owner.player_anim.animation_finished
	
	if roll >= owner.enemy.data.stats.armor_class:
		var damage = PlayerData.roll_damage()
		damage_enemy(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"
		
	# Revert back to idle
	owner.player_anim.animation = "idle_side"
	owner.player_anim.play()
	
	# Set the battle log label
	owner.label_log.text = log_text


func damage_enemy(damage) -> void:
	owner.enemy.take_damage(damage)
	if owner.enemy.health <= 0:
		owner.label_log.text = "Enemy defeated!"
		owner.enemy.queue_free()
		# TODO: Change to CHECK_END state
		owner.leave_battle()
