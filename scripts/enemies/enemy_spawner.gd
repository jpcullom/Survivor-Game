extends Node

# EnemySpawner script to manage enemy spawning in groups outside camera view

# Variables
var enemy_scene: PackedScene
var base_spawn_interval: float = 5.0  # Base time between group spawns (increased from 3.0)
var spawn_interval: float = 5.0  # Current spawn interval (will scale with score)
var spawn_timer: float = 0.0
var base_max_enemies: int = 30  # Base max enemies (reduced from 50)
var max_enemies: int = 30  # Current max enemies (will scale with score)
var absolute_max_enemies: int = 150  # Hard cap to prevent performance issues
var current_enemies: int = 0
var hud = null
var camera: Camera2D = null
var player = null

# Group spawn settings
var min_group_size: int = 3
var max_group_size: int = 12
var spawn_distance: float = 400.0  # Distance from camera edge to spawn

# Enemy type tracking
var coyotes_spawned: int = 0
var toads_spawned: int = 0
var vultures_spawned: int = 0

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
	# Update difficulty based on current score
	update_difficulty()
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval and current_enemies < max_enemies:
		spawn_enemy_group()
		spawn_timer = 0.0

# Update spawn rate and max enemies based on score
func update_difficulty() -> void:
	if not hud:
		return
	
	var score = hud.score
	
	# Decrease spawn interval as score increases (faster spawns)
	# Every 100 score reduces interval by 0.1 seconds, min 0.5 seconds
	var interval_reduction = (score / 100.0) * 0.1
	spawn_interval = max(0.5, base_spawn_interval - interval_reduction)
	
	# Increase max enemies as score increases
	# Every 50 score adds 5 more max enemies
	var enemy_increase = int(score / 50.0) * 5
	max_enemies = min(absolute_max_enemies, base_max_enemies + enemy_increase)

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
	
	if rand < 0.6:  # 60% chance: small group (3-5)
		return randi_range(3, 5)
	elif rand < 0.85:  # 25% chance: medium group (6-8)
		return randi_range(6, 8)
	else:  # 15% chance: large group (9-12)
		return randi_range(9, 12)

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
	
	# Determine enemy type BEFORE adding to scene (so _ready() can use it)
	var rand_type = randi() % 20  # 0-19
	if rand_type == 0:  # 1 in 20 chance (5%)
		enemy_instance.enemy_type = Enemy.EnemyType.TOAD
		toads_spawned += 1
		print("[Enemy Spawn] TOAD spawned! (Total: Coyotes=", coyotes_spawned, ", Toads=", toads_spawned, ", Vultures=", vultures_spawned, ")")
	elif rand_type == 1:  # 1 in 20 chance (5%)
		enemy_instance.enemy_type = Enemy.EnemyType.VULTURE
		vultures_spawned += 1
		print("[Enemy Spawn] VULTURE spawned! (Total: Coyotes=", coyotes_spawned, ", Toads=", toads_spawned, ", Vultures=", vultures_spawned, ")")
	else:
		enemy_instance.enemy_type = Enemy.EnemyType.COYOTE
		coyotes_spawned += 1
	
	# Initialize enemy with its type
	enemy_instance.initialize_enemy_type()
	
	# NOW add to scene tree (after type is set and initialized)
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
