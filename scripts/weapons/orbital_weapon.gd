extends Node2D

class_name OrbitalWeapon

var damage: int = 15
var orbital_count: int = 3
var orbit_radius: float = 80.0
var orbit_speed: float = 2.0
var player = null

var orbital_scene = preload("res://scenes/weapons/orbital.tscn")
var orbitals: Array = []

# Frog Overload state
var frog_overload_active = false
var frog_overload_timer = 0.0
var frog_overload_duration = 30.0
var frog_overload_upgrade_key = ""
var upgrade_menu_ref = null
var base_damage = 15
var base_orbital_count = 3
var base_orbit_speed = 2.0

func _ready():
	print("[OrbitalWeapon] _ready() called, player = ", player)
	# Spawn initial orbitals
	spawn_orbitals()

func _process(delta: float) -> void:
	# Handle Frog Overload timer
	if frog_overload_active:
		frog_overload_timer -= delta
		if frog_overload_timer <= 0:
			end_frog_overload()

func spawn_orbitals():
	print("[OrbitalWeapon] spawn_orbitals() called")
	print("[OrbitalWeapon] player = ", player)
	print("[OrbitalWeapon] orbital_count = ", orbital_count)
	
	# Clear existing orbitals
	for orbital in orbitals:
		if is_instance_valid(orbital):
			orbital.queue_free()
	orbitals.clear()
	
	if not player:
		print("[OrbitalWeapon] ERROR: No player reference, aborting spawn")
		return
	
	# Spawn new orbitals evenly distributed around player
	var angle_step = TAU / orbital_count
	print("[OrbitalWeapon] Spawning ", orbital_count, " orbitals with angle_step = ", angle_step)
	
	for i in range(orbital_count):
		var orbital = orbital_scene.instantiate()
		print("[OrbitalWeapon] Created orbital ", i, ": ", orbital)
		print("[OrbitalWeapon] Orbital script: ", orbital.get_script())
		print("[OrbitalWeapon] Orbital class: ", orbital.get_class())
		
		# Set properties BEFORE adding to scene tree
		orbital.player = player
		orbital.damage = damage
		orbital.orbit_radius = orbit_radius
		
		# Apply Frog Overload speed boost (5x faster!)
		if frog_overload_active:
			orbital.orbit_speed = orbit_speed * 5.0
		else:
			orbital.orbit_speed = orbit_speed
		
		orbital.current_angle = i * angle_step
		
		# Calculate initial position
		var offset = Vector2(
			cos(i * angle_step) * orbit_radius,
			sin(i * angle_step) * orbit_radius
		)
		orbital.global_position = player.global_position + offset
		
		print("[OrbitalWeapon] Orbital ", i, " initial position set to: ", orbital.global_position)
		player.get_parent().add_child.call_deferred(orbital)
		print("[OrbitalWeapon] Deferred add of orbital ", i, " to scene tree, visible=", orbital.visible)
		print("[OrbitalWeapon] Orbital in tree? ", orbital.is_inside_tree())
		print("[OrbitalWeapon] Orbital parent: ", orbital.get_parent())
		print("[OrbitalWeapon] Orbital process_mode: ", orbital.process_mode)
		orbitals.append(orbital)
	
	print("[OrbitalWeapon] spawn_orbitals() COMPLETE. Total orbitals created: ", orbitals.size())
	print("[OrbitalWeapon] Verifying all orbitals after 1 frame...")
	await get_tree().process_frame
	for i in range(orbitals.size()):
		var orb = orbitals[i]
		if is_instance_valid(orb):
			print("[OrbitalWeapon] Orbital ", i, " after frame: position=", orb.global_position, " visible=", orb.visible, " in_tree=", orb.is_inside_tree())

func upgrade_count():
	orbital_count += 1
	spawn_orbitals()

func upgrade_damage():
	damage = int(damage * 1.5)
	for orbital in orbitals:
		if is_instance_valid(orbital):
			orbital.damage = damage

func upgrade_size():
	orbit_radius += 20
	for orbital in orbitals:
		if is_instance_valid(orbital):
			orbital.orbit_radius = orbit_radius

func upgrade_speed():
	orbit_speed += 0.5
	for orbital in orbitals:
		if is_instance_valid(orbital):
			orbital.orbit_speed = orbit_speed

func activate_frog_overload(upgrade_key: String, upgrade_menu):
	print("[ORBITAL WEAPON] FROG OVERLOAD ACTIVATED!")
	frog_overload_active = true
	frog_overload_timer = frog_overload_duration
	frog_overload_upgrade_key = upgrade_key
	upgrade_menu_ref = upgrade_menu
	
	# Boost all existing orbitals to 5x speed
	for orbital in orbitals:
		if is_instance_valid(orbital):
			orbital.orbit_speed = orbit_speed * 5.0
	
	print("[ORBITAL WEAPON] 5x spin speed for ", frog_overload_duration, " seconds!")

func end_frog_overload():
	print("[ORBITAL WEAPON] Frog Overload ended")
	frog_overload_active = false
	frog_overload_timer = 0.0
	
	# Reset orbital speeds to normal
	for orbital in orbitals:
		if is_instance_valid(orbital):
			orbital.orbit_speed = orbit_speed
	
	# Reset the upgrade level after overload ends
	if upgrade_menu_ref and frog_overload_upgrade_key != "":
		print("[ORBITAL WEAPON] Resetting ", frog_overload_upgrade_key, " level from ", upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key], " to 0")
		upgrade_menu_ref.weapon_levels[frog_overload_upgrade_key] = 0
		
		# Reset weapon stats to base values
		if frog_overload_upgrade_key == "orbital_count":
			orbital_count = base_orbital_count
			spawn_orbitals()  # Respawn with base count
			print("[ORBITAL WEAPON] Reset orbital_count to base: ", base_orbital_count)
		elif frog_overload_upgrade_key == "orbital_damage":
			damage = base_damage
			for orbital in orbitals:
				if is_instance_valid(orbital):
					orbital.damage = base_damage
			print("[ORBITAL WEAPON] Reset damage to base: ", base_damage)
		elif frog_overload_upgrade_key == "orbital_speed":
			orbit_speed = base_orbit_speed
			for orbital in orbitals:
				if is_instance_valid(orbital):
					orbital.orbit_speed = base_orbit_speed
			print("[ORBITAL WEAPON] Reset orbit_speed to base: ", base_orbit_speed)
		
		frog_overload_upgrade_key = ""
		upgrade_menu_ref = null
