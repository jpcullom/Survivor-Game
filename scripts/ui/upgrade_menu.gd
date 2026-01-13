extends CanvasLayer

var upgrade_container = null
var pulse_damage_button = null
var pulse_damage_label = null
var pulse_area_button = null
var pulse_area_label = null
var bullet_damage_button = null
var bullet_damage_label = null
var bullet_capacity_button = null
var bullet_capacity_label = null
var orbital_count_button = null
var orbital_count_label = null
var orbital_damage_button = null
var orbital_damage_label = null
var boomerang_count_button = null
var boomerang_count_label = null
var boomerang_damage_button = null
var boomerang_damage_label = null
var lightning_chains_button = null
var lightning_chains_label = null
var lightning_damage_button = null
var lightning_damage_label = null
var grenade_count_button = null
var grenade_count_label = null
var grenade_damage_button = null
var grenade_damage_label = null
var close_button = null

var player = null
var pulse_damage_level = 0
var pulse_area_level = 0
var bullet_damage_level = 0
var bullet_capacity_level = 0
var orbital_count_level = 0
var orbital_damage_level = 0
var boomerang_count_level = 0
var boomerang_damage_level = 0
var lightning_chains_level = 0
var lightning_damage_level = 0
var grenade_count_level = 0
var grenade_damage_level = 0
var total_upgrades = 0  # Track total upgrades purchased
var upgrade_cost = 25  # Current upgrade cost (will scale)
var base_cost = 25
var cost_increment = 5

# Keyboard navigation - 2D grid
var selected_row = 0  # 0-3 for upgrades, 4 for close
var selected_col = 0  # 0-2 for columns
var grid_rows = 4  # 4 upgrades per column
var grid_cols = 3  # 3 columns

func _ready():
	# Add to group for easy access
	add_to_group("upgrade_menu")
	
	# Start hidden
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Work even when paused
	
	# Get node references safely
	upgrade_container = get_node_or_null("CenterContainer")
	pulse_damage_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/PulseDamageUpgrade/PurchaseButton")
	pulse_damage_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/PulseDamageUpgrade/LevelLabel")
	pulse_area_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/PulseAreaUpgrade/PurchaseButton")
	pulse_area_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/PulseAreaUpgrade/LevelLabel")
	bullet_damage_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/BulletDamageUpgrade/PurchaseButton")
	bullet_damage_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/BulletDamageUpgrade/LevelLabel")
	bullet_capacity_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/BulletCapacityUpgrade/PurchaseButton")
	bullet_capacity_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column1/BulletCapacityUpgrade/LevelLabel")
	orbital_count_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/OrbitalCountUpgrade/PurchaseButton")
	orbital_count_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/OrbitalCountUpgrade/LevelLabel")
	orbital_damage_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/OrbitalDamageUpgrade/PurchaseButton")
	orbital_damage_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/OrbitalDamageUpgrade/LevelLabel")
	boomerang_count_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/BoomerangCountUpgrade/PurchaseButton")
	boomerang_count_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/BoomerangCountUpgrade/LevelLabel")
	boomerang_damage_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/BoomerangDamageUpgrade/PurchaseButton")
	boomerang_damage_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column2/BoomerangDamageUpgrade/LevelLabel")
	lightning_chains_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/LightningChainsUpgrade/PurchaseButton")
	lightning_chains_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/LightningChainsUpgrade/LevelLabel")
	lightning_damage_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/LightningDamageUpgrade/PurchaseButton")
	lightning_damage_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/LightningDamageUpgrade/LevelLabel")
	grenade_count_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/GrenadeCountUpgrade/PurchaseButton")
	grenade_count_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/GrenadeCountUpgrade/LevelLabel")
	grenade_damage_button = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/GrenadeDamageUpgrade/PurchaseButton")
	grenade_damage_label = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList/Column3/GrenadeDamageUpgrade/LevelLabel")
	close_button = get_node_or_null("CenterContainer/VBoxContainer/CloseButton")
	
	# Debug print to check if nodes were found
	print("UpgradeMenu _ready() called")
	print("  upgrade_container: ", upgrade_container)
	print("=== COLUMN 1 (Pulse + Bullet) ===")
	print("  pulse_damage_button: ", pulse_damage_button)
	print("  pulse_damage_label: ", pulse_damage_label)
	print("  pulse_area_button: ", pulse_area_button)
	print("  pulse_area_label: ", pulse_area_label)
	print("  bullet_damage_button: ", bullet_damage_button)
	print("  bullet_damage_label: ", bullet_damage_label)
	print("  bullet_capacity_button: ", bullet_capacity_button)
	print("  bullet_capacity_label: ", bullet_capacity_label)
	print("=== COLUMN 2 (Orbital + Boomerang) ===")
	print("  orbital_count_button: ", orbital_count_button)
	print("  orbital_count_label: ", orbital_count_label)
	print("  orbital_damage_button: ", orbital_damage_button)
	print("  orbital_damage_label: ", orbital_damage_label)
	print("  boomerang_count_button: ", boomerang_count_button)
	print("  boomerang_count_label: ", boomerang_count_label)
	print("  boomerang_damage_button: ", boomerang_damage_button)
	print("  boomerang_damage_label: ", boomerang_damage_label)
	print("=== COLUMN 3 (Lightning + Grenade) ===")
	print("  lightning_chains_button: ", lightning_chains_button)
	print("  lightning_chains_label: ", lightning_chains_label)
	print("  lightning_damage_button: ", lightning_damage_button)
	print("  lightning_damage_label: ", lightning_damage_label)
	print("  grenade_count_button: ", grenade_count_button)
	print("  grenade_count_label: ", grenade_count_label)
	print("  grenade_damage_button: ", grenade_damage_button)
	print("  grenade_damage_label: ", grenade_damage_label)
	print("=== OTHER ===")
	print("  close_button: ", close_button)
	
	# Print scene tree structure
	print("\\n=== SCENE TREE DEBUG ===")
	var upgrade_list = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList")
	if upgrade_list:
		print("UpgradeList children:")
		for child in upgrade_list.get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
			if child.name.begins_with("Column"):
				print("    ", child.name, " children:")
				for panel in child.get_children():
					print("      - ", panel.name, " (", panel.get_class(), ")")
					if panel.has_node("VBoxContainer"):
						var vbox = panel.get_node("VBoxContainer")
						print("        VBoxContainer children:")
						for item in vbox.get_children():
							print("          - ", item.name, " (", item.get_class(), ")")
	print("=== END SCENE TREE DEBUG ===\\n")
	
	# Connect button signals if they exist
	if pulse_damage_button:
		pulse_damage_button.pressed.connect(_on_pulse_damage_pressed)
	if pulse_area_button:
		pulse_area_button.pressed.connect(_on_pulse_area_pressed)
	if bullet_damage_button:
		bullet_damage_button.pressed.connect(_on_bullet_damage_pressed)
	if bullet_capacity_button:
		bullet_capacity_button.pressed.connect(_on_bullet_capacity_pressed)
	if orbital_count_button:
		orbital_count_button.pressed.connect(_on_orbital_count_pressed)
	if orbital_damage_button:
		orbital_damage_button.pressed.connect(_on_orbital_damage_pressed)
	if boomerang_count_button:
		boomerang_count_button.pressed.connect(_on_boomerang_count_pressed)
	if boomerang_damage_button:
		boomerang_damage_button.pressed.connect(_on_boomerang_damage_pressed)
	if lightning_chains_button:
		lightning_chains_button.pressed.connect(_on_lightning_chains_pressed)
	if lightning_damage_button:
		lightning_damage_button.pressed.connect(_on_lightning_damage_pressed)
	if grenade_count_button:
		grenade_count_button.pressed.connect(_on_grenade_count_pressed)
	if grenade_damage_button:
		grenade_damage_button.pressed.connect(_on_grenade_damage_pressed)
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
	selected_row = 0  # Reset selection to first option
	selected_col = 0
	
	# Debug: Print current scene tree when menu opens
	print("\\n=== MENU OPENED - SCENE TREE CHECK ===")
	var upgrade_list = get_node_or_null("CenterContainer/VBoxContainer/UpgradeList")
	if upgrade_list:
		print("UpgradeList found, checking columns:")
		for child in upgrade_list.get_children():
			print("  Column: ", child.name)
			for panel in child.get_children():
				print("    Panel: ", panel.name)
				var vbox = panel.get_node_or_null("VBoxContainer")
				if vbox:
					print("      VBoxContainer children:")
					for item in vbox.get_children():
						print("        - ", item.name, " (visible: ", item.visible, ")")
						if item is Label:
							print("          Text: '", item.text, "'")
						if item.name == "HBoxContainer":
							print("          HBoxContainer children:")
							for hbox_child in item.get_children():
								print("            - ", hbox_child.name, " (", hbox_child.get_class(), ") visible=", hbox_child.visible)
								if hbox_child is Label:
									print("              Text: '", hbox_child.text, "'")
									print("              Size: ", hbox_child.size)
									print("              Custom min size: ", hbox_child.custom_minimum_size)
	else:
		print("ERROR: UpgradeList not found!")
	print("=== END MENU CHECK ===\\n")
	
	update_upgrade_display()
	update_selection_highlight()

func calculate_upgrade_cost() -> int:
	# Cost increases by 5 for each upgrade: 25, 30, 35, 40...
	return base_cost + (cost_increment * total_upgrades)

func calculate_next_threshold() -> int:
	# Calculate sum of all costs up to the next upgrade
	# First upgrade: 25
	# Second upgrade: 25 + 30 = 55
	# Third upgrade: 25 + 30 + 35 = 90
	var total = 0
	for i in range(total_upgrades + 1):
		total += base_cost + (cost_increment * i)
	return total

func hide_upgrade_menu():
	visible = false
	get_tree().paused = false
	get_tree().paused = false

func update_upgrade_display():
	if not player:
		return
	
	# Update current upgrade cost
	upgrade_cost = calculate_upgrade_cost()
	
	# Update pulse damage upgrade display
	if pulse_damage_label:
		pulse_damage_label.text = "Level: %d" % pulse_damage_level
	
	if pulse_damage_button:
		if player.gold >= upgrade_cost:
			pulse_damage_button.disabled = false
			pulse_damage_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			pulse_damage_button.disabled = true
			pulse_damage_button.text = "Not Enough Gold"
	
	# Update pulse area upgrade display
	if pulse_area_label:
		pulse_area_label.text = "Level: %d" % pulse_area_level
	
	if pulse_area_button:
		if player.gold >= upgrade_cost:
			pulse_area_button.disabled = false
			pulse_area_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			pulse_area_button.disabled = true
			pulse_area_button.text = "Not Enough Gold"
	
	# Update bullet damage upgrade display
	if bullet_damage_label:
		bullet_damage_label.text = "Level: %d" % bullet_damage_level
	
	if bullet_damage_button:
		if player.gold >= upgrade_cost:
			bullet_damage_button.disabled = false
			bullet_damage_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			bullet_damage_button.disabled = true
			bullet_damage_button.text = "Not Enough Gold"
	
	# Update bullet capacity upgrade display
	if bullet_capacity_label:
		bullet_capacity_label.text = "Level: %d" % bullet_capacity_level
	
	if bullet_capacity_button:
		if player.gold >= upgrade_cost:
			bullet_capacity_button.disabled = false
			bullet_capacity_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			bullet_capacity_button.disabled = true
			bullet_capacity_button.text = "Not Enough Gold"
	
	# Update orbital count upgrade display
	if orbital_count_label:
		orbital_count_label.text = "Level: %d" % orbital_count_level
	
	if orbital_count_button:
		if player.gold >= upgrade_cost:
			orbital_count_button.disabled = false
			orbital_count_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			orbital_count_button.disabled = true
			orbital_count_button.text = "Not Enough Gold"
	
	# Update orbital damage upgrade display
	if orbital_damage_label:
		orbital_damage_label.text = "Level: %d" % orbital_damage_level
	
	if orbital_damage_button:
		if player.gold >= upgrade_cost:
			orbital_damage_button.disabled = false
			orbital_damage_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			orbital_damage_button.disabled = true
			orbital_damage_button.text = "Not Enough Gold"
	
	# Update boomerang count upgrade display
	if boomerang_count_label:
		boomerang_count_label.text = "Level: %d" % boomerang_count_level
	
	if boomerang_count_button:
		if player.gold >= upgrade_cost:
			boomerang_count_button.disabled = false
			boomerang_count_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			boomerang_count_button.disabled = true
			boomerang_count_button.text = "Not Enough Gold"
	
	# Update boomerang damage upgrade display
	if boomerang_damage_label:
		boomerang_damage_label.text = "Level: %d" % boomerang_damage_level
	
	if boomerang_damage_button:
		if player.gold >= upgrade_cost:
			boomerang_damage_button.disabled = false
			boomerang_damage_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			boomerang_damage_button.disabled = true
			boomerang_damage_button.text = "Not Enough Gold"
	
	# Update lightning chains upgrade display
	if lightning_chains_label:
		lightning_chains_label.text = "Level: %d" % lightning_chains_level
	
	if lightning_chains_button:
		if player.gold >= upgrade_cost:
			lightning_chains_button.disabled = false
			lightning_chains_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			lightning_chains_button.disabled = true
			lightning_chains_button.text = "Not Enough Gold"
	
	# Update lightning damage upgrade display
	if lightning_damage_label:
		lightning_damage_label.text = "Level: %d" % lightning_damage_level
	
	if lightning_damage_button:
		if player.gold >= upgrade_cost:
			lightning_damage_button.disabled = false
			lightning_damage_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			lightning_damage_button.disabled = true
			lightning_damage_button.text = "Not Enough Gold"
	
	# Update grenade count upgrade display
	if grenade_count_label:
		grenade_count_label.text = "Level: %d" % grenade_count_level
	
	if grenade_count_button:
		if player.gold >= upgrade_cost:
			grenade_count_button.disabled = false
			grenade_count_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			grenade_count_button.disabled = true
			grenade_count_button.text = "Not Enough Gold"
	
	# Update grenade damage upgrade display
	if grenade_damage_label:
		grenade_damage_label.text = "Level: %d" % grenade_damage_level
	
	if grenade_damage_button:
		if player.gold >= upgrade_cost:
			grenade_damage_button.disabled = false
			grenade_damage_button.text = "Purchase (" + str(upgrade_cost) + " Gold)"
		else:
			grenade_damage_button.disabled = true
			grenade_damage_button.text = "Not Enough Gold"

func _on_pulse_damage_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to pulse weapon only
	pulse_damage_level += 1
	total_upgrades += 1
	
	if player.pulse_weapon:
		player.pulse_weapon.damage = int(player.pulse_weapon.damage * 1.5)
		print("Pulse weapon damage upgraded to: ", player.pulse_weapon.damage)
	
	print("Pulse weapon upgraded! (Level ", pulse_damage_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_pulse_area_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to pulse weapon range
	pulse_area_level += 1
	total_upgrades += 1
	
	if player.pulse_weapon:
		player.pulse_weapon.attack_range *= 1.3
		print("Pulse weapon range upgraded to: ", player.pulse_weapon.attack_range)
	
	print("Pulse weapon range upgraded! (Level ", pulse_area_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_bullet_damage_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to bullet weapon damage
	bullet_damage_level += 1
	total_upgrades += 1
	
	if player.bullet_weapon:
		player.bullet_weapon.damage = int(player.bullet_weapon.damage * 1.5)
		print("Bullet weapon damage upgraded to: ", player.bullet_weapon.damage)
	
	print("Bullet weapon damage upgraded! (Level ", bullet_damage_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_bullet_capacity_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to bullet weapon capacity
	bullet_capacity_level += 1
	total_upgrades += 1
	
	if player.bullet_weapon:
		# Increase max bullets by 2
		player.bullet_weapon.max_bullets += 2
		player.bullet_weapon.current_bullets = player.bullet_weapon.max_bullets
		print("Bullet capacity upgraded to: ", player.bullet_weapon.max_bullets, " bullets")
	
	print("Bullet capacity upgraded! (Level ", bullet_capacity_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_orbital_count_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to orbital weapon count
	orbital_count_level += 1
	total_upgrades += 1
	
	if player.orbital_weapon:
		player.orbital_weapon.upgrade_count()
		print("Orbital count upgraded to: ", player.orbital_weapon.orbital_count)
	
	print("Orbital count upgraded! (Level ", orbital_count_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_orbital_damage_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to orbital weapon damage
	orbital_damage_level += 1
	total_upgrades += 1
	
	if player.orbital_weapon:
		player.orbital_weapon.upgrade_damage()
		print("Orbital damage upgraded to: ", player.orbital_weapon.damage)
	
	print("Orbital damage upgraded! (Level ", orbital_damage_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_boomerang_count_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to boomerang weapon count
	boomerang_count_level += 1
	total_upgrades += 1
	
	if player.boomerang_weapon:
		player.boomerang_weapon.upgrade_count()
		print("Boomerang count upgraded to: ", player.boomerang_weapon.boomerang_count)
	
	print("Boomerang count upgraded! (Level ", boomerang_count_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_boomerang_damage_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to boomerang weapon damage
	boomerang_damage_level += 1
	total_upgrades += 1
	
	if player.boomerang_weapon:
		player.boomerang_weapon.upgrade_damage()
		print("Boomerang damage upgraded to: ", player.boomerang_weapon.damage)
	
	print("Boomerang damage upgraded! (Level ", boomerang_damage_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_lightning_chains_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to lightning weapon chains
	lightning_chains_level += 1
	total_upgrades += 1
	
	if player.lightning_weapon:
		player.lightning_weapon.upgrade_chains()
		print("Lightning chains upgraded to: ", player.lightning_weapon.max_chains)
	
	print("Lightning chains upgraded! (Level ", lightning_chains_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_lightning_damage_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to lightning weapon damage
	lightning_damage_level += 1
	total_upgrades += 1
	
	if player.lightning_weapon:
		player.lightning_weapon.upgrade_damage()
		print("Lightning damage upgraded to: ", player.lightning_weapon.damage)
	
	print("Lightning damage upgraded! (Level ", lightning_damage_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_grenade_count_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to grenade weapon count
	grenade_count_level += 1
	total_upgrades += 1
	
	if player.grenade_weapon:
		player.grenade_weapon.upgrade_count()
		print("Grenade count upgraded to: ", player.grenade_weapon.grenade_count)
	
	print("Grenade count upgraded! (Level ", grenade_count_level, ")")
	
	# Update display
	update_upgrade_display()
	
	# Close menu after purchase
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func _on_grenade_damage_pressed():
	if not player or player.gold < upgrade_cost:
		return
	
	# Deduct gold
	player.gold -= upgrade_cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	# Apply upgrade to grenade weapon damage
	grenade_damage_level += 1
	total_upgrades += 1
	
	if player.grenade_weapon:
		player.grenade_weapon.upgrade_damage()
		print("Grenade damage upgraded to: ", player.grenade_weapon.damage)
	
	print("Grenade damage upgraded! (Level ", grenade_damage_level, ")")
	
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
	
	# Check for Enter key to activate selection
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		activate_selected_option()
		get_viewport().set_input_as_handled()
		return
	
	# Block spacebar from activating buttons
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		return
	
	# Navigate with arrow keys - 2D grid
	if event.is_action_pressed("ui_down"):
		if selected_row < grid_rows:  # If not on close button
			selected_row = min(selected_row + 1, grid_rows)
		update_selection_highlight()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_up"):
		selected_row = max(selected_row - 1, 0)
		update_selection_highlight()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_right"):
		if selected_row < grid_rows:  # Only move right if in upgrade grid
			selected_col = (selected_col + 1) % grid_cols
			update_selection_highlight()
			get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_left"):
		if selected_row < grid_rows:  # Only move left if in upgrade grid
			selected_col = (selected_col - 1 + grid_cols) % grid_cols
			update_selection_highlight()
			get_viewport().set_input_as_handled()

func update_selection_highlight():
	# Reset all button styles
	if pulse_damage_button:
		pulse_damage_button.modulate = Color(1, 1, 1, 1)
	if pulse_area_button:
		pulse_area_button.modulate = Color(1, 1, 1, 1)
	if bullet_damage_button:
		bullet_damage_button.modulate = Color(1, 1, 1, 1)
	if bullet_capacity_button:
		bullet_capacity_button.modulate = Color(1, 1, 1, 1)
	if orbital_count_button:
		orbital_count_button.modulate = Color(1, 1, 1, 1)
	if orbital_damage_button:
		orbital_damage_button.modulate = Color(1, 1, 1, 1)
	if boomerang_count_button:
		boomerang_count_button.modulate = Color(1, 1, 1, 1)
	if boomerang_damage_button:
		boomerang_damage_button.modulate = Color(1, 1, 1, 1)
	if lightning_chains_button:
		lightning_chains_button.modulate = Color(1, 1, 1, 1)
	if lightning_damage_button:
		lightning_damage_button.modulate = Color(1, 1, 1, 1)
	if grenade_count_button:
		grenade_count_button.modulate = Color(1, 1, 1, 1)
	if grenade_damage_button:
		grenade_damage_button.modulate = Color(1, 1, 1, 1)
	if close_button:
		close_button.modulate = Color(1, 1, 1, 1)
	
	# Highlight selected button based on row and column
	if selected_row == grid_rows:  # Close button
		if close_button:
			close_button.modulate = Color(1.5, 1.5, 0.5, 1)
	else:
		# Determine which button based on column and row
		var button = null
		match selected_col:
			0:  # Column 1 (Pulse + Bullet)
				match selected_row:
					0: button = pulse_damage_button
					1: button = pulse_area_button
					2: button = bullet_damage_button
					3: button = bullet_capacity_button
			1:  # Column 2 (Orbital + Boomerang)
				match selected_row:
					0: button = orbital_count_button
					1: button = orbital_damage_button
					2: button = boomerang_count_button
					3: button = boomerang_damage_button
			2:  # Column 3 (Lightning + Grenade)
				match selected_row:
					0: button = lightning_chains_button
					1: button = lightning_damage_button
					2: button = grenade_count_button
					3: button = grenade_damage_button
		
		if button:
			button.modulate = Color(1.5, 1.5, 0.5, 1)

func activate_selected_option():
	if selected_row == grid_rows:  # Close button
		_on_close_pressed()
		return
	
	# Determine which upgrade based on column and row
	match selected_col:
		0:  # Column 1 (Pulse + Bullet)
			match selected_row:
				0:
					if pulse_damage_button and not pulse_damage_button.disabled:
						_on_pulse_damage_pressed()
				1:
					if pulse_area_button and not pulse_area_button.disabled:
						_on_pulse_area_pressed()
				2:
					if bullet_damage_button and not bullet_damage_button.disabled:
						_on_bullet_damage_pressed()
				3:
					if bullet_capacity_button and not bullet_capacity_button.disabled:
						_on_bullet_capacity_pressed()
		1:  # Column 2 (Orbital + Boomerang)
			match selected_row:
				0:
					if orbital_count_button and not orbital_count_button.disabled:
						_on_orbital_count_pressed()
				1:
					if orbital_damage_button and not orbital_damage_button.disabled:
						_on_orbital_damage_pressed()
				2:
					if boomerang_count_button and not boomerang_count_button.disabled:
						_on_boomerang_count_pressed()
				3:
					if boomerang_damage_button and not boomerang_damage_button.disabled:
						_on_boomerang_damage_pressed()
		2:  # Column 3 (Lightning + Grenade)
			match selected_row:
				0:
					if lightning_chains_button and not lightning_chains_button.disabled:
						_on_lightning_chains_pressed()
				1:
					if lightning_damage_button and not lightning_damage_button.disabled:
						_on_lightning_damage_pressed()
				2:
					if grenade_count_button and not grenade_count_button.disabled:
						_on_grenade_count_pressed()
				3:
					if grenade_damage_button and not grenade_damage_button.disabled:
						_on_grenade_damage_pressed()
