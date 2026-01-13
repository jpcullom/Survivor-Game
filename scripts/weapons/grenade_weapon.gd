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

func _process(delta: float) -> void:
	auto_attack_timer += delta
	
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
