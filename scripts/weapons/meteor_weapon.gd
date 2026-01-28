extends Node2D

class_name MeteorWeapon

var damage: int = 40
var cooldown: float = 3.0
var meteor_count: int = 1
var player = null

var meteor_scene = preload("res://scenes/weapons/meteor.tscn")
var auto_attack_timer: float = 0.0

# Frog Overload state
var frog_overload_active: bool = false
var frog_overload_timer: float = 0.0
var frog_overload_duration: float = 30.0
var frog_overload_upgrade_key: String = ""
var upgrade_menu_ref = null
var base_damage: int = 40
var base_meteor_count: int = 1

func _process(delta: float) -> void:
	auto_attack_timer += delta
	
	if auto_attack_timer >= cooldown and can_attack():
		attack()
		auto_attack_timer = 0.0
	
	# Frog Overload timer
	if frog_overload_active:
		frog_overload_timer -= delta
		if frog_overload_timer <= 0:
			end_frog_overload()

func can_attack() -> bool:
	if not player or not is_instance_valid(player):
		return false
	
	# Check if there are any enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			return true
	
	return false

func attack():
	if not player:
		return
	
	# Calculate effective meteor count (boosted during Frog Overload)
	var effective_count = meteor_count
	if frog_overload_active:
		effective_count += 10
	
	print("[MeteorWeapon] Summoning ", effective_count, " meteor(s)!")
	
	# Get all valid enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	var valid_enemies = []
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			valid_enemies.append(enemy)
	
	if valid_enemies.is_empty():
		return
	
	# Launch meteors at random enemies
	for i in range(effective_count):
		var target_enemy = valid_enemies[randi() % valid_enemies.size()]
		spawn_meteor(target_enemy)

func spawn_meteor(target_enemy):
	var meteor = meteor_scene.instantiate()
	meteor.damage = damage
	meteor.player = player  # Pass player reference for crit damage
	meteor.target_position = target_enemy.global_position
	
	# Calculate spawn position at 45-degree angle from top of screen
	var viewport_rect = get_viewport_rect()
	var camera = get_viewport().get_camera_2d()
	
	var screen_center = Vector2.ZERO
	if camera:
		screen_center = camera.global_position
	
	# Position above and to the side of the target at 45-degree angle
	var offset_distance = 400.0  # Distance from target
	var angle = -PI / 4  # -45 degrees (top-right direction)
	
	# Alternate between top-left and top-right for variety
	if randi() % 2 == 0:
		angle = -3 * PI / 4  # -135 degrees (top-left direction)
	
	var spawn_offset = Vector2(cos(angle), sin(angle)) * offset_distance
	meteor.global_position = target_enemy.global_position + spawn_offset
	
	player.get_parent().call_deferred("add_child", meteor)

func upgrade_damage():
	damage = int(damage * 1.5)
	print("[MeteorWeapon] Meteor damage upgraded to: ", damage)

func upgrade_cooldown():
	cooldown = max(0.5, cooldown - 0.3)
	print("[MeteorWeapon] Meteor cooldown reduced to: ", cooldown)

func upgrade_count():
	meteor_count += 1
	print("[MeteorWeapon] Meteor count upgraded to: ", meteor_count)

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	print("[MeteorWeapon] FROG OVERLOAD ACTIVATED! +10 meteors for ", frog_overload_duration, " seconds!")

func end_frog_overload():
	print("[MeteorWeapon] Frog Overload ended! Resetting weapon level...")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset the upgrade level to 0 in the upgrade menu
	if upgrade_menu_ref and upgrade_menu_ref.has_method("reset_weapon_level"):
		upgrade_menu_ref.reset_weapon_level(frog_overload_upgrade_key)
	
	# Reset stats based on which upgrade triggered overload
	match frog_overload_upgrade_key:
		"meteor_count":
			meteor_count = base_meteor_count
			print("[MeteorWeapon] Reset meteor_count to base: ", meteor_count)
		"meteor_damage":
			damage = base_damage
			print("[MeteorWeapon] Reset damage to base: ", damage)
		"meteor_cooldown":
			# Cooldown resets to initial cooldown - no base tracking needed since it always decreases
			cooldown = 3.0
			print("[MeteorWeapon] Reset cooldown to base: ", cooldown)
	
	frog_overload_upgrade_key = ""
