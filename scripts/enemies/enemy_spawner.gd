extends Node

# EnemySpawner script to manage enemy spawning in groups outside camera view

# Variables
var enemy_scene: PackedScene
var spawn_interval: float = 3.0  # Time between group spawns
var spawn_timer: float = 0.0
var max_enemies: int = 50  # Increased to allow for groups
var current_enemies: int = 0
var hud = null
var camera: Camera2D = null
var player = null

# Group spawn settings
var min_group_size: int = 5
var max_group_size: int = 20
var spawn_distance: float = 400.0  # Distance from camera edge to spawn

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_scene = preload("res://scenes/enemies/enemy_base.tscn")
	
	# Find the HUD and player
	await get_tree().process_frame
	hud = get_tree().get_first_node_in_group("hud")
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		camera = player.get_node_or_null("Camera2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval and current_enemies < max_enemies:
		spawn_enemy_group()
		spawn_timer = 0.0

# Function to spawn a group of enemies
func spawn_enemy_group() -> void:
	if not camera or not player:
		return
	
	# Determine group size (weighted towards smaller groups)
	var group_size = get_weighted_group_size()
	
	# Don't spawn if it would exceed max enemies
	if current_enemies + group_size > max_enemies:
		group_size = max_enemies - current_enemies
	
	if group_size <= 0:
		return
	
	# Get spawn position outside camera view
	var spawn_center = get_offscreen_position()
	
	# Spawn enemies in a cluster around the spawn center
	for i in range(group_size):
		spawn_enemy_at_position(spawn_center, i, group_size)

# Get a weighted random group size (smaller groups more common)
func get_weighted_group_size() -> int:
	var rand = randf()
	
	if rand < 0.5:  # 50% chance: small group (5-8)
		return randi_range(5, 8)
	elif rand < 0.8:  # 30% chance: medium group (9-14)
		return randi_range(9, 14)
	else:  # 20% chance: large group (15-20)
		return randi_range(15, 20)

# Get a position just outside the camera's view
func get_offscreen_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_pos = camera.get_screen_center_position()
	
	# Choose a random side (0=top, 1=right, 2=bottom, 3=left)
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0:  # Top
			spawn_pos = Vector2(
				randf_range(camera_pos.x - viewport_size.x/2, camera_pos.x + viewport_size.x/2),
				camera_pos.y - viewport_size.y/2 - spawn_distance
			)
		1:  # Right
			spawn_pos = Vector2(
				camera_pos.x + viewport_size.x/2 + spawn_distance,
				randf_range(camera_pos.y - viewport_size.y/2, camera_pos.y + viewport_size.y/2)
			)
		2:  # Bottom
			spawn_pos = Vector2(
				randf_range(camera_pos.x - viewport_size.x/2, camera_pos.x + viewport_size.x/2),
				camera_pos.y + viewport_size.y/2 + spawn_distance
			)
		3:  # Left
			spawn_pos = Vector2(
				camera_pos.x - viewport_size.x/2 - spawn_distance,
				randf_range(camera_pos.y - viewport_size.y/2, camera_pos.y + viewport_size.y/2)
			)
	
	return spawn_pos

# Spawn a single enemy at a position with slight clustering
func spawn_enemy_at_position(center: Vector2, _index: int, _total: int) -> void:
	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	
	# Add some random spread around the center point (tighter clustering)
	var spread = 50.0  # Radius of the cluster
	var offset = Vector2(
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	)
	
	enemy_instance.global_position = center + offset
	current_enemies += 1
	
	# Connect the enemy's death signal to the HUD
	if hud and hud.has_method("add_score"):
		enemy_instance.enemy_died.connect(hud.add_score)
	
	# Connect to track when enemy is removed
	enemy_instance.tree_exiting.connect(enemy_removed)

# Function to notify when an enemy is removed
func enemy_removed() -> void:
	current_enemies -= 1
