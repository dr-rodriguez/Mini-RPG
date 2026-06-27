class_name Item
extends Resource

@export var name: String
@export var texture: Texture2D
@export var help_text: String
@export var target: TargetType
enum TargetType {PLAYER, ENEMY}

# To be set per-resource (what happens when you use the item)
var use: Callable = func(): 
	pass
