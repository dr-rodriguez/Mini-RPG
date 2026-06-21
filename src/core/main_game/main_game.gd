extends Node

@onready var player_menu = %PlayerMenu
@onready var level_root: Node2D = $World/LevelRoot
@onready var player: Node2D = $World/EntityRoot/Player
@onready var fade_screen = %FadeScreen
var player_menu_visible: bool = false


func _ready() -> void:
	player_menu.hide()
	# Connect to level-change signal
	GameState.level_change_requested.connect(_on_level_change_requested)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if player_menu_visible:
			player_menu.hide()
			player_menu_visible = false
		else:
			player_menu.show()
			player_menu_visible = true


#region Scene Handling

func _on_level_change_requested(scene_path: String) -> void:
	# Defer so we don't free a level from inside its own physics callback.
	_swap_level.call_deferred(scene_path)


func _swap_level(scene_path: String) -> void:
	# Run fade_tween to go to black
	await fade_tween(Color(0, 0, 0, 1))
	
	# Remove all scene levels
	for level in get_tree().get_nodes_in_group("Levels"):
		level.queue_free()
	
	# Create the new scene
	var new_level: Node2D = load(scene_path).instantiate()
	new_level.add_to_group("Levels")
	level_root.add_child(new_level)
	
	# Move the player to the new level's spawn marker if it has one.
	var spawn: Node2D = new_level.get_node_or_null("StartPosition")
	if spawn:
		player.global_position = spawn.global_position
		
	# Run fade_tween to go to transparent
	await fade_tween(Color(0, 0, 0, 0))


func fade_tween(color: Color = Color(0, 0, 0, 0), duration: float = 0.6) -> void:
	var tween = fade_screen.create_tween()
	
	# Set the tween properites
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(fade_screen, "color", color, duration/2.0)
	
	await tween.finished

#endregion
