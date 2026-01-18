extends Node2D

class_name LightningWeapon

var damage: int = 25
var cooldown: float = 2.0
var chain_range: float = 150.0
var max_chains: int = 3
var player = null

var lightning_scene = preload("res://scenes/weapons/lightning_chain.tscn")
var auto_attack_timer: float = 0.0

# Frog Overload state
var frog_overload_active = false
var frog_overload_timer = 0.0
var frog_overload_duration = 30.0
var frog_overload_upgrade_key = ""
var upgrade_menu_ref = null
var base_damage = 25
var base_max_chains = 3

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
	
	var current_max_chains = max_chains
	# Apply Frog Overload chain boost (up to 30 enemies!)
	if frog_overload_active:
		current_max_chains = 30
	
	print("[LightningWeapon] Casting lightning! Chains: ", current_max_chains, " Range: ", chain_range)
	
	var lightning = lightning_scene.instantiate()
	lightning.player = player
	lightning.damage = damage
	lightning.chain_range = chain_range
	lightning.max_chains = current_max_chains
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

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	print("[LIGHTNING WEAPON] FROG OVERLOAD ACTIVATED!")
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	print("[LIGHTNING WEAPON] Chain up to 30 enemies for ", frog_overload_duration, " seconds!")

func end_frog_overload():
	print("[LIGHTNING WEAPON] Frog Overload ended")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset the upgrade level after overload ends
	if upgrade_menu_ref and frog_overload_upgrade_key != "":
		print("[LIGHTNING WEAPON] Resetting ", frog_overload_upgrade_key, " level from ", upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key], " to 0")
		upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key] = 0
		
		# Reset weapon stats to base values
		if frog_overload_upgrade_key == "lightning_chains":
			max_chains = base_max_chains
			print("[LIGHTNING WEAPON] Reset max_chains to base: ", base_max_chains)
		elif frog_overload_upgrade_key == "lightning_damage":
			damage = base_damage
			print("[LIGHTNING WEAPON] Reset damage to base: ", base_damage)
		
		frog_overload_upgrade_key = ""
		upgrade_menu_ref = null
