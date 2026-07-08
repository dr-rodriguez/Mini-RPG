extends Node

@onready var player_menu = %PlayerMenu
@onready var help_menu = %UiHelp
@onready var menu_button: TextureButton = %MenuButton
@onready var help_button: TextureButton = %HelpButton
@onready var level_root: Node2D = $World/LevelRoot
@onready var player: Node2D = $World/EntityRoot/Player
@onready var fade_screen = %FadeScreen
@onready var timer: Timer = %Timer
@onready var music: AudioStreamPlayer = %Music
var player_menu_visible: bool = false
var help_menu_visible: bool = true
var current_track: String = ""   # what's playing now
var level_track: String = ""     # the level song to resume after battle
var music_tween: Tween

const LEVEL_MUSIC := {
	"res://src/levels/Level1.tscn": "res://assets/audio/music/audio_hero_Just-Ducky_SIPML_K-04-57-01.mp3",
	"res://src/levels/Level2.tscn": "res://assets/audio/music/music_zapsplat_realization_111.mp3",
}
const BATTLE_MUSIC := "res://assets/audio/music/music_zapsplat_tuff_enough.mp3"
const MUSIC_FADE_TIME := 0.6
const MUSIC_SILENT_DB := -40.0


func _ready() -> void:
	player_menu.hide()
	
	# Debug mode button
	if GameState.debug_mode:
		%DebugButton.show()
		%DebugButton.connect("pressed", _on_debug_button_pressed)
	
	# Start the music for the level that's already in the scene tree
	level_track = LEVEL_MUSIC.get("res://src/levels/Level1.tscn", "")
	play_music(level_track)
	
	# Connect to level-change signal
	GameState.level_change_requested.connect(_on_level_change_requested)
	GameState.battle_requested.connect(_on_battle_requested)
	PlayerData.player_died.connect(_on_player_died)
	GameState.quest_completed.connect(_on_quest_completion)

	# Hide the help menu the first time the player moves.
	player.first_moved.connect(_on_player_first_moved)


func _input(event: InputEvent) -> void:
	# Don't get inputs if paused
	if get_tree().paused:
		return
	
	# Show the player menu
	if event.is_action_pressed("menu"):
		set_player_menu_visible(not player_menu_visible)
		set_help_menu_visible(false)


#region Scene Handling

## Set visibility of player menu
func set_player_menu_visible(should_show: bool) -> void:
	player_menu.visible = should_show
	player_menu_visible = should_show


## Toggle the menu/help button
func hide_menu_button(state: bool) -> void:
	menu_button.visible = not state
	help_button.visible = not state


## Hide the help menu when the player starts moving
func _on_player_first_moved() -> void:
	set_help_menu_visible(false)


## Set visibility of help menu
func set_help_menu_visible(should_show: bool) -> void:
	help_menu.visible = should_show
	help_menu_visible = should_show


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

	# Switch to the new level's music
	level_track = LEVEL_MUSIC.get(scene_path, "")
	play_music(level_track)

	# Run fade_tween to go to transparent
	await fade_tween(Color(0, 0, 0, 0))


func fade_tween(color: Color = Color(0, 0, 0, 0), duration: float = 0.6) -> void:
	var tween = fade_screen.create_tween()
	
	# Set the tween properites
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(fade_screen, "color", color, duration/2.0)
	
	await tween.finished


func _on_battle_requested(enemy: Node):
	# Hide the player menu in case it's visible
	set_player_menu_visible(false)
	hide_menu_button(true)
	set_help_menu_visible(false)
	
	# Swap to battle screen and pause the main world
	get_tree().paused = true
	await fade_tween(Color(0, 0, 0, 1))

	# Hide the active level + its LevelFX node (fog)
	var level = get_tree().get_first_node_in_group("Levels")
	level.hide()
	var fx := level.get_node_or_null("LevelFX")
	if fx:
		fx.hide()
	
	GameState.active_enemy = enemy

	# Switch to battle music (keeps level_track so we can resume it after)
	play_music(BATTLE_MUSIC)

	# Load the battle screen
	var battle = load("res://src/levels/Battle.tscn").instantiate()
	battle.process_mode = Node.PROCESS_MODE_ALWAYS
	battle.enemy = enemy  # passing the node to the battle scene
	# tree_exited signal hooked up to _restore_level()
	battle.tree_exited.connect(_restore_level.bind(level))
	$BattleLayer.add_child(battle)
	await fade_tween(Color(0, 0, 0, 0))


func _restore_level(level: Node) -> void:
	# Battle node freed (Flee/Won) — re-show the level and unpause.
	# tree_exited also fires while the whole tree tears down (e.g. quitting
	# from the battle screen). In that case the level is still a valid object
	# but already detached, so get_tree() on it is null — skip the restore.
	if is_instance_valid(level) and level.is_inside_tree():
		level.show()
		hide_menu_button(false)
		var fx := level.get_node_or_null("LevelFX")
		if fx:
			# Once every enemy in the level is defeated, kill the fog for good.
			var cleared: bool = level.has_method("check_enemies") and level.check_enemies()
			fx.visible = not cleared
		# Resume the level music we paused for the battle
		play_music(level_track)
	# Just a safety check in case closing game from battle screen
	if get_tree():
		get_tree().paused = false


func _on_player_died() -> void:
	get_tree().paused = false
	# Run fade_tween to go to black
	await fade_tween(Color(0, 0, 0, 1))
	%GameOver.visible = true
	timer.start()
	await timer.timeout
	get_tree().quit()


## Show splash text for quest completion
func _on_quest_completion() -> void:
	var quest_scene: Control = %QuestComplete
	var tween = quest_scene.create_tween()
	var duration: float = 0.8
	
	# Set the tween properites
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	quest_scene.visible = true
	
	tween.tween_property(quest_scene, "visible", true, duration/2.0)
	
	await tween.finished
	tween.stop()
	
	# Timer between fading
	timer.wait_time = 1.0
	timer.start()
	await timer.timeout
	
	# New tween for the fade-out effect
	var tween2 = quest_scene.create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_LINEAR)
	
	tween2.tween_property(quest_scene, "visible", false, duration/2.0)
	
	await tween2.finished

#endregion

#region Music

func play_music(path: String) -> void:
	
	# Exit if already playing
	if path.is_empty() or (path == current_track and music.playing):
		return
	current_track = path

	# Kill any in-progress fade so overlapping transitions don't fight.
	if music_tween and music_tween.is_valid():
		music_tween.kill()

	# Nothing playing yet (game start): just fade in from silence.
	if not music.playing:
		music.stream = load(path)
		music.volume_db = MUSIC_SILENT_DB
		music.play()
		music_tween = create_tween()
		music_tween.tween_property(music, "volume_db", 0.0, MUSIC_FADE_TIME)
		return

	# Cross-fade: dip current track to silence, swap stream, bring it back up.
	music_tween = create_tween()
	music_tween.tween_property(music, "volume_db", MUSIC_SILENT_DB, MUSIC_FADE_TIME / 2.0)
	music_tween.tween_callback(func() -> void:
		music.stream = load(path)
		music.play())
	music_tween.tween_property(music, "volume_db", 0.0, MUSIC_FADE_TIME / 2.0)

#endregion


func _on_debug_button_pressed() -> void:
	var debug_root = $DebugLayer/DebugRoot
	# Toggle visiblity of debug ui
	debug_root.visible = not debug_root.visible


func _on_menu_button_pressed() -> void:
	set_player_menu_visible(not player_menu_visible)
	set_help_menu_visible(false)


func _on_help_button_pressed() -> void:
	set_help_menu_visible(not help_menu_visible)
	set_player_menu_visible(false)
