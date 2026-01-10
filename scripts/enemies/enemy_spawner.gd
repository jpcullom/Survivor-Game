extends Node

# EnemySpawner script to manage enemy spawning in the game

# Variables
var enemy_scene: PackedScene
var spawn_interval: float = 2.0
var spawn_timer: float = 0.0
var max_enemies: int = 10
var current_enemies: int = 0
var hud = null

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_scene = preload("res://scenes/enemies/enemy_base.tscn")
	
	# Find the HUD
	await get_tree().process_frame
	hud = get_tree().get_first_node_in_group("hud")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval and current_enemies < max_enemies:
		spawn_enemy()
		spawn_timer = 0.0

# Function to spawn an enemy
func spawn_enemy() -> void:
	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	var viewport_size = get_viewport().get_visible_rect().size
	enemy_instance.position = Vector2(randf_range(0, viewport_size.x), randf_range(0, viewport_size.y))
	current_enemies += 1
	
	# Connect the enemy's death signal to the HUD
	if hud and hud.has_method("add_score"):
		enemy_instance.enemy_died.connect(hud.add_score)
	
	# Connect to track when enemy is removed
	enemy_instance.tree_exiting.connect(enemy_removed)

# Function to notify when an enemy is removed
func enemy_removed() -> void:
	current_enemies -= 1
