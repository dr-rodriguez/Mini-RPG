extends CharacterBody2D

@onready var interactable_component: Interactable = $InteractableComponent

func _ready():
	interactable_component.interact = Callable(self, "_on_interact")
	
func _on_interact():
	print("hi")
	# Add dialogue logic
