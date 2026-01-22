extends CanvasLayer

# Roguelike progression system - show 3 random upgrades each time

var player = null
var total_upgrades = 0

# Track upgrade levels
var weapon_levels = {
	"bullet_damage": 0,
	"bullet_capacity": 0,
	"pulse_damage": 0,
	"pulse_area": 0,
	"orbital_count": 0,
	"orbital_damage": 0,
	"boomerang_count": 0,
	"boomerang_damage": 0,
	"lightning_chains": 0,
	"lightning_damage": 0,
	"grenade_count": 0,
	"grenade_damage": 0,
	"magnet": 0
}

# Available upgrade options
var current_options = []  # Will hold 3 random upgrade options
var selected_option = 0  # 0, 1, or 2

# UI references (we'll create these dynamically)
var option_buttons = []
var option_labels = []
var option_descriptions = []

func _ready():
	add_to_group("upgrade_menu")
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Wait for player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	print("Upgrade menu initialized, player: ", player)



func calculate_next_threshold() -> int:
	# Exponential scaling: 15 * (1.35 ^ level)
	# Level 1: ~20, Level 2: ~27, Level 3: ~37, Level 5: ~67, Level 10: ~273
	if player:
		return int(15 * pow(1.35, player.player_level))
	return 20

func show_upgrade_menu():
	if not player:
		return
	
	print("[UPGRADE MENU] Generating 3 random options...")
	visible = true
	get_tree().paused = true
	selected_option = 0
	
	# Generate 3 random upgrade options
	current_options = generate_upgrade_options()
	
	# Display the options
	display_options()

func hide_upgrade_menu():
	visible = false
	get_tree().paused = false

func generate_upgrade_options() -> Array:
	var options = []
	
	# ALWAYS add magnet as first option (for testing)
	options.append({
		"type": "upgrade",
		"upgrade_key": "magnet",
		"name": "Magnet Level " + str(weapon_levels["magnet"] + 1),
		"description": "Increases gold pickup range by 30 pixels (Current level: " + str(weapon_levels["magnet"]) + ")"
	})
	
	# Build pool of all possible upgrades
	var upgrade_pool = []
	
	# Add weapon unlocks for locked weapons
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
			"name": "Pulse Damage +50%",
			"description": "Increases pulse weapon damage"
		})
		upgrade_pool.append({
			"type": "upgrade",
			"upgrade_key": "pulse_area",
			"name": "Pulse Area +30%",
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
	
	# Randomly select 2 more options (since magnet is always first)
	upgrade_pool.shuffle()
	var num_options = min(2, upgrade_pool.size())
	for i in range(num_options):
		options.append(upgrade_pool[i])
	
	print("[UPGRADE MENU] Generated ", num_options, " options")
	return options

func get_weapon_description(weapon_name: String) -> String:
	match weapon_name:
		"pulse":
			return "AoE damage around player"
		"orbital":
			return "Rotating satellites that options.size()ontact"
		"boomerang":
			return "Throws boomerangs that return"
		"lightning":
			return "Chain lightning between enemies"
		"grenade":
			return "Explosive projectiles"
	return "New weapon"

func display_options():
	# For now, print to console (UI will need to be updated in the scene)
	print("[UPGRADE MENU] Available options:")
	for i in range(current_options.size()):
		var opt = current_options[i]
		print("  [", i, "] ", opt["name"], " - ", opt["description"])

func apply_upgrade(option_index: int):
	if option_index < 0 or option_index >= current_options.size():
		return
	
	var option = current_options[option_index]
	
	# No gold check - upgrades are free now, just level up
	# Increment player level
	player.player_level += 1
	print("[UPGRADE MENU] Player leveled up to level ", player.player_level)
	
	total_upgrades += 1
	
	# Apply the upgrade
	if option["type"] == "unlock":
		player.unlock_weapon(option["weapon"])
	elif option["type"] == "upgrade":
		apply_weapon_upgrade(option["upgrade_key"])
	
	print("[UPGRADE] Applied: ", option["name"], " | New level: ", player.player_level)
	
	# Close menu
	await get_tree().create_timer(0.3).timeout
	hide_upgrade_menu()

func apply_weapon_upgrade(upgrade_key: String):
	weapon_levels[upgrade_key] += 1
	var level = weapon_levels[upgrade_key]
	
	match upgrade_key:
		"bullet_damage":
			if player.bullet_weapon:
				player.bullet_weapon.damage = int(player.bullet_weapon.damage * 1.5)
				print("Bullet damage: ", player.bullet_weapon.damage)
		"bullet_capacity":
			if player.bullet_weapon:
				player.bullet_weapon.max_bullets += 2
				player.bullet_weapon.current_bullets = player.bullet_weapon.max_bullets
				print("Bullet capacity: ", player.bullet_weapon.max_bullets)
		"pulse_damage":
			if player.pulse_weapon:
				player.pulse_weapon.damage = int(player.pulse_weapon.damage * 1.5)
				print("Pulse damage: ", player.pulse_weapon.damage)
		"pulse_area":
			if player.pulse_weapon:
				player.pulse_weapon.attack_range *= 1.3
				print("Pulse range: ", player.pulse_weapon.attack_range)
		"orbital_count":
			if player.orbital_weapon:
				player.orbital_weapon.upgrade_count()
		"orbital_damage":
			if player.orbital_weapon:
				player.orbital_weapon.upgrade_damage()
		"boomerang_count":
			if player.boomerang_weapon:
				player.boomerang_weapon.upgrade_count()
		"boomerang_damage":
			if player.boomerang_weapon:
				player.boomerang_weapon.upgrade_damage()
		"lightning_chains":
			if player.lightning_weapon:
				player.lightning_weapon.upgrade_chains()
		"lightning_damage":
			if player.lightning_weapon:
				player.lightning_weapon.upgrade_damage()
		"grenade_count":
			if player.grenade_weapon:
				player.grenade_weapon.upgrade_count()
		"grenade_damage":
			if player.grenade_weapon:
				player.grenade_weapon.upgrade_damage()
		"magnet":
			player.upgrade_magnet()
			print("Magnet level: ", player.magnet_level)

func _input(event):
	if not visible:
		return
	
	# Navigate with 1, 2, 3 keys or arrow keys
	if event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_1):
		selected_option = 0
		print("[SELECT] Option 0")
		get_viewport().set_input_as_handled()
	elif (event is InputEventKey and event.pressed and event.keycode == KEY_2):
		if current_options.size() > 1:
			selected_option = 1
			print("[SELECT] Option 1")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_3):
		if current_options.size() > 2:
			selected_option = 2
			print("[SELECT] Option 2")
		get_viewport().set_input_as_handled()
	
	# Confirm with Enter or Space
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		apply_upgrade(selected_option)
		get_viewport().set_input_as_handled()
