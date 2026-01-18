extends Area2D

var speed = 400.0
var damage = 10
var direction = Vector2.ZERO
var lifetime = 2.0  # Seconds before bullet despawns

# Preload impact effect
const impact_scene = preload("res://scenes/weapons/bullet_impact.tscn")

func _ready():
	# Set up collision
	collision_layer = 8  # Layer 4 for projectiles
	collision_mask = 2   # Detect enemies on layer 2
	
	# Connect signals for both Area2D and PhysicsBody2D collisions
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Auto-despawn after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		print("Bullet timed out")
		queue_free()

func _physics_process(delta):
	# Move bullet in direction
	global_position += direction * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()
	# Rotate bullet to face direction
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		# Damage enemy
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# Spawn impact effect
		spawn_impact_effect()
		# Destroy bullet
		queue_free()

func _on_area_entered(area):
	print("Bullet hit area: ", area.name)
	# Check if the area's parent is an enemy
	if area.get_parent() and area.get_parent().is_in_group("enemies"):
		print("Bullet hit enemy area! Dealing ", damage, " damage")
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
		# Spawn impact effect
		spawn_impact_effect()
		# Destroy bullet
		queue_free()

func spawn_impact_effect():
	# Create and spawn the impact effect at bullet's position
	var impact = impact_scene.instantiate()
	impact.global_position = global_position
	# Add to the scene tree (same parent as bullet)
	get_tree().root.add_child(impact)
