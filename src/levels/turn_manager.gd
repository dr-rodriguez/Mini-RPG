extends Node
class_name TurnManager

enum State {PLAYER_TURN, ENEMY_TURN, CHECK_END}
@onready var states_map = {
	State.PLAYER_TURN: $PlayerTurn,
	State.ENEMY_TURN: $EnemyTurn,
	State.CHECK_END: $CheckEnd,
}
var previous_state: State = State.PLAYER_TURN
var current_state: State = State.PLAYER_TURN
var state_node: Node

## Inject the owning Battle and this manager into every turn state.
func setup(battle: Battle) -> void:
	for node in states_map.values():
		node.setup(battle, self)


## The single entry point for every transition. States request a transition by
## calling this; the manager owns the exit -> bookkeeping -> enter sequence.
func change_state(new_state: State) -> void:
	# Let the outgoing state tear down (guard: the first transition has none)
	if state_node:
		state_node.exit()
	
	# Bookkeeping
	previous_state = current_state
	current_state = new_state
	state_node = states_map[new_state]
	
	# Let the incoming state run
	state_node.enter()
