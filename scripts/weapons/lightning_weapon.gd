extends Node2D

class_name LightningWeapon

var damage: int = 25
var cooldown: float = 2.0
var chain_range: float = 150.0
var max_chains: int = 3
var player = null

var lightning_scene = preload("res://scenes/weapons/lightning_chain.tscn")
var auto_attack_timer: float = 0.0

func _process(delta: float) -> void:
	auto_attack_timer += delta
	
	if auto_attack_timer >= cooldown and can_attack():
		attack()
		auto_attack_timer = 0.0

func can_attack() -> bool:
	if not player or not is_instance_valid(player):
		return false
	
	# Check if there are any enemies in range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = player.global_position.distance_to(enemy.global_position)
			if distance <= chain_range:
				return true
	
	return false

func attack():
	if not player:
		return
	
	print("[LightningWeapon] Casting lightning! Chains: ", max_chains, " Range: ", chain_range)
	
	var lightning = lightning_scene.instantiate()
	lightning.player = player
	lightning.damage = damage
	lightning.chain_range = chain_range
	lightning.max_chains = max_chains
	lightning.global_position = player.global_position
	
	player.get_parent().call_deferred("add_child", lightning)

func upgrade_chains():
	max_chains += 1
	print("[LightningWeapon] Chain count upgraded to: ", max_chains)

func upgrade_damage():
	damage = int(damage * 1.5)
	print("[LightningWeapon] Lightning damage upgraded to: ", damage)

func upgrade_range():
	chain_range += 50
	print("[LightningWeapon] Chain range upgraded to: ", chain_range)

func upgrade_speed():
	cooldown = max(0.8, cooldown - 0.2)
	print("[LightningWeapon] Lightning cooldown reduced to: ", cooldown)
