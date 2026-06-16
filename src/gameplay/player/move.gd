extends Node

func enter() -> void:
	move_animation()

func move_animation() -> void:
	# Helper function to handle animation based on direction
	# owner is the root (eg, Player)
	var direction = owner.direction
	var anim = owner.anim

	# Regular movement
	if direction.x < 0:
		anim.animation = "walk_side"
		anim.flip_h = true
	elif direction.x > 0:
		anim.animation = "walk_side"
		anim.flip_h = false
	elif direction.y < 0:
		anim.animation = "walk_back"
	elif direction.y > 0:
		anim.animation = "walk_front"
	
	anim.play()
	
	# Direction for idle
	owner.last_direction = direction
