class_name Interactable
extends Area2D

@export var interact_name: String
@export var is_interactable: bool = true

# Behavior is set per-object by assigning this from outside.
var interact: Callable = func(): 
	pass
