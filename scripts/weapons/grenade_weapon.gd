extends Node2D

class_name GrenadeWeapon

var damage: int = 30
var cooldown: float = 2.0
var explosion_radius: float = 80.0
var speed: float = 200.0
var travel_time: float = 1.5
var grenade_count: int = 1
var player = null

var grenade_scene = preload("res://scenes/weapons/grenade.tscn")
var auto_attack_timer: float = 0.0
var throw_angle: float = 0.0

# Frog Overload state
var frog_overload_active = false
var frog_overload_timer = 0.0
var frog_overload_duration = 30.0
var frog_overload_upgrade_key = ""
var upgrade_menu_ref = null
var base_damage = 30
var base_grenade_count = 1
var base_explosion_radius = 80.0

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
	
	print("[GrenadeWeapon] Throwing ", grenade_count, " grenade(s)!")
	
	# Spread grenades in different directions
	var angle_step = TAU / grenade_count
	
	for i in range(grenade_count):
		var grenade = grenade_scene.instantiate()
		grenade.player = player
		grenade.damage = damage
		grenade.speed = speed
		grenade.travel_time = travel_time
		
		# Apply Frog Overload explosion boost (3x larger explosions)
		if frog_overload_active:
			grenade.explosion_radius = explosion_radius * 3.0
		else:
			grenade.explosion_radius = explosion_radius
		
		grenade.global_position = player.global_position
		
		# Calculate throw direction
		var throw_direction_angle = throw_angle + (i * angle_step)
		var throw_direction = Vector2(cos(throw_direction_angle), sin(throw_direction_angle))
		grenade.set_direction(throw_direction)
		
		player.get_parent().call_deferred("add_child", grenade)
	
	# Rotate angle for next throw
	throw_angle += angle_step * 0.3

func upgrade_count():
	grenade_count += 1
	print("[GrenadeWeapon] Grenade count upgraded to: ", grenade_count)

func upgrade_damage():
	damage = int(damage * 1.5)
	print("[GrenadeWeapon] Grenade damage upgraded to: ", damage)

func upgrade_radius():
	explosion_radius += 20
	print("[GrenadeWeapon] Explosion radius upgraded to: ", explosion_radius)

func upgrade_speed():
	cooldown = max(0.8, cooldown - 0.2)
	speed += 30
	print("[GrenadeWeapon] Grenade speed upgraded - cooldown: ", cooldown, " speed: ", speed)

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	print("[GRENADE WEAPON] FROG OVERLOAD ACTIVATED!")
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	print("[GRENADE WEAPON] 3x explosion radius for ", frog_overload_duration, " seconds!")

func end_frog_overload():
	print("[GRENADE WEAPON] Frog Overload ended")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset the upgrade level after overload ends
	if upgrade_menu_ref and frog_overload_upgrade_key != "":
		print("[GRENADE WEAPON] Resetting ", frog_overload_upgrade_key, " level from ", upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key], " to 0")
		upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key] = 0
		
		# Reset weapon stats to base values
		if frog_overload_upgrade_key == "grenade_count":
			grenade_count = base_grenade_count
			print("[GRENADE WEAPON] Reset grenade_count to base: ", base_grenade_count)
		elif frog_overload_upgrade_key == "grenade_damage":
			damage = base_damage
			print("[GRENADE WEAPON] Reset damage to base: ", base_damage)
		
		frog_overload_upgrade_key = ""
		upgrade_menu_ref = null
