extends Node

func enter() -> void:
	idle_animation()

func idle_animation() -> void:
	# Idle animations
	# owner is the root (eg, Player)
	var last_direction = owner.last_direction
	var anim = owner.anim
	
	if last_direction.x < 0:
		anim.animation = "idle_side"
		anim.flip_h = true
	elif last_direction.x > 0:
		anim.animation = "idle_side"
		anim.flip_h = false
	elif last_direction.y < 0:
		anim.animation = "idle_back"
	elif last_direction.y > 0:
		anim.animation = "idle_front"
	
	anim.play()
