extends Node2D


func _on_level_2_transition_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("player"):
		GameState.transition_scene = true
		change_scene()

func change_scene():
	if GameState.transition_scene:
		if GameState.current_scene == "level1":
			get_tree().get_first_node_in_group("Levels").change_scene_to_file("res://src/levels/Level2.tscn")
			
