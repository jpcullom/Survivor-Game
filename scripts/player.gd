extends CharacterBody2D

# Player stats
var speed = 200
var base_speed = 200
var health = 100
var max_health = 100
var gold = 0
var attack_damage = 10
var attack_range = 100
var is_attacking = false
var invulnerable = false
var invulnerability_time = 1.0  # Seconds of invulnerability after taking damage

# Dodge roll stats
var is_dodging = false
var dodge_speed_multiplier = 2.5
var dodge_duration = 0.4  # Seconds
var dodge_cooldown = 2.0  # Seconds between dodge rolls
var can_dodge = true

# Weapon system
var pulse_weapon = null
var bullet_weapon = null
var current_weapon = null
var weapon_index = 0  # 0 = pulse, 1 = bullet

# Load weapon scripts at runtime (adjust paths if your weapon scripts are in a different folder)
# Use load() instead of preload() so missing files don't error out at script parse time.
var PulseWeapon = load("res://scripts/pulse_weapon.gd")
var BulletWeapon = load("res://scripts/bullet_weapon.gd")
func _ready():
	print("Player initialized at position: ", position)
	set_physics_process(true)
	
	# Initialize weapons (guard against missing scripts)
	if PulseWeapon:
		pulse_weapon = PulseWeapon.new()
		pulse_weapon.player = self
		add_child(pulse_weapon)
	else:
		print("ERROR: Could not load PulseWeapon script at 'res://scripts/pulse_weapon.gd' - pulse_weapon will be unavailable")
	
	if BulletWeapon:
		bullet_weapon = BulletWeapon.new()
		bullet_weapon.player = self
		add_child(bullet_weapon)
	else:
		print("ERROR: Could not load BulletWeapon script at 'res://scripts/bullet_weapon.gd' - bullet_weapon will be unavailable")
	
	# Start with pulse weapon if available, otherwise fall back to bullet or none
	if pulse_weapon:
		current_weapon = pulse_weapon
		weapon_index = 0
		print("Pulse weapon equipped")
	elif bullet_weapon:
		current_weapon = bullet_weapon
		weapon_index = 1
		print("Bullet weapon equipped (pulse missing)")
	else:
		current_weapon = null
		print("No weapons available")
	print("Pulse weapon equipped")

# Movement logic
func _physics_process(delta):
	# Get movement input
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize diagonal movement so it's not faster
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()
	
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
	
	# Get references to HUD and Game Over screen
	var hud = get_tree().get_first_node_in_group("hud")
	var game_over = get_node("/root/Main/GameOver")
	
	if hud and game_over:
		# Show game over screen with final score
		game_over.show_game_over(hud.score)
	
	# Hide the player instead of deleting them immediately
	visible = false
	set_physics_process(false)

# Function to add gold
func add_gold(amount):
	gold += amount
	print("Picked up ", amount, " gold! Total: ", gold)
	
	# Update HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_gold"):
		hud.update_gold(gold)
	
	# Check if player has enough gold for upgrade (25 gold)
	if gold >= 25:
		print("Player has 25+ gold! Trying to show upgrade menu...")
		var upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
		print("  upgrade_menu found: ", upgrade_menu)
		if upgrade_menu:
			print("  Has show_upgrade_menu method: ", upgrade_menu.has_method("show_upgrade_menu"))
			if upgrade_menu.has_method("show_upgrade_menu"):
				print("  Calling show_upgrade_menu()!")
				upgrade_menu.show_upgrade_menu()
			else:
				print("  ERROR: upgrade_menu doesn't have show_upgrade_menu method!")
		else:
			print("  ERROR: Could not find upgrade menu in 'upgrade_menu' group")
