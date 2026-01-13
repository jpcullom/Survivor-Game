extends Node2D

var damage: int = 25
var chain_range: float = 150.0
var max_chains: int = 3
var chain_delay: float = 0.1
var player = null

var hit_enemies: Array = []
var current_target = null
var chains_remaining: int = 0
var chain_timer: float = 0.0
var is_chaining: bool = false

# Visual line
var line: Line2D = null

func _ready():
	print("[LightningChain] _ready() called")
	
	# Create visual line
	line = Line2D.new()
	line.width = 3.0
	line.default_color = Color(0.5, 0.8, 1.0, 1.0)
	line.z_index = 5
	add_child(line)
	
	# Start the chain
	chains_remaining = max_chains
	find_next_target()

func _process(delta: float) -> void:
	if not is_chaining:
		return
	
	chain_timer -= delta
	if chain_timer <= 0 and chains_remaining > 0:
		chain_to_next()

func find_next_target():
	if not player or not is_instance_valid(player):
		queue_free()
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy = null
	var closest_distance = chain_range
	
	# Find closest enemy we haven't hit yet
	var search_pos = current_target.global_position if current_target else player.global_position
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy in hit_enemies:
			continue
		
		var distance = search_pos.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		current_target = closest_enemy
		hit_target(current_target)
		chains_remaining -= 1
		
		if chains_remaining > 0:
			is_chaining = true
			chain_timer = chain_delay
		else:
			# No more chains, start fade out
			fade_out()
	else:
		# No more targets
		fade_out()

func hit_target(target):
	if not is_instance_valid(target):
		return
	
	hit_enemies.append(target)
	
	# Deal damage
	if target.has_method("take_damage"):
		target.take_damage(damage)
		print("[LightningChain] Hit enemy! Dealing ", damage, " damage (", chains_remaining, " chains left)")
	
	# Update visual line
	update_visual()

func chain_to_next():
	is_chaining = false
	find_next_target()

func update_visual():
	if not line:
		return
	
	line.clear_points()
	
	# Draw line from player through all hit enemies
	if player and is_instance_valid(player):
		line.add_point(player.global_position - global_position)
	
	for enemy in hit_enemies:
		if is_instance_valid(enemy):
			line.add_point(enemy.global_position - global_position)

func fade_out():
	# Fade out the lightning effect
	var tween = create_tween()
	if line:
		tween.tween_property(line, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
