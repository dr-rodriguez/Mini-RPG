extends Node

var battle: Battle  # injected via setup()


func setup(b: Battle) -> void:
	battle = b


func enter() -> void:
	# Check enemy/player health
	if not is_instance_valid(battle.enemy) or battle.enemy.health <= 0:
		battle.handle_enemy_defeated()
		return
	if PlayerData.health <= 0:
		# Logic for death handled in PlayerData
		pass
	
	# Hand off to the *other* side
	var tm := battle.turn_manager
	if tm.previous_state == TurnManager.State.PLAYER_TURN:
		tm.change_state(TurnManager.State.ENEMY_TURN)
	else:
		tm.change_state(TurnManager.State.PLAYER_TURN)
