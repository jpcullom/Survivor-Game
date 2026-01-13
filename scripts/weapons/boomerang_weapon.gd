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
