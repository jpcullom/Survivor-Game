extends Node2D

class_name MeteorWeapon

var damage: int = 40
var cooldown: float = 3.0
var meteor_count: int = 1
var player = null

var meteor_scene = preload("res://scenes/weapons/meteor.tscn")
var auto_attack_timer: float = 0.0

func _process(delta: float) -> void:
	auto_attack_timer += delta
	
	if auto_attack_timer >= cooldown and can_attack():
		attack()
		auto_attack_timer = 0.0

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
	
	print("[MeteorWeapon] Summoning ", meteor_count, " meteor(s)!")
	
	# Get all valid enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	var valid_enemies = []
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			valid_enemies.append(enemy)
	
	if valid_enemies.is_empty():
		return
	
	# Launch meteors at random enemies
	for i in range(meteor_count):
		var target_enemy = valid_enemies[randi() % valid_enemies.size()]
		spawn_meteor(target_enemy)

func spawn_meteor(target_enemy):
	var meteor = meteor_scene.instantiate()
	meteor.damage = damage
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
