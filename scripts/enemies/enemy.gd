extends CharacterBody2D

class_name Enemy

signal enemy_died(score_value)

var health: int = 50
var max_health: int = 50
var speed: float = 80.0
var damage: int = 10
var attack_range: float = 30.0
var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0
var score_value: int = 100
var player = null
var health_bar = null

# Preload health bar scene and gold pickup
var health_bar_scene = preload("res://scenes/ui/health_bar.tscn")
var gold_pickup_scene = preload("res://scenes/items/gold_pickup.tscn")

func _ready():
	# Add to enemies group for easy player detection
	add_to_group("enemies")
	
	# Create and add health bar
	health_bar = health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.update_health(health, max_health)
	
	# Find the player
	await get_tree().process_frame  # Wait one frame for everything to be ready
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("Warning: Enemy couldn't find player!")

func _physics_process(delta: float) -> void:
	if not player:
		# Try to find player again
		player = get_tree().get_first_node_in_group("player")
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Check if we're close enough to attack
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range:
		attempt_attack()

func attempt_attack() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time >= attack_cooldown:
		attack_player()
		last_attack_time = current_time

func attack_player() -> void:
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
		print("Enemy dealt ", damage, " damage to player!")

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took ", amount, " damage! Health: ", health)
	
	# Update health bar
	if health_bar:
		health_bar.update_health(health, max_health)
	
	# Visual feedback - flash white
	modulate = Color(2, 2, 2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

func die() -> void:
	print("Enemy died! Awarding ", score_value, " points")
	enemy_died.emit(score_value)
	
	# Drop gold at enemy position
	var gold = gold_pickup_scene.instantiate()
	get_parent().add_child(gold)
	gold.global_position = global_position
	
	queue_free()