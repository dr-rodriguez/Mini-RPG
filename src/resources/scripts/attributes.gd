class_name Attributes
extends Resource

@export var max_health: int
@export var strength: int
@export var dexterity: int

var armor_class: int:
	set(value):
		# armor class cannot be manually set
		pass
	get:
		return 10 + dexterity

var health: int:
	set(value):
		health = min(value, max_health)
	get:
		return health
