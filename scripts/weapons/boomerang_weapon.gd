extends Node2D

class_name BoomerangWeapon

var damage: int = 20
var cooldown: float = 1.5
var max_distance: float = 200.0
var speed: float = 300.0
var boomerang_count: int = 1
var player = null

var boomerang_scene = preload("res://scenes/weapons/boomerang.tscn")
var auto_attack_timer: float = 0.0
var current_angle: float = 0.0  # For spreading multiple boomerangs

# Frog Overload state
var frog_overload_active = false
var frog_overload_timer = 0.0
var frog_overload_duration = 30.0
var frog_overload_upgrade_key = ""
var upgrade_menu_ref = null
var base_damage = 20
var base_boomerang_count = 1

func _process(delta: float) -> void:
	auto_attack_timer += delta
	
	# Handle Frog Overload timer
	if frog_overload_active:
		frog_overload_timer -= delta
		if frog_overload_timer <= 0:
			end_frog_overload()
	
	if auto_attack_timer >= cooldown and can_attack():
		attack()
		auto_attack_timer = 0.0

func can_attack() -> bool:
	return player != null and is_instance_valid(player)

func attack():
	if not player:
		return
	
	print("[BoomerangWeapon] Throwing ", boomerang_count, " boomerang(s)!")
	
	# Spread boomerangs evenly in different directions
	var angle_step = TAU / boomerang_count
	
	for i in range(boomerang_count):
		var boomerang = boomerang_scene.instantiate()
		boomerang.player = player
		boomerang.damage = damage
		boomerang.speed = speed
		boomerang.max_distance = max_distance
		boomerang.global_position = player.global_position
		
		# Apply Frog Overload size increase
		if frog_overload_active:
			boomerang.frog_overload_scale = 5.0
		
		# Calculate direction for this boomerang
		var throw_angle = current_angle + (i * angle_step)
		var throw_direction = Vector2(cos(throw_angle), sin(throw_angle))
		boomerang.set_direction(throw_direction)
		
		player.get_parent().call_deferred("add_child", boomerang)
	
	# Rotate angle for next throw to create a spinning pattern
	current_angle += angle_step * 0.5

func upgrade_count():
	boomerang_count += 1
	print("[BoomerangWeapon] Boomerang count upgraded to: ", boomerang_count)

func upgrade_damage():
	damage = int(damage * 1.5)
	print("[BoomerangWeapon] Boomerang damage upgraded to: ", damage)

func upgrade_range():
	max_distance += 50
	print("[BoomerangWeapon] Boomerang range upgraded to: ", max_distance)

func upgrade_speed():
	speed += 50
	cooldown = max(0.5, cooldown - 0.1)  # Also reduce cooldown slightly
	print("[BoomerangWeapon] Boomerang speed upgraded to: ", speed, " cooldown: ", cooldown)

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	print("[BOOMERANG WEAPON] FROG OVERLOAD ACTIVATED!")
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	print("[BOOMERANG WEAPON] 5x size boost for ", frog_overload_duration, " seconds!")

func end_frog_overload():
	print("[BOOMERANG WEAPON] Frog Overload ended")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset the upgrade level after overload ends
	if upgrade_menu_ref and frog_overload_upgrade_key != "":
		print("[BOOMERANG WEAPON] Resetting ", frog_overload_upgrade_key, " level from ", upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key], " to 0")
		upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key] = 0
		
		# Reset weapon stats to base values
		if frog_overload_upgrade_key == "boomerang_count":
			boomerang_count = base_boomerang_count
			print("[BOOMERANG WEAPON] Reset boomerang_count to base: ", base_boomerang_count)
		elif frog_overload_upgrade_key == "boomerang_damage":
			damage = base_damage
			print("[BOOMERANG WEAPON] Reset damage to base: ", base_damage)
		
		frog_overload_upgrade_key = ""
		upgrade_menu_ref = null
