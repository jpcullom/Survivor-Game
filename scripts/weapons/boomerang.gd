extends Area2D

var damage: int = 20
var speed: float = 300.0
var max_distance: float = 200.0
var player = null

var direction: Vector2 = Vector2.RIGHT
var traveled_distance: float = 0.0
var returning: bool = false
var hit_enemies: Dictionary = {}  # Track enemies we've hit recently
var hit_cooldown: float = 0.3  # Cooldown before hitting same enemy again
var frog_overload_scale: float = 1.0  # Size multiplier for Frog Overload

func _ready():
	print("[Boomerang] _ready() called")
	# Set up collision detection
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Apply Frog Overload scale
	if frog_overload_scale > 1.0:
		scale = Vector2(frog_overload_scale, frog_overload_scale)
		print("[Boomerang] Applied Frog Overload scale: ", frog_overload_scale)

func _process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		queue_free()
		return
	
	# Reduce hit cooldowns
	for enemy in hit_enemies.keys():
		hit_enemies[enemy] -= delta
		if hit_enemies[enemy] <= 0:
			hit_enemies.erase(enemy)
	
	if not returning:
		# Move outward
		position += direction * speed * delta
		traveled_distance += speed * delta
		
		# Start returning when we've traveled max distance
		if traveled_distance >= max_distance:
			returning = true
	else:
		# Move back toward player
		var to_player = player.global_position - global_position
		var distance_to_player = to_player.length()
		
		if distance_to_player < 20:
			# Reached player, destroy boomerang
			queue_free()
			return
		
		direction = to_player.normalized()
		position += direction * speed * delta
	
	# Rotate the boomerang for visual effect
	rotation += 15 * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = dir.angle()

func _on_body_entered(body):
	if body == player:
		return
	
	if body.is_in_group("enemies"):
		# Check if we can hit this enemy (cooldown expired)
		if not hit_enemies.has(body) or hit_enemies[body] <= 0:
			if body.has_method("take_damage"):
				body.take_damage(damage)
				hit_enemies[body] = hit_cooldown
				print("[Boomerang] Hit enemy! Dealing ", damage, " damage")

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		# Check if we can hit this enemy (cooldown expired)
		if not hit_enemies.has(area) or hit_enemies[area] <= 0:
			if area.has_method("take_damage"):
				area.take_damage(damage)
				hit_enemies[area] = hit_cooldown
				print("[Boomerang] Hit enemy area! Dealing ", damage, " damage")
