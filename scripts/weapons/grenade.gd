extends Area2D

var damage: int = 30
var speed: float = 200.0
var travel_time: float = 1.5
var explosion_radius: float = 80.0
var player = null

var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 0.0
var has_exploded: bool = false

var attack_pulse_scene = preload("res://scenes/weapons/attack_pulse.tscn")

func _ready():
	print("[Grenade] _ready() called")
	# Set up collision initially disabled (will enable on explosion)
	monitoring = false

func _process(delta: float) -> void:
	if has_exploded:
		return
	
	lifetime += delta
	
	# Travel in direction
	position += direction * speed * delta
	
	# Explode after travel time
	if lifetime >= travel_time:
		explode()

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()

func explode():
	if has_exploded:
		return
	
	has_exploded = true
	print("[Grenade] BOOM! Exploding at ", global_position)
	
	# Enable collision detection for explosion
	monitoring = true
	
	# Get collision shape and expand it to explosion radius
	var collision = get_node_or_null("CollisionShape2D")
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = explosion_radius
	
	# Damage all enemies in radius
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= explosion_radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player.get_damage_with_crit(damage))
					print("[Grenade] Hit enemy at distance ", distance)
	
	# Visual explosion effect
	create_explosion_visual()
	
	# Remove grenade after short delay
	await get_tree().create_timer(0.3).timeout
	queue_free()

func create_explosion_visual():
	# Use the same visual as pulse weapon for clear AOE indication
	var pulse = attack_pulse_scene.instantiate()
	get_parent().add_child(pulse)
	pulse.global_position = global_position
	if pulse.has_method("set_attack_range"):
		pulse.set_attack_range(explosion_radius)
	
	# Hide the grenade sprite during explosion
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false
