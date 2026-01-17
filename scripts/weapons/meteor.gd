extends Area2D

var damage: int = 40
var speed: float = 600.0
var target_position: Vector2 = Vector2.ZERO
var impact_radius: float = 60.0

var velocity: Vector2 = Vector2.ZERO
var has_impacted: bool = false
var trail_particles = []

var attack_pulse_scene = preload("res://scenes/weapons/attack_pulse.tscn")

func _ready():
	print("[Meteor] _ready() called, targeting: ", target_position)
	
	# Calculate direction to target
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	
	# Rotate sprite to face direction of travel
	rotation = direction.angle() + PI / 2  # Adjust for sprite orientation
	
	# Disable collision initially
	monitoring = false
	
	# Set up visual trail effect
	create_trail_effect()

func _process(delta: float) -> void:
	if has_impacted:
		return
	
	# Move towards target
	position += velocity * delta
	
	# Check if we've reached or passed the target
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < 10.0:  # Close enough to impact
		impact()

func create_trail_effect():
	# Create a simple visual trail using particles or multiple sprites
	# This is a placeholder - you can enhance with actual particle effects
	pass

func impact():
	if has_impacted:
		return
	
	has_impacted = true
	print("[Meteor] IMPACT at ", global_position)
	
	# Enable collision detection for impact
	monitoring = true
	
	# Get collision shape and expand it to impact radius
	var collision = get_node_or_null("CollisionShape2D")
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = impact_radius
	
	# Damage all enemies in radius
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= impact_radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
					print("[Meteor] Hit enemy at distance ", distance)
	
	# Visual impact effect
	create_impact_visual()
	
	# Remove meteor after short delay
	await get_tree().create_timer(0.3).timeout
	queue_free()

func create_impact_visual():
	# Use the same visual as pulse weapon for clear AOE indication
	var pulse = attack_pulse_scene.instantiate()
	get_parent().add_child(pulse)
	pulse.global_position = global_position
	if pulse.has_method("set_attack_range"):
		pulse.set_attack_range(impact_radius)
	
	# Hide the meteor sprite during explosion
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false
