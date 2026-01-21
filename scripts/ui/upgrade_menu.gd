extends CanvasLayer

# Roguelike progression system - show 3 random upgrades each time

var player = null
var upgrade_cost = 25
var base_cost = 25
var cost_increment = 5
var total_upgrades = 0

# Track upgrade levels
var weapon_levels = {
	"bullet_damage": 0,
	"bullet_capacity": 0,
	"pulse_damage": 0,
	"pulse_area": 0,
	"orbital_count": 0,
	"orbital_damage": 0,
	"orbital_speed": 0,
	"boomerang_count": 0,
	"boomerang_damage": 0,
	"lightning_chains": 0,
	"lightning_damage": 0,
	"grenade_count": 0,
	"grenade_damage": 0,
	"meteor_damage": 0,
	"meteor_cooldown": 0,
	"meteor_count": 0,
	"magnet": 0,
	"speed_boost": 0,
	"crown": 0
}

# Available upgrade options
var current_options = []  # Will hold 3 random upgrade options
var selected_option = 0  # 0, 1, or 2

# Weapon sprites for upgrade menu
var weapon_sprites = {
	"bullet": preload("res://sprites/pistol.png"),
	"boomerang": preload("res://sprites/boomerang.png"),
	"meteor": preload("res://sprites/meteor.png"),
	"grenade": preload("res://sprites/grenade.png"),
	"lightning": preload("res://sprites/lightning.png"),
	"orbital": preload("res://sprites/orbital.png"),
	"pulse": preload("res://sprites/pulse.png")
}

# UI references (we'll create these dynamically)
var option_buttons = []
var option_labels = []
var option_descriptions = []

func _ready():
	add_to_group("upgrade_menu")
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("[NEW UPGRADE MENU] Initialized!")
	
	# Wait for player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	print("[NEW UPGRADE MENU] Player found: ", player)

func calculate_upgrade_cost() -> int:
	return base_cost + (cost_increment * total_upgrades)

func calculate_next_threshold() -> int:
	var total = 0
	for i in range(total_upgrades + 1):
		total += base_cost + (cost_increment * i)
	return total

func show_upgrade_menu():
	if not player:
		return
	
	print("[UPGRADE MENU] Generating 3 random options...")
	visible = true
	get_tree().paused = true
	selected_option = 0
	
	# Update title
	var title = get_node_or_null("CenterContainer/VBoxContainer/TitleLabel")
	if title:
		title.text = "CHOOSE YOUR UPGRADE!"
	
	# Generate 3 random upgrade options
	current_options = generate_upgrade_options()
	
	# Display the options
	display_options()
	update_selection_highlight()

func hide_upgrade_menu():
	visible = false
	get_tree().paused = false

func generate_upgrade_options() -> Array:
	print("[UPGRADE MENU] generate_upgrade_options called")
	
	# Build pool of all possible upgrades
	var upgrade_pool = []
	
	# Add passive upgrades to pool
	upgrade_pool.append({
		"type": "upgrade",
		"upgrade_key": "magnet",
		"name": "Magnet Level " + str(weapon_levels["magnet"] + 1),
		"description": "Increases gold pickup range by 30 pixels (Current level: " + str(weapon_levels["magnet"]) + ")"
	})
	
	upgrade_pool.append({
		"type": "upgrade",
		"upgrade_key": "speed_boost",
		"name": "Speed Boost Level " + str(weapon_levels["speed_boost"] + 1),
		"description": "Increases movement speed by 25% (Current level: " + str(weapon_levels["speed_boost"]) + ")"
	})
	
	var next_crown_bonus = (weapon_levels["crown"] + 1) * 5
	upgrade_pool.append({
		"type": "upgrade",
		"upgrade_key": "crown",
		"name": "Crown Level " + str(weapon_levels["crown"] + 1),
		"description": "Add +" + str(next_crown_bonus) + " to each gold pickup (Current level: " + str(weapon_levels["crown"]) + ")"
	})
	
	# Add weapon unlocks for locked weapons (cap at 6 weapons total)
	var unlocked_count = 0
	for weapon_name in player.unlocked_weapons:
		if player.unlocked_weapons[weapon_name]:
			unlocked_count += 1
	
	# Only offer weapon unlocks if we haven't reached the cap
	if unlocked_count < 6:
		for weapon_name in player.unlocked_weapons:
			if not player.unlocked_weapons[weapon_name]:
				upgrade_pool.append({
					"type": "unlock",
					"weapon": weapon_name,
					"name": "Unlock " + weapon_name.capitalize() + " Weapon",
					"description": get_weapon_description(weapon_name)
				})
	
	# Add upgrades for unlocked weapons
	if player.unlocked_weapons["bullet"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "bullet_damage",
			"name": "Bullet Damage +50%",
			"description": "Increases bullet weapon damage"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "bullet_capacity",
			"name": "Bullet Capacity +2",
			"description": "Add 2 more bullets to magazine"
		})
	
	if player.unlocked_weapons["pulse"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "pulse_damage",
			"name": "Pulse Damage +30%",
			"description": "Increases pulse weapon damage"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "pulse_area",
			"name": "Pulse Area +20%",
			"description": "Increases pulse weapon range"
		})
	
	if player.unlocked_weapons["orbital"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "orbital_count",
			"name": "Orbital Count +1",
			"description": "Add one more orbital"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "orbital_damage",
			"name": "Orbital Damage +50%",
			"description": "Increases orbital damage"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "orbital_speed",
			"name": "Orbital Speed +0.5",
			"description": "Makes orbitals rotate faster"
		})
	
	if player.unlocked_weapons["boomerang"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "boomerang_count",
			"name": "Boomerang Count +1",
			"description": "Throw one more boomerang"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "boomerang_damage",
			"name": "Boomerang Damage +50%",
			"description": "Increases boomerang damage"
		})
	
	if player.unlocked_weapons["lightning"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "lightning_chains",
			"name": "Lightning Chains +1",
			"description": "Chain to one more enemy"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "lightning_damage",
			"name": "Lightning Damage +50%",
			"description": "Increases lightning damage"
		})
	
	if player.unlocked_weapons["grenade"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "grenade_count",
			"name": "Grenade Count +1",
			"description": "Throw one more grenade"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "grenade_damage",
			"name": "Grenade Damage +50%",
			"description": "Increases grenade damage"
		})
	
	if player.unlocked_weapons["meteor"]:
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "meteor_damage",
			"name": "Meteor Damage +50%",
			"description": "Increases meteor impact damage"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "meteor_cooldown",
			"name": "Meteor Cooldown -0.3s",
			"description": "Strike more frequently with meteors"
		})
	
	# TEMPORARY: Always add pulse upgrade to slot 1 for testing
	# var test_option = null
	# if player.unlocked_weapons["pulse"]:
	# 	test_option = {
	# 		"type": "upgrade",
	# 		"upgrade_key": "pulse_damage",
	# 		"name": "Pulse Damage +30%",
	# 		"description": "Increases pulse weapon damage"
	# 	}
	# else:
	# 	test_option = {
	# 		"type": "unlock",
	# 		"weapon": "pulse",
	# 		"name": "Unlock Pulse Weapon",
	# 		"description": "AoE damage around player"
	# 	}
	
	# Shuffle and pick 3 random options
	upgrade_pool.shuffle()
	var options = []
	
	# Force test option into first slot
	# if test_option:
	# 	options.append(test_option)
	
	for i in range(min(3, upgrade_pool.size())):
		options.append(upgrade_pool[i])
	
	print("[UPGRADE MENU] Total options generated: ", options.size())
	print("[UPGRADE MENU] Option 1: ", options[0]["name"])
	if options.size() > 1:
		print("[UPGRADE MENU] Option 2: ", options[1]["name"])
	if options.size() > 2:
		print("[UPGRADE MENU] Option 3: ", options[2]["name"])
	
	return options

func get_weapon_description(weapon_name: String) -> String:
	match weapon_name:
		"pulse":
			return "AoE damage around player"
		"orbital":
			return "Rotating satellites that damage on contact"
		"boomerang":
			return "Throws boomerangs that return"
		"lightning":
			return "Chain lightning between enemies"
		"grenade":
			return "Explosive projectiles"
		"meteor":
			return "Rain meteors from above at random enemies"
	return "New weapon"

func display_options():
	# Update the subtitle to show the cost
	var subtitle = get_node_or_null("CenterContainer/VBoxContainer/SubtitleLabel")
	if subtitle:
		var cost = calculate_upgrade_cost()
		subtitle.text = "Cost: " + str(cost) + " gold | Press 1, 2, or 3, then ENTER to confirm"
	
	# Update option panels
	for i in range(3):
		var option_panel = get_node_or_null("CenterContainer/VBoxContainer/Option" + str(i + 1))
		if not option_panel:
			continue
		
		if i < current_options.size():
			var opt = current_options[i]
			var vbox = option_panel.get_node_or_null("VBox")
			var name_label = option_panel.get_node_or_null("VBox/NameLabel")
			var desc_label = option_panel.get_node_or_null("VBox/DescLabel")
			
			if name_label:
				name_label.text = "[" + str(i + 1) + "] " + opt["name"]
			if desc_label:
				desc_label.text = opt["description"]
			
			# Add weapon sprite if applicable
			var weapon_key = get_weapon_key_from_option(opt)
			if weapon_key and weapon_key in weapon_sprites:
				# Check if icon already exists
				var existing_icon = vbox.get_node_or_null("WeaponIcon")
				if not existing_icon and vbox:
					var icon = TextureRect.new()
					icon.name = "WeaponIcon"
					icon.texture = weapon_sprites[weapon_key]
					icon.custom_minimum_size = Vector2(40, 40)
					icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
					icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					
					# Apply weapon-specific scaling
					if weapon_key == "boomerang":
						icon.scale = Vector2(0.5, 0.5)
					elif weapon_key == "bullet":
						icon.scale = Vector2(0.9, 0.9)
					elif weapon_key == "meteor":
						icon.scale = Vector2(1.4, 1.4)
					elif weapon_key == "grenade":
						icon.scale = Vector2(0.8, 0.8)
					elif weapon_key == "lightning":
						icon.scale = Vector2(0.7, 0.7)
					elif weapon_key == "orbital":
						icon.scale = Vector2(0.8, 0.8)
					elif weapon_key == "pulse":
						icon.scale = Vector2(0.8, 0.8)
					
					vbox.add_child(icon)
					vbox.move_child(icon, 0)  # Put icon at the top
				elif existing_icon:
					existing_icon.texture = weapon_sprites[weapon_key]
					existing_icon.visible = true
			else:
				# Hide icon if it exists but not needed
				var existing_icon = vbox.get_node_or_null("WeaponIcon") if vbox else null
				if existing_icon:
					existing_icon.visible = false
			
			option_panel.visible = true
		else:
			option_panel.visible = false
	
	# Print to console as well
	print("[UPGRADE MENU] Available options:")
	for i in range(current_options.size()):
		var opt = current_options[i]
		print("  [", i + 1, "] ", opt["name"], " - ", opt["description"])

func get_weapon_key_from_option(opt: Dictionary) -> String:
	# Extract weapon key from upgrade option
	if opt["type"] == "unlock":
		return opt["weapon"]
	elif opt["type"] == "upgrade" and "upgrade_key" in opt:
		var key = opt["upgrade_key"]
		# Extract weapon name from upgrade key (e.g., "bullet_damage" -> "bullet")
		if key.begins_with("bullet_"):
			return "bullet"
		elif key.begins_with("boomerang_"):
			return "boomerang"
		elif key.begins_with("meteor_"):
			return "meteor"
		elif key.begins_with("grenade_"):
			return "grenade"
		elif key.begins_with("lightning_"):
			return "lightning"
		elif key.begins_with("orbital_"):
			return "orbital"
		elif key.begins_with("pulse_"):
			return "pulse"
	return ""

func apply_upgrade(option_index: int):
	if option_index < 0 or option_index >= current_options.size():
		return
	
	var option = current_options[option_index]
	var cost = calculate_upgrade_cost()
	
	if player.gold < cost:
		print("[UPGRADE] Not enough gold!")
		return
	
	# Deduct gold
	player.gold -= cost
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(player.gold)
	
	total_upgrades += 1
	
	# Apply the upgrade
	if option["type"] == "unlock":
		player.unlock_weapon(option["weapon"])
		# Update HUD weapon slots
		var hud_node = get_tree().get_first_node_in_group("hud")
		if hud_node and hud_node.has_method("update_weapon_slots"):
			hud_node.update_weapon_slots()
	elif option["type"] == "upgrade":
		apply_weapon_upgrade(option["upgrade_key"])
	
	print("[UPGRADE] Applied: ", option["name"])
	
	# Close menu
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func apply_weapon_upgrade(upgrade_key: String):
	weapon_levels[upgrade_key] += 1
	var level = weapon_levels[upgrade_key]
	
	print("[UPGRADE] ", upgrade_key, " level is now: ", level)
	
	# Check for Frog Overload trigger (level 5)
	var trigger_frog_overload = false
	
	match upgrade_key:
		"bullet_damage":
			if player.bullet_weapon:
				player.bullet_weapon.damage = int(player.bullet_weapon.damage * 1.5)
				print("Bullet damage: ", player.bullet_weapon.damage)
				if level >= 5:
					trigger_frog_overload = true
		"bullet_capacity":
			if player.bullet_weapon:
				player.bullet_weapon.max_bullets += 2
				player.bullet_weapon.current_bullets = player.bullet_weapon.max_bullets
				print("Bullet capacity: ", player.bullet_weapon.max_bullets)
				if level >= 5:
					trigger_frog_overload = true
		"pulse_damage":
			if player.pulse_weapon:
				player.pulse_weapon.damage = int(player.pulse_weapon.damage * 1.3)
				print("Pulse damage: ", player.pulse_weapon.damage)
				if level >= 5:
					trigger_frog_overload = true
		"pulse_area":
			if player.pulse_weapon:
				player.pulse_weapon.attack_range *= 1.2
				print("Pulse range: ", player.pulse_weapon.attack_range)
				if level >= 5:
					trigger_frog_overload = true
		"orbital_count":
			if player.orbital_weapon:
				player.orbital_weapon.upgrade_count()
				if level >= 5:
					trigger_frog_overload = true
		"orbital_damage":
			if player.orbital_weapon:
				player.orbital_weapon.upgrade_damage()
				if level >= 5:
					trigger_frog_overload = true
		"orbital_speed":
			if player.orbital_weapon:
				player.orbital_weapon.upgrade_speed()
				if level >= 5:
					trigger_frog_overload = true
		"boomerang_count":
			if player.boomerang_weapon:
				player.boomerang_weapon.upgrade_count()
				if level >= 5:
					trigger_frog_overload = true
		"boomerang_damage":
			if player.boomerang_weapon:
				player.boomerang_weapon.upgrade_damage()
				if level >= 5:
					trigger_frog_overload = true
		"lightning_chains":
			if player.lightning_weapon:
				player.lightning_weapon.upgrade_chains()
				if level >= 5:
					trigger_frog_overload = true
		"lightning_damage":
			if player.lightning_weapon:
				player.lightning_weapon.upgrade_damage()
				if level >= 5:
					trigger_frog_overload = true
		"grenade_count":
			if player.grenade_weapon:
				player.grenade_weapon.upgrade_count()
				if level >= 5:
					trigger_frog_overload = true
		"grenade_damage":
			if player.grenade_weapon:
				player.grenade_weapon.upgrade_damage()
				if level >= 5:
					trigger_frog_overload = true
		"meteor_damage":
			if player.meteor_weapon:
				player.meteor_weapon.upgrade_damage()
				if level >= 5:
					trigger_frog_overload = true
		"meteor_cooldown":
			if player.meteor_weapon:
				player.meteor_weapon.upgrade_cooldown()
				if level >= 5:
					trigger_frog_overload = true
		"meteor_count":
			if player.meteor_weapon:
				player.meteor_weapon.upgrade_count()
				if level >= 5:
					trigger_frog_overload = true
		"magnet":
			player.upgrade_magnet()
			print("[UPGRADE] Magnet level: ", player.magnet_level, ", pickup range: ", player.pickup_range)
		"speed_boost":
			player.upgrade_speed_boost()
			print("[UPGRADE] Speed boost level: ", player.speed_boost_level, ", speed: ", player.speed)
		"crown":
			player.upgrade_crown()
			var current_bonus = player.crown_level * 5
			print("[UPGRADE] Crown level: ", player.crown_level, ", bonus per pickup: +", current_bonus)
	
	# Trigger Frog Overload if level reached 5
	if trigger_frog_overload:
		print("[UPGRADE MENU] FROG OVERLOAD TRIGGERED FOR: ", upgrade_key)
		trigger_frog_overload_for_upgrade(upgrade_key)

func trigger_frog_overload_for_upgrade(upgrade_key: String):
	print("[FROG OVERLOAD] Triggering for: ", upgrade_key)
	print("[FROG OVERLOAD] Level at trigger: ", weapon_levels[upgrade_key])
	
	# Show dialogue splash
	var dialogue_splash = get_tree().get_first_node_in_group("dialogue_splash")
	if dialogue_splash and dialogue_splash.has_method("show_frog_overload"):
		dialogue_splash.show_frog_overload()
	
	# Activate weapon-specific overload
	match upgrade_key:
		"bullet_damage", "bullet_capacity":
			if player.bullet_weapon:
				player.bullet_weapon.activate_frog_overload(upgrade_key, self)
		"pulse_damage", "pulse_area":
			if player.pulse_weapon:
				player.pulse_weapon.activate_frog_overload(upgrade_key, self)
		"boomerang_damage", "boomerang_count":
			if player.boomerang_weapon:
				player.boomerang_weapon.activate_frog_overload(upgrade_key, self)
		"grenade_damage", "grenade_count":
			if player.grenade_weapon:
				player.grenade_weapon.activate_frog_overload(upgrade_key, self)
		"lightning_damage", "lightning_chains":
			if player.lightning_weapon:
				player.lightning_weapon.activate_frog_overload(upgrade_key, self)
		"orbital_damage", "orbital_count", "orbital_speed":
			if player.orbital_weapon:
				player.orbital_weapon.activate_frog_overload(upgrade_key, self)
		"meteor_damage", "meteor_cooldown", "meteor_count":
			if player.meteor_weapon:
				player.meteor_weapon.activate_frog_overload(upgrade_key, self)

func _input(event):
	if not visible:
		return
	
	# Navigate with 1, 2, 3 keys or arrow keys
	if event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_1):
		selected_option = 0
		update_selection_highlight()
		print("[SELECT] Option 1")
		get_viewport().set_input_as_handled()
	elif (event is InputEventKey and event.pressed and event.keycode == KEY_2):
		if current_options.size() > 1:
			selected_option = 1
			update_selection_highlight()
			print("[SELECT] Option 2")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_3):
		if current_options.size() > 2:
			selected_option = 2
			update_selection_highlight()
			print("[SELECT] Option 3")
		get_viewport().set_input_as_handled()
	
	# Confirm with Enter or Space
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		apply_upgrade(selected_option)
		get_viewport().set_input_as_handled()

func update_selection_highlight():
	# Reset all panels
	for i in range(3):
		var panel = get_node_or_null("CenterContainer/VBoxContainer/Option" + str(i + 1))
		if panel:
			if i == selected_option:
				panel.modulate = Color(1.5, 1.5, 0.5)  # Yellow highlight
			else:
				panel.modulate = Color(1, 1, 1)  # Normal
