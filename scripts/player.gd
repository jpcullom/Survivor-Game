extends CharacterBody2D

# Player stats
var speed = 200
var health = 100
var max_health = 100
var attack_damage = 10
var attack_range = 100
var is_attacking = false
var invulnerable = false
var invulnerability_time = 1.0  # Seconds of invulnerability after taking damage

# Preload attack pulse effect
var attack_pulse_scene = preload("res://scenes/weapons/attack_pulse.tscn")

func _ready():
	print("Player initialized at position: ", position)
	set_physics_process(true)

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
	
	# Check for collisions with enemies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if we collided with an enemy
		if collider and collider.is_in_group("enemies"):
			if not invulnerable:
				take_damage(collider.damage if "damage" in collider else 10)

func _input(event):
	# Attack on spacebar
	if event.is_action_pressed("ui_accept") and not is_attacking:
		is_attacking = true
		attack()

# Attack function - damages nearby enemies
func attack():
	print("Player attacking!")
	
	# Spawn visual attack pulse effect
	var pulse = attack_pulse_scene.instantiate()
	get_parent().add_child(pulse)
	pulse.global_position = global_position
	pulse.set_attack_range(attack_range)
	
	# Get all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Check if enemy is in attack range
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range:
			print("Hit enemy at distance: ", distance)
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)
	
	# Attack cooldown
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

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
	# TODO: Add game over screen
	queue_free()
