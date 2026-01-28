extends "res://scripts/weapons/weapon_base.gd"

var bullet_scene = preload("res://scenes/weapons/bullet.tscn")
var max_bullets = 6
var current_bullets = 6
var reload_time = 2.0
var is_reloading = false
var fire_delay = 0.1  # Time between each bullet

# Auto-attack timer
var auto_attack_timer: float = 0.0

# Frog Overload state
var frog_overload_active = false
var frog_overload_timer = 0.0
var frog_overload_duration = 30.0
var base_reload_time = 2.0
var frog_overload_upgrade_key = ""
var upgrade_menu_ref = null
var base_max_bullets = 6  # Store the original value
var base_damage = 10  # Store the original value

func _init():
	damage = 10
	cooldown = 0.1  # Quick fire rate
	attack_range = 500.0  # Bullets can go far
	base_reload_time = reload_time

func _process(delta: float) -> void:
	if not player:
		return
	
	# Handle Frog Overload timer
	if frog_overload_active:
		frog_overload_timer -= delta
		if frog_overload_timer <= 0:
			end_frog_overload()
	
	# Auto-attack timer
	auto_attack_timer += delta
	if auto_attack_timer >= cooldown and can_attack():
		attack()
		auto_attack_timer = 0.0

func attack():
	if not player or is_reloading:
		return
	
	# Skip reload check during Frog Overload
	if not frog_overload_active and current_bullets <= 0:
		# Start reload
		reload()
		return
	
	if not can_attack():
		return
	
	# Find closest enemy
	var closest_enemy = get_closest_enemy()
	
	if closest_enemy:
		# Spawn bullet
		var bullet = bullet_scene.instantiate()
		player.get_parent().add_child(bullet)
		bullet.global_position = player.global_position
		bullet.damage = damage
		bullet.player = player  # Pass player reference for crit damage
		
		# Increase bullet speed during Frog Overload
		if frog_overload_active:
			bullet.speed *= 2.0
		
		# Set direction towards enemy
		var direction = (closest_enemy.global_position - player.global_position).normalized()
		bullet.set_direction(direction)
	else:
		print("No enemies in range!")
	
	# Use up a bullet only if not in Frog Overload
	if not frog_overload_active:
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

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	print("[BULLET WEAPON] FROG OVERLOAD ACTIVATED!")
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	
	# Instant reload and cancel any ongoing reload
	is_reloading = false
	current_bullets = max_bullets
	
	print("[BULLET WEAPON] No reload + faster bullets for ", frog_overload_duration, " seconds!")

func end_frog_overload():
	print("[BULLET WEAPON] Frog Overload ended")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset the upgrade level after overload ends
	if upgrade_menu_ref and frog_overload_upgrade_key != "":
		print("[BULLET WEAPON] Resetting ", frog_overload_upgrade_key, " level from ", upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key], " to 0")
		upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key] = 0
		
		# Reset weapon stats to base values
		if frog_overload_upgrade_key == "bullet_capacity":
			max_bullets = base_max_bullets
			current_bullets = max_bullets
			print("[BULLET WEAPON] Reset max_bullets to base: ", base_max_bullets)
		elif frog_overload_upgrade_key == "bullet_damage":
			damage = base_damage
			print("[BULLET WEAPON] Reset damage to base: ", base_damage)
		
		frog_overload_upgrade_key = ""
		upgrade_menu_ref = null
