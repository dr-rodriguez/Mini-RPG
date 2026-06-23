class_name Attributes
extends Resource

@export var max_health: int  # health is different from max_health
@export var strength: int
@export var dexterity: int

var armor_class: int:
	set(value):
		# armor class cannot be manually set
		pass
	get:
		return 10 + dexterity
