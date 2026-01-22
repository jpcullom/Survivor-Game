extends CharacterBody2D

# Player stats
var speed = 200
var base_speed = 200
var health = 100
var max_health = 100
var gold = 0
var player_level = 1  # Player level for upgrade progression
var last_upgrade_threshold = 0  # Track which threshold we last showed the menu at
var attack_damage = 10
var attack_range = 100
var is_attacking = false
var invulnerable = false
var invulnerability_time = 1.0  # Seconds of invulnerability after taking damage

# Pickup range (affected by magnet)
var pickup_range = 50.0
var base_pickup_range = 50.0

# Dodge roll stats
var is_dodging = false
var dodge_speed_multiplier = 2.5
var dodge_duration = 0.4  # Seconds
var dodge_cooldown = 2.0  # Seconds between dodge rolls
var can_dodge = true

# Weapon system
var pulse_weapon = null
var bullet_weapon = null
var orbital_weapon = null
var boomerang_weapon = null
var lightning_weapon = null
var grenade_weapon = null
var meteor_weapon = null
var current_weapon = null
var weapon_index = 0  # 0 = pulse, 1 = bullet

# Weapon unlock tracking
var unlocked_weapons = {
	"bullet": true,     # Start with bullet
	"pulse": false,
	"orbital": false,
	"boomerang": false,
	"lightning": false,
	"grenade": false,
	"meteor": false
}

# Passive items
var magnet_level = 0
var speed_boost_level = 0
var crown_level = 0
var gold_value_multiplier = 1.0

# Load weapon scripts at runtime (adjust paths if your weapon scripts are in a different folder)
# Use load() instead of preload() so missing files don't error out at script parse time.
var PulseWeapon = load("res://scripts/weapons/pulse_weapon.gd")
var BulletWeapon = load("res://scripts/weapons/bullet_weapon.gd")
var OrbitalWeapon = load("res://scripts/weapons/orbital_weapon.gd")
var BoomerangWeapon = load("res://scripts/weapons/boomerang_weapon.gd")
var LightningWeapon = load("res://scripts/weapons/lightning_weapon.gd")
var GrenadeWeapon = load("res://scripts/weapons/grenade_weapon.gd")
var MeteorWeapon = load("res://scripts/weapons/meteor_weapon.gd")

# Sprite references
@onready var sprite = $Sprite2D
var frog_right_texture = null
var frog_left_texture = null
var last_horizontal_direction = 1  # 1 = right, -1 = left

func _ready():
	print("Player initialized at position: ", position)
	set_physics_process(true)
	
	# Apply permanent skill tree bonuses
	apply_skill_tree_bonuses()
	
	# Load frog textures
	frog_right_texture = load("res://sprites/FrogRight.png")
	frog_left_texture = load("res://sprites/FrogLeft.png")
	
	# Initialize only unlocked weapons - start with just bullet
	if BulletWeapon and unlocked_weapons["bullet"]:
		bullet_weapon = BulletWeapon.new()
		bullet_weapon.player = self
		add_child(bullet_weapon)
		current_weapon = bullet_weapon
		print("Starting with Bullet weapon")

# Movement logic
func _physics_process(_delta):
	# Get movement input
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize diagonal movement so it's not faster
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()
	
	# Update sprite direction based on movement
	if input_vector.x != 0:
		last_horizontal_direction = sign(input_vector.x)
	
	# Change sprite based on direction
	if sprite and frog_right_texture and frog_left_texture:
		if last_horizontal_direction > 0:
			sprite.texture = frog_right_texture
		else:
			sprite.texture = frog_left_texture
	
	# Check for collisions with enemies (but not during dodge roll)
	if not is_dodging:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Check if we collided with an enemy
			if collider and collider.is_in_group("enemies"):
				if not invulnerable:
					take_damage(collider.damage if "damage" in collider else 10)

func _input(event):
	# Attack on spacebar
	if event.is_action_pressed("ui_accept"):
		if current_weapon:
			current_weapon.attack()
	
	# Dodge roll on Shift key
	if event.is_action_pressed("ui_shift") and can_dodge and not is_dodging:
		dodge_roll()
	
	# Weapon switching with 1 and 2 keys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			switch_weapon(0)  # Pulse weapon
		elif event.keycode == KEY_2:
			switch_weapon(1)  # Bullet weapon

# Weapon switching function
func switch_weapon(index: int):
	if index == 0 and current_weapon != pulse_weapon:
		current_weapon = pulse_weapon
		weapon_index = 0
		print("Switched to Pulse Weapon")
	elif index == 1 and current_weapon != bullet_weapon:
		current_weapon = bullet_weapon
		weapon_index = 1
		print("Switched to Bullet Weapon")

# Dodge roll function
func dodge_roll():
	print("Player dodge rolling!")
	is_dodging = true
	can_dodge = false
	invulnerable = true
	
	# Disable collision shape entirely - become a ghost!
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	# Boost speed
	speed = base_speed * dodge_speed_multiplier
	
	# Visual feedback - flash blue/cyan during dodge
	modulate = Color(0.5, 0.8, 1.0)  # Cyan tint
	
	# Dodge duration
	await get_tree().create_timer(dodge_duration).timeout
	
	# End dodge
	is_dodging = false
	speed = base_speed
	modulate = Color(1, 1, 1)  # Back to normal
	
	# Re-enable collision shape
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	
	# Only remove invulnerability if we're not already invulnerable from taking damage
	if invulnerable and is_dodging == false:
		invulnerable = false
	
	# Cooldown before next dodge
	await get_tree().create_timer(dodge_cooldown).timeout
	can_dodge = true
	print("Dodge roll ready!")

# Function to take damage
func take_damage(amount):
	if invulnerable:
		return
	
	health -= amount
	print("Player took ", amount, " damage! Health: ", health, "/", max_health)
	
	# Start invulnerability period
	invulnerable = true
	
	# Visual feedback - flash the player
	modulate = Color(1, 0.5, 0.5)  # Red tint
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Back to normal
	
	await get_tree().create_timer(invulnerability_time - 0.1).timeout
	invulnerable = false
	
	if health <= 0:
		die()

# Function to handle player death
func die():
	print("Player has died!")
	
	# Get references to HUD, Game Over screen, and GameManager
	var hud = get_tree().get_first_node_in_group("hud")
	var game_over = get_node("/root/Main/GameOver")
	var game_manager = GameManager
	
	if hud and game_over:
		# Update GameManager with final score and save high score
		if game_manager:
			game_manager.score = hud.score
			game_manager.end_game()
		
		# Show game over screen with final score
		game_over.show_game_over(hud.score)
	
	# Hide the player instead of deleting them immediately
	visible = false
	set_physics_process(false)

# Function to add gold
func add_gold(amount):
	# Apply crown bonus (flat amount based on level)
	var crown_bonus = 0
	for i in range(1, crown_level + 1):
		crown_bonus += i * 5
	var actual_amount = amount + crown_bonus
	gold += actual_amount
	if crown_level > 0:
		print("Picked up ", amount, " gold (+", crown_bonus, " crown bonus = ", actual_amount, ")! Total: ", gold)
	else:
		print("Picked up ", amount, " gold! Total: ", gold)
	
	# Update HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(gold)
	
	# Check if we can afford an upgrade
	check_upgrade_threshold()

# Function to add gems (permanent currency)
func add_gems(amount):
	# Update local gem count
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.gems += amount
		print("Picked up ", amount, " gem(s)! Total this run: ", hud.gems)
	
	# Update GameManager's permanent gem count
	var game_manager = GameManager
	if game_manager:
		game_manager.gems += amount
		print("Total gems across all runs: ", game_manager.gems)

# Check if player has enough gold to trigger upgrade menu
func check_upgrade_threshold():
	# Check if player has reached the next upgrade threshold
	var upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	if upgrade_menu and upgrade_menu.has_method("calculate_next_threshold"):
		var next_threshold = upgrade_menu.calculate_next_threshold()
		
		# Debug logging
		if gold % 50 == 0:  # Log every 50 gold
			print("[THRESHOLD CHECK] Gold: ", gold, " | Next: ", next_threshold, " | Last: ", last_upgrade_threshold, " | Level: ", player_level)
		
		# Only show menu if we've reached a new threshold
		if gold >= next_threshold and next_threshold > last_upgrade_threshold:
			print("[PLAYER] Reached upgrade threshold! Gold: ", gold, ", Threshold: ", next_threshold)
			last_upgrade_threshold = next_threshold
			upgrade_menu.show_upgrade_menu()

# Apply permanent skill tree bonuses from unlocked skills
func apply_skill_tree_bonuses():
	var game_manager = GameManager
	if not game_manager:
		return
	
	# Load skill tree
	var skill_tree = load("res://scripts/skill_tree.gd").new()
	skill_tree._initialize_skill_tree()
	
	# Get all bonuses from unlocked skills
	var bonuses = skill_tree.get_total_bonuses(game_manager.unlocked_skills)
	
	if bonuses.size() > 0:
		print("[Player] Applying skill tree bonuses: ", bonuses)
	
	# Apply stat bonuses
	if bonuses.has("max_health"):
		max_health += int(bonuses["max_health"])
		health = max_health  # Start with full health
	
	if bonuses.has("move_speed"):
		var speed_bonus = bonuses["move_speed"]
		base_speed = int(base_speed * (1.0 + speed_bonus))
		speed = base_speed
	
	if bonuses.has("damage_multiplier"):
		var damage_bonus = bonuses["damage_multiplier"]
		attack_damage = int(attack_damage * (1.0 + damage_bonus))
	
	if bonuses.has("pickup_range"):
		base_pickup_range += bonuses["pickup_range"]
		pickup_range = base_pickup_range
	
	if bonuses.has("starting_gold"):
		gold += int(bonuses["starting_gold"])
		print("[Player] Starting with ", gold, " bonus gold!")
	
	if bonuses.has("attack_speed"):
		# This would affect weapon cooldowns - we'll implement later
		pass
	
	if bonuses.has("extra_lives"):
		# Extra lives system - implement later
		pass
	
	if bonuses.has("max_weapon_slots"):
		# Increase max weapon slots - would need to update HUD
		pass
	
	if bonuses.has("exp_multiplier"):
		# XP bonus - implement later
		pass
	
	if bonuses.has("critical_chance"):
		# Crit system - implement later
		pass
	
	# Check if player has reached the next upgrade threshold
	var upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	if upgrade_menu and upgrade_menu.has_method("calculate_next_threshold"):
		var next_threshold = upgrade_menu.calculate_next_threshold()
		print("  Current gold: ", gold, ", Next threshold: ", next_threshold, ", Last threshold: ", last_upgrade_threshold)
		
		# Only show menu if we've reached a new threshold
		if gold >= next_threshold and next_threshold > last_upgrade_threshold:
			print("  Reached new upgrade threshold! Showing menu...")
			last_upgrade_threshold = next_threshold
			upgrade_menu.show_upgrade_menu()

# Function to unlock a weapon
func upgrade_magnet():
	magnet_level += 1
	# Each level increases pickup range by 30 pixels
	pickup_range = base_pickup_range + (magnet_level * 30.0)
	print("[PLAYER] Magnet upgraded to level ", magnet_level, ", pickup range: ", pickup_range)

func upgrade_speed_boost():
	speed_boost_level += 1
	# Each level increases speed by 25%
	speed = base_speed * (1 + speed_boost_level * 0.25)
	print("[PLAYER] Speed boost upgraded to level ", speed_boost_level, ", speed: ", speed)

func upgrade_crown():
	crown_level += 1
	# Each level adds (level * 5) to gold value
	# Level 1: +5, Level 2: +10, Level 3: +15, etc.
	var total_bonus = 0
	for i in range(1, crown_level + 1):
		total_bonus += i * 5
	gold_value_multiplier = 1.0 + (total_bonus / 5.0)  # Convert to multiplier for the calculation
	print("[PLAYER] Crown upgraded to level ", crown_level, ", bonus gold per pickup: +", crown_level * 5)

func unlock_weapon(weapon_name: String):
	if not unlocked_weapons.has(weapon_name) or unlocked_weapons[weapon_name]:
		return  # Already unlocked or invalid weapon
	
	print("[UNLOCK] Unlocking weapon: ", weapon_name)
	unlocked_weapons[weapon_name] = true
	
	# Instantiate the weapon
	match weapon_name:
		"pulse":
			if PulseWeapon and not pulse_weapon:
				pulse_weapon = PulseWeapon.new()
				pulse_weapon.player = self
				add_child(pulse_weapon)
				print("Pulse weapon equipped!")
		"orbital":
			if OrbitalWeapon and not orbital_weapon:
				orbital_weapon = OrbitalWeapon.new()
				orbital_weapon.player = self
				add_child(orbital_weapon)
				orbital_weapon.spawn_orbitals()
				print("Orbital weapon equipped with ", orbital_weapon.orbital_count, " orbitals!")
		"boomerang":
			if BoomerangWeapon and not boomerang_weapon:
				boomerang_weapon = BoomerangWeapon.new()
				boomerang_weapon.player = self
				add_child(boomerang_weapon)
				print("Boomerang weapon equipped!")
		"lightning":
			if LightningWeapon and not lightning_weapon:
				lightning_weapon = LightningWeapon.new()
				lightning_weapon.player = self
				add_child(lightning_weapon)
				print("Lightning weapon equipped!")
		"grenade":
			if GrenadeWeapon and not grenade_weapon:
				grenade_weapon = GrenadeWeapon.new()
				grenade_weapon.player = self
				add_child(grenade_weapon)
				print("Grenade weapon equipped!")
		"meteor":
			if MeteorWeapon and not meteor_weapon:
				meteor_weapon = MeteorWeapon.new()
				meteor_weapon.player = self
				add_child(meteor_weapon)
				print("Meteor weapon equipped!")
