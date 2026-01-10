extends Node2D

class_name PulseWeapon

# Minimal compatibility layer for missing WeaponBase
var damage: int = 10
var cooldown: float = 0.5
var attack_range: float = 100.0
var player = null
var _can_attack: bool = true

func can_attack() -> bool:
	return _can_attack

func start_cooldown() -> void:
	_can_attack = false
	await get_tree().create_timer(cooldown).timeout
	_can_attack = true


var attack_pulse_scene = preload("res://scenes/weapons/attack_pulse.tscn")

func _init():
	# Keep defaults in case WeaponBase normally sets them
	pass

func attack():
	if not can_attack() or not player:
		return
	
	print("Pulse attack!")
	
	# Spawn visual attack pulse effect
	var pulse = attack_pulse_scene.instantiate()
	player.get_parent().add_child(pulse)
	pulse.global_position = player.global_position
	if pulse.has_method("set_attack_range"):
		pulse.set_attack_range(attack_range)
	
	# Get all enemies in the scene
	var enemies = player.get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Check if enemy is in attack range
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance <= attack_range:
			print("Hit enemy at distance: ", distance)
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
	
	# Start cooldown
	start_cooldown()
