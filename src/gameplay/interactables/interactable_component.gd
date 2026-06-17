class_name Interactable
extends Area2D

@export var interact_name: String
@export var is_interactable: bool = true
@export var interact_radius: float = 25

# Behavior is set per-object by assigning this from outside.
var interact: Callable = func(): pass

func _ready() -> void:
	var collision_shape: CollisionShape2D = $CollisionShape2D
	collision_shape.shape.radius = interact_radius
