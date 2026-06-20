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
		#var new_item = TextureRect.new()
		var new_item = HBoxContainer.new()
		var icon = TextureRect.new()
		var label = Label.new()
		
		# Add the icon
		icon.texture = i.texture
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# Make a label
		label.text = i.name
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# The Hbox is icon + label
		new_item.add_child(icon)
		new_item.add_child(label)
		
		# Set up custom help text and finalize the Hbox
		new_item.mouse_entered.connect(GameState.set_help_text.bind(i.help_text, new_item))
		new_item.mouse_exited.connect(GameState.clear_help_text.bind(new_item))
		cnt_items.add_child(new_item)
