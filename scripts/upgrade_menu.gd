extends CanvasLayer

var upgrade_container = null
var damage_upgrade_button = null
var damage_level_label = null
var bullet_upgrade_button = null
var bullet_level_label = null
var close_button = null

var player = null
var damage_upgrade_level = 0
var bullet_upgrade_level = 0
var upgrade_cost = 25

# Keyboard navigation
var selected_index = 0  # 0 = damage, 1 = bullet, 2 = close
var total_options = 3

func _ready():
	# Add to group for easy access
	add_to_group("upgrade_menu")
	
	# Start hidden
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Work even when paused
	
	# Get node references safely
	upgrade_container = get_node_or_null("CenterContainer")
	damage_upgrade_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/DamageUpgrade/PurchaseButton")
	damage_level_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/DamageUpgrade/LevelLabel")
	bullet_upgrade_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/BulletUpgrade/PurchaseButton")
	bullet_level_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/BulletUpgrade/LevelLabel")
	close_button = get_node_or_null("CenterContainer/VBoxContainer/CloseButton")
	
	# Debug print to check if nodes were found
	print("UpgradeMenu _ready() called")
	print("  upgrade_container: ", upgrade_container)
	print("  damage_upgrade_button: ", damage_upgrade_button)
	print("  damage_level_label: ", damage_level_label)
	print("  bullet_upgrade_button: ", bullet_upgrade_button)
	print("  bullet_level_label: ", bullet_level_label)
	print("  close_button: ", close_button)
	
	# Connect button signals if they exist
	if damage_upgrade_button:
		damage_upgrade_button.pressed.connect(_on_damage_upgrade_pressed)
	if bullet_upgrade_button:
		bullet_upgrade_button.pressed.connect(_on_bullet_upgrade_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	print("  player found: ", player)

func show_upgrade_menu():
	print("show_upgrade_menu() called!")
	visible = true
	get_tree().paused = true
	selected_index = 0  # Reset selection to first option
	update_upgrade_display()
	update_selection_highlight()

func hide_upgrade_menu():
	visible = false
	get_tree().paused = false
	get_tree().paused = false

func update_upgrade_display():
	if not player:
		return
	
	# Update damage upgrade display
	if damage_level_label:
		damage_level_label.text = "Level: %d" % damage_upgrade_level
	
	# Enable/disable damage purchase button based on gold
	if damage_upgrade_button:
		if player.gold >= upgrade_cost:
			damage_upgrade_button.disabled = false
			damage_upgrade_button.text = "Purchase (25 Gold)"
		else:
			damage_upgrade_button.disabled = true
			damage_upgrade_button.text = "Not Enough Gold"
	
	# Update bullet upgrade display
	if bullet_level_label:
		bullet_level_label.text = "Level: %d" % bullet_upgrade_level
	
	# Enable/disable bullet purchase button based on gold
	if bullet_upgrade_button:
		if player.gold >= upgrade_cost:
			bullet_upgrade_button.disabled = false
			bullet_upgrade_button.text = "Purchase (25 Gold)"
		else:
			bullet_upgrade_button.disabled = true
			bullet_upgrade_button.text = "Not Enough Gold"

func _on_damage_upgrade_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to both weapons
	damage_upgrade_level += 1
	
	# Upgrade pulse weapon damage
	if player.pulse_weapon:
		player.pulse_weapon.damage = int(player.pulse_weapon.damage * 1.5)
		print("Pulse weapon damage upgraded to: ", player.pulse_weapon.damage)
	
	# Upgrade bullet weapon damage
	if player.bullet_weapon:
		player.bullet_weapon.damage = int(player.bullet_weapon.damage * 1.5)
		print("Bullet weapon damage upgraded to: ", player.bullet_weapon.damage)
	
	print("All weapons upgraded! (Level ", damage_upgrade_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_bullet_upgrade_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to bullet weapon only
	bullet_upgrade_level += 1
	
	if player.bullet_weapon:
		# Increase max bullets by 2
		player.bullet_weapon.max_bullets += 2
		player.bullet_weapon.current_bullets = player.bullet_weapon.max_bullets
		print("Bullet capacity upgraded to: ", player.bullet_weapon.max_bullets, " bullets")
	
	print("Bullet weapon upgraded! (Level ", bullet_upgrade_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_close_pressed():
	hide_upgrade_menu()

func _input(event):
	# Only handle input when menu is visible
	if not visible:
		return
	
	# Navigate with arrow keys
	if event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % total_options
		update_selection_highlight()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + total_options) % total_options
		update_selection_highlight()
		get_viewport().set_input_as_handled()
	
	# Select with spacebar
	elif event.is_action_pressed("ui_accept"):  # Spacebar is mapped to ui_accept
		activate_selected_option()
		get_viewport().set_input_as_handled()

func update_selection_highlight():
	# Reset all button styles
	if damage_upgrade_button:
		damage_upgrade_button.modulate = Color(1, 1, 1, 1)
	if bullet_upgrade_button:
		bullet_upgrade_button.modulate = Color(1, 1, 1, 1)
	if close_button:
		close_button.modulate = Color(1, 1, 1, 1)
	
	# Highlight selected button
	match selected_index:
		0:  # Damage upgrade
			if damage_upgrade_button:
				damage_upgrade_button.modulate = Color(1.5, 1.5, 0.5, 1)  # Yellow highlight
		1:  # Bullet upgrade
			if bullet_upgrade_button:
				bullet_upgrade_button.modulate = Color(1.5, 1.5, 0.5, 1)  # Yellow highlight
		2:  # Close button
			if close_button:
				close_button.modulate = Color(1.5, 1.5, 0.5, 1)  # Yellow highlight

func activate_selected_option():
	match selected_index:
		0:  # Damage upgrade
			if damage_upgrade_button and not damage_upgrade_button.disabled:
				_on_damage_upgrade_pressed()
		1:  # Bullet upgrade
			if bullet_upgrade_button and not bullet_upgrade_button.disabled:
				_on_bullet_upgrade_pressed()
		2:  # Close button
			_on_close_pressed()
