extends MarginContainer

@onready var cnt_items = %ItemsContainer

func _ready() -> void:
	_update_items()

# Update the items in the UI
func _update_items():
	# Clear all child items first
	for child in cnt_items.get_children():
		child.queue_free()
	
	# Add items specifically from the players' inventory
	for i in PlayerData.inventory.items:
		var new_item = Button.new()

		# Button.icon takes a Texture2D directly, not a TextureRect node
		new_item.icon = i.texture
		new_item.expand_icon = true
		new_item.text = i.name
		new_item.alignment = HORIZONTAL_ALIGNMENT_CENTER

		# Set up custom help text and finalize the button.
		# Pressing does nothing yet — only hover drives the helper tooltip.
		new_item.mouse_entered.connect(GameState.set_help_text.bind(i.help_text, new_item))
		new_item.mouse_exited.connect(GameState.clear_help_text.bind(new_item))
		cnt_items.add_child(new_item)
