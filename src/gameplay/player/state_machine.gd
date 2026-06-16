class_name StateMachine
extends Node

enum State {MOVE, IDLE, DIE, ATTACK}
@onready var states_map = {
	State.IDLE: $Idle,
	State.MOVE: $Move,
	State.ATTACK: $Attack,
	State.DIE: $Die,
}
@onready var current_state: State = State.IDLE


func change_state(new_state: State) -> void:
	# Manage the various states
	var state_node
	
	current_state = new_state
	match new_state:
		State.MOVE:
			# Select appropriate node and call it's enter function
			state_node = states_map[State.MOVE]
			state_node.enter()
		State.IDLE:
			state_node = states_map[State.IDLE]
			state_node.enter()
		State.DIE:
			pass
		State.ATTACK:
			pass
