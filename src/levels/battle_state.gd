extends Node
class_name BattleState

enum State {PLAYER_TURN, ENEMY_TURN, CHECK_END}
@onready var states_map = {
	State.PLAYER_TURN: $PlayerTurn,
	State.ENEMY_TURN: $EnemyTurn,
	State.CHECK_END: $CheckEnd,
}
var current_state: State = State.PLAYER_TURN
var state_node: Node

func change_state(new_state: State) -> void:
	# Manage the various states
	current_state = new_state
	match new_state:
		State.PLAYER_TURN:
			# Select appropriate node and call it's enter function
			state_node = states_map[State.PLAYER_TURN]
			state_node.enter()
		State.ENEMY_TURN:
			state_node = states_map[State.ENEMY_TURN]
			state_node.enter()
		State.CHECK_END:
			state_node = states_map[State.CHECK_END]
			state_node.enter()
