extends CharacterBody2D

@onready var interactable_component: Interactable = $InteractableComponent
@onready var anim := $AnimatedSprite2D

func _ready():
	interactable_component.interact = Callable(self, "_on_interact")
	anim.play()
	
func _on_interact():
	# Dialogue logic
	var balloon_scene = load("res://src/ui/dialogue/balloon.tscn")
	var resource = load("res://src/resources/dialogue/quest.dialogue")
	DialogueManager.show_dialogue_balloon_scene(balloon_scene, resource, "start")
