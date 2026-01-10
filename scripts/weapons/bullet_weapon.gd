extends "res://scripts/weapons/weapon_base.gd"

var bullet_scene = preload("res://scenes/weapons/bullet.tscn")
var max_bullets = 6
var current_bullets = 6
var reload_time = 2.0
var is_reloading = false
var fire_delay = 0.1  # Time between each bullet

func _init():
	damage = 10
	cooldown = 0.1  # Quick fire rate
	attack_range = 500.0  # Bullets can go far

func attack():
	if not player or is_reloading:
		return
	
	if current_bullets <= 0:
		# Start reload
		reload()
		return
	
	if not can_attack():
		return
	
	print("Bullet fired! (", current_bullets, "/", max_bullets, " remaining)")
	
	# Find closest enemy
	var closest_enemy = get_closest_enemy()
	
	if closest_enemy:
		# Spawn bullet
		var bullet = bullet_scene.instantiate()
		player.get_parent().add_child(bullet)
		bullet.global_position = player.global_position
		bullet.damage = damage
		
		# Set direction towards enemy
		var direction = (closest_enemy.global_position - player.global_position).normalized()
		bullet.set_direction(direction)
	else:
		print("No enemies in range!")
	
	# Use up a bullet
	current_bullets -= 1
	
	# Start cooldown between shots
	start_cooldown()

func get_closest_enemy():
	var enemies = player.get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	
	var closest = null
	var closest_distance = INF
	var equidistant_enemies = []
	
	for enemy in enemies:
		var distance = player.global_position.distance_to(enemy.global_position)
		
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy
			equidistant_enemies = [enemy]
		elif abs(distance - closest_distance) < 0.1:  # Nearly equal distance
			equidistant_enemies.append(enemy)
	
	# If multiple enemies at same distance, pick random
	if equidistant_enemies.size() > 1:
		return equidistant_enemies[randi() % equidistant_enemies.size()]
	
	return closest

func reload():
	if is_reloading:
		return
	
	print("Reloading...")
	is_reloading = true
	await player.get_tree().create_timer(reload_time).timeout
	current_bullets = max_bullets
	is_reloading = false
	print("Reload complete!")
