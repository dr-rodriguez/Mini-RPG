extends Node2D

@onready var interact_label: Label = $InteractLabel

var current_interactions: Array[Interactable] = []
var current_nearest: Interactable = null

func _ready() -> void:
	# Connect signals
	$InteractingRange.area_entered.connect(_on_area_entered)
	$InteractingRange.area_exited.connect(_on_area_exited)
	# Decouple label from this node's (player's) transform so it sits at
	# the interactable's world position without fighting player movement.
	interact_label.top_level = true
	interact_label.hide()  # start hidden so it doesn't show sample text

# Register / deregister interactables in range
func _on_area_entered(area: Area2D) -> void:
	if area is Interactable and area.is_interactable:
		current_interactions.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area is Interactable:
		current_interactions.erase(area)


func _process(_delta: float) -> void:
	if current_interactions.is_empty():
		if current_nearest != null:
			current_nearest = null
			interact_label.hide()
		return

	# Sort so the nearest interactable is index 0
	current_interactions.sort_custom(sort_nearest)
	var nearest: Interactable = current_interactions[0]

	# Only reposition when the target changes. Interactables are static,
	# so re-pinning every frame just causes jitter against player movement.
	if nearest == current_nearest:
		return
	current_nearest = nearest

	# Activate the text for the interactible
	interact_label.text = nearest.interact_name

	# Move the label to be for the area, instead of the player
	interact_label.global_position = nearest.global_position
	interact_label.global_position.y -= 36
	interact_label.global_position.x -= interact_label.size.x / 2

	# Actually show the label
	interact_label.show()


func sort_nearest(a: Interactable, b: Interactable) -> bool:
	# Helper function to return closest of 2
	var da := global_position.distance_to(a.global_position)
	var db := global_position.distance_to(b.global_position)
	return da < db


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not current_interactions.is_empty():
		set_process_input(false)        # block input during interaction
		interact_label.hide()
		await current_interactions[0].interact.call()
		set_process_input(true)
		current_nearest = null          # force re-show/re-pin after interaction
