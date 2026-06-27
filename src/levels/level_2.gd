extends Node2D


func _on_level_1_transition_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
		if body.has_method("player"):
			GameState.level_change_requested.emit("res://src/levels/Level1.tscn")


## Returns true when no enemies remain in the level.
func check_enemies() -> bool:
	GameState.quest_complete = true
	return get_tree().get_node_count_in_group("Enemies") == 0
