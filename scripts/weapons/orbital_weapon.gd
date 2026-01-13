extends Node2D

class_name OrbitalWeapon

var damage: int = 15
var orbital_count: int = 3
var orbit_radius: float = 80.0
var orbit_speed: float = 2.0
var player = null

var orbital_scene = preload("res://scenes/weapons/orbital.tscn")
var orbitals: Array = []

func _ready():
	print("[OrbitalWeapon] _ready() called, player = ", player)
	# Spawn initial orbitals
	spawn_orbitals()

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
