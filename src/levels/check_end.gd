extends Node

var battle: Battle  # injected via setup()
var manager: TurnManager  # injected via setup()


func setup(b: Battle, m: TurnManager) -> void:
	battle = b
	manager = m


func enter() -> void:
	# Check enemy/player health
	if not is_instance_valid(battle.enemy) or battle.enemy.health <= 0:
		battle.handle_enemy_defeated()
		return
	if PlayerData.health <= 0:
		# Logic for death handled in PlayerData
		pass
	
	# Hand off to the *other* side
	if manager.previous_state == TurnManager.State.PLAYER_TURN:
		manager.change_state(TurnManager.State.ENEMY_TURN)
	else:
		manager.change_state(TurnManager.State.PLAYER_TURN)


func exit() -> void:
	pass
