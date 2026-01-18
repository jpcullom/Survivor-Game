extends CharacterBody2D

class_name Enemy

signal enemy_died(score_value)

# Enemy type enum
enum EnemyType { COYOTE, TOAD, VULTURE }

# Enemy configuration
var enemy_type: EnemyType = EnemyType.COYOTE

var health: int = 20
var max_health: int = 20
var speed: float = 80.0
var damage: int = 10
var attack_range: float = 50.0
var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0
var score_value: int = 100
var player = null
var health_bar = null

# Sprite references
@onready var sprite = $Sprite2D
var right_texture = null
var left_texture = null
var last_horizontal_direction = 1  # 1 = right, -1 = left
var sprite_flip_cooldown: float = 0.0
var min_flip_interval: float = 0.2  # Minimum time between sprite flips

# Performance optimization variables
var update_interval = 0.0
var lod_update_rate = 0.1  # Update LOD less frequently (every 0.1s)
var is_near_player = true
var separation_check_limit = 3  # Only check nearest 3 enemies for separation
var max_enemies_for_separation = 80  # Disable separation above this enemy count

# AI/Pathfinding variables
var target_angle: float = 0.0  # Preferred angle around player
var angle_update_timer: float = 0.0
var angle_update_rate: float = 0.5  # Update target angle every 0.5 seconds
var surround_distance: float = 100.0  # Preferred distance to maintain from player
var obstacle_detection_radius: float = 60.0  # How far to look for obstacles

# Preload health bar scene and gold pickup
var health_bar_scene = preload("res://scenes/ui/health_bar.tscn")
var gold_pickup_scene = preload("res://scenes/items/gold_pickup.tscn")

func _ready():
	# Add to enemies group for easy player detection
	add_to_group("enemies")
	
	# Note: initialize_enemy_type() is called by spawner after setting enemy_type
	# Create and add health bar
	health_bar = health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.update_health(health, max_health)
	
	# Find the player
	await get_tree().process_frame  # Wait one frame for everything to be ready
	player = get_tree().get_first_node_in_group("player")
	
	# Initialize with a random target angle around the player
	target_angle = randf() * TAU  # TAU = 2*PI (full circle in radians)
	
	if not player:
		print("Warning: Enemy couldn't find player!")

# Initialize enemy stats based on type
func initialize_enemy_type() -> void:
	match enemy_type:
		EnemyType.COYOTE:
			# Coyote - Default balanced enemy
			health = 20
			max_health = 20
			speed = 80.0
			damage = 10
			attack_range = 50.0
			attack_cooldown = 1.0
			score_value = 100
			right_texture = load("res://sprites/CoyoteRight.png")
			left_texture = load("res://sprites/CoyoteLeft.png")
			
		EnemyType.TOAD:
			# Toad - Tanky, high damage, rare enemy
			health = 100
			max_health = 100
			speed = 60.0  # Slower than Coyote
			damage = 20  # Much more damage
			attack_range = 50.0
			attack_cooldown = 1.2
			score_value = 500  # Worth more points
			right_texture = load("res://sprites/ToadRight.png")
			left_texture = load("res://sprites/ToadLeft.png")
			scale = Vector2(2.5, 2.5)  # Make Toad much bigger
			
		EnemyType.VULTURE:
			# Vulture - Fast, dangerous, rare enemy
			health = 40
			max_health = 80
			speed = 120.0  # Much faster than Coyote
			damage = 15
			attack_range = 50.0
			attack_cooldown = 1.0
			score_value = 200  # Worth more than Coyote
			right_texture = load("res://sprites/VultureRight.png")
			left_texture = load("res://sprites/VultureLeft.png")

func _physics_process(_delta: float) -> void:
	if not player:
		# Try to find player again
		player = get_tree().get_first_node_in_group("player")
		return
	
	# Update LOD check periodically instead of every frame
	update_interval += _delta
	if update_interval >= lod_update_rate:
		var distance_to_player = global_position.distance_to(player.global_position)
		is_near_player = distance_to_player < 800.0  # Within ~1.5 screens
		update_interval = 0.0
		
		# Despawn if too far from player (helps with performance)
		if distance_to_player > 2000.0:
			queue_free()
			return
	
	# Get current distance and direction to player
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Update target angle periodically to find best position
	angle_update_timer += _delta
	if angle_update_timer >= angle_update_rate:
		target_angle = update_target_angle(distance_to_player)
		angle_update_timer = 0.0
	
	# Calculate ideal surrounding position
	var target_position = player.global_position + Vector2(
		cos(target_angle) * surround_distance,
		sin(target_angle) * surround_distance
	)
	
	# Get direction to target surrounding position
	var direction_to_target = (target_position - global_position).normalized()
	
	# If far from player, move directly toward them; if close, move to surrounding position
	var direction: Vector2
	if distance_to_player > surround_distance * 2.0:
		# Far away - move directly toward player
		direction = direction_to_player
	elif distance_to_player < attack_range * 2.0:
		# Close to attack range - move directly toward player
		direction = direction_to_player
	else:
		# In surrounding range - move to target position
		direction = direction_to_target
	
	# Apply obstacle avoidance
	var avoidance = get_avoidance_force()
	direction = (direction + avoidance).normalized()
	
	velocity = direction * speed
	
	# Only apply separation force if near player AND enemy count is reasonable
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if is_near_player and enemy_count < max_enemies_for_separation:
		var separation = get_separation_force()
		velocity += separation
	
	move_and_slide()
	
	# Update sprite flip cooldown
	sprite_flip_cooldown -= _delta
	
	# Update sprite direction based on movement (with dampening)
	if abs(direction.x) > 0.3 and sprite_flip_cooldown <= 0.0:
		var new_direction = sign(direction.x)
		if new_direction != last_horizontal_direction:
			last_horizontal_direction = new_direction
			sprite_flip_cooldown = min_flip_interval
	
	# Change sprite based on direction
	if sprite and right_texture and left_texture:
		if last_horizontal_direction > 0:
			sprite.texture = right_texture
		else:
			sprite.texture = left_texture
	
	# Check if we're close enough to attack (recalculate distance after movement)
	var final_distance = global_position.distance_to(player.global_position)
	if final_distance <= attack_range:
		attempt_attack()

# Update the target angle to find the best surrounding position
func update_target_angle(distance_to_player: float) -> float:
	# Find the current angle from player to this enemy
	var current_angle = (global_position - player.global_position).angle()
	
	# Check nearby enemies to find gaps in the surrounding circle
	var enemies = get_tree().get_nodes_in_group("enemies")
	var occupied_angles = []
	
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		
		var enemy_distance = enemy.global_position.distance_to(player.global_position)
		# Only consider enemies in similar distance range
		if abs(enemy_distance - distance_to_player) < 150.0:
			var angle = (enemy.global_position - player.global_position).angle()
			occupied_angles.append(angle)
		
		# Limit checks for performance
		if occupied_angles.size() >= 12:
			break
	
	# If we're already in a good spot (not too close to others), keep current angle
	var min_angle_diff = TAU  # Full circle
	for angle in occupied_angles:
		var diff = abs(angle_difference(current_angle, angle))
		if diff < min_angle_diff:
			min_angle_diff = diff
	
	# If we have enough space, stay where we are
	if min_angle_diff > 0.5:  # About 30 degrees
		return current_angle
	
	# Otherwise, find the largest gap
	if occupied_angles.size() > 0:
		occupied_angles.sort()
		var largest_gap = 0.0
		var best_angle = current_angle
		
		for i in range(occupied_angles.size()):
			var angle1 = occupied_angles[i]
			var angle2 = occupied_angles[(i + 1) % occupied_angles.size()]
			var gap = angle_difference(angle1, angle2)
			
			if gap > largest_gap:
				largest_gap = gap
				# Aim for the middle of the gap
				best_angle = angle1 + gap * 0.5
		
		return best_angle
	
	return current_angle

# Get avoidance force to navigate around blocking enemies
func get_avoidance_force() -> Vector2:
	var avoidance_force = Vector2.ZERO
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	# Look ahead in our movement direction
	var look_ahead_distance = obstacle_detection_radius
	var my_direction = velocity.normalized() if velocity.length() > 0 else Vector2.ZERO
	
	if my_direction.length() == 0:
		return Vector2.ZERO
	
	var checks_made = 0
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		
		checks_made += 1
		var to_enemy = enemy.global_position - global_position
		var distance = to_enemy.length()
		
		# Check if enemy is in our path
		if distance < look_ahead_distance:
			var to_enemy_normalized = to_enemy.normalized()
			var dot = my_direction.dot(to_enemy_normalized)
			
			# If enemy is ahead of us (positive dot product)
			if dot > 0.3:
				# Steer perpendicular to avoid
				var perpendicular = Vector2(-my_direction.y, my_direction.x)
				var side = sign(perpendicular.dot(to_enemy_normalized))
				
				# Steer away from the obstacle
				var avoidance_strength = 1.0 - (distance / look_ahead_distance)
				avoidance_force -= side * perpendicular * avoidance_strength
		
		# Limit checks for performance
		if checks_made >= 8:
			break
	
	return avoidance_force

func get_separation_force() -> Vector2:
	# Push away from nearby enemies to prevent overlap
	var separation_force = Vector2.ZERO
	var separation_radius = 40.0  # How close before pushing away
	var separation_strength = 50.0  # How strong the push is
	
	# Get all enemies and find nearby ones
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearby_enemies = []
	
	# First pass: find enemies within separation radius
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < separation_radius and distance > 0:
			nearby_enemies.append({"enemy": enemy, "distance": distance})
			
			# Early exit if we have enough nearby enemies to check
			if nearby_enemies.size() >= separation_check_limit:
				break
	
	# Second pass: calculate separation force only for nearby enemies
	for data in nearby_enemies:
		var enemy = data["enemy"]
		var distance = data["distance"]
		
		# Push away from this enemy
		var push_direction = (global_position - enemy.global_position).normalized()
		var push_strength = (separation_radius - distance) / separation_radius
		separation_force += push_direction * separation_strength * push_strength
	
	return separation_force

func attempt_attack() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time >= attack_cooldown:
		attack_player()
		last_attack_time = current_time

func attack_player() -> void:
	if player and player.has_method("take_damage"):
		player.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	
	# Update health bar
	if health_bar:
		health_bar.update_health(health, max_health)
	
	# Visual feedback - flash white
	modulate = Color(2, 2, 2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func die() -> void:
	enemy_died.emit(score_value)
	
	# Drop gold at enemy position
	var gold = gold_pickup_scene.instantiate()
	get_parent().add_child(gold)
	gold.global_position = global_position
	
	queue_free()
