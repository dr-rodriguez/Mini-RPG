extends Node

@onready var battle: Battle = owner

var log_text: String = ""

func enter() -> void:
	if battle.enemy.health <= 0:
		battle.enemy_defeated.emit()
	else:
		battle.change_label_text.emit("Enemy turn.")
		await do_attack()


func do_attack() -> void:
	await enemy_roll_to_hit()
	battle.run_and_await_timer()
	# Change to PlayerTurn state
	battle.battle_state.change_state(battle.battle_state.State.PLAYER_TURN)


func enemy_roll_to_hit() -> void:
	var roll = battle.enemy.roll_attack()
	log_text = "Enemy Roll: " + str(roll)

	# Run the attack animation
	battle.enemy_anim.animation = "attack_side"
	battle.enemy_anim.play()
	await battle.enemy_anim.animation_finished

	if roll >= PlayerData.stats.armor_class:
		var damage = battle.enemy.roll_damage()
		PlayerData.take_damage(damage)
		log_text += " Hit! " + str(damage) + " damage!"
	else:
		log_text += " Miss!"

	# Revert back to idle
	battle.enemy_anim.animation = "idle_side"
	battle.enemy_anim.play()

	# Set the battle log label
	battle.change_label_text.emit(log_text)
