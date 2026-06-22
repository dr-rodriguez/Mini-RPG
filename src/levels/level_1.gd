extends Node2D

@onready var removable_fence := $EntityRoot/RemovableFence

func _ready() -> void:
	# Remove fence if quest is already active
	if GameState.quest_active:
		removable_fence.queue_free()


func _on_level_2_transition_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.has_method("player"):
		GameState.level_change_requested.emit("res://src/levels/Level2.tscn")
