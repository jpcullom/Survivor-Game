extends Node2D

class_name PulseWeapon

# Minimal compatibility layer for missing WeaponBase
var damage: int = 5
var cooldown: float = 1.5
var attack_range: float = 75.0
var player = null
var _can_attack: bool = true

# Auto-attack timer
var auto_attack_timer: float = 0.0

# Frog Overload state
var frog_overload_active = false
var frog_overload_timer = 0.0
var frog_overload_duration = 30.0
var frog_overload_upgrade_key = ""
var upgrade_menu_ref = null
var base_damage = 5
var base_attack_range = 75.0

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

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	print("[PULSE WEAPON] FROG OVERLOAD ACTIVATED!")
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	
	# Get viewport size for full screen coverage
	var viewport = player.get_viewport()
	if viewport:
		var viewport_size = viewport.get_visible_rect().size
		attack_range = max(viewport_size.x, viewport_size.y) * 2.0  # Cover entire screen and beyond
		print("[PULSE WEAPON] Full screen coverage! Range: ", attack_range)

func end_frog_overload():
	print("[PULSE WEAPON] Frog Overload ended")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset the upgrade level after overload ends
	if upgrade_menu_ref and frog_overload_upgrade_key != "":
		print("[PULSE WEAPON] Resetting ", frog_overload_upgrade_key, " level from ", upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key], " to 0")
		upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key] = 0
		
		# Reset weapon stats to base values
		if frog_overload_upgrade_key == "pulse_area":
			attack_range = base_attack_range
			print("[PULSE WEAPON] Reset attack_range to base: ", base_attack_range)
		elif frog_overload_upgrade_key == "pulse_damage":
			damage = base_damage
			print("[PULSE WEAPON] Reset damage to base: ", base_damage)
		
		frog_overload_upgrade_key = ""
		upgrade_menu_ref = null
