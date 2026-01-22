extends Area2D

var gem_value = 1  # Gems are rarer, usually just 1 at a time
var move_speed = 600.0
var player = null

func _ready():
	# Set up collision layers
	collision_layer = 4  # Layer 3
	collision_mask = 1   # Detect player on layer 1
	
	# Wait a frame to find the player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	# Connect to area entered signal for pickup
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Use player's pickup range (affected by magnet upgrades)
	var attraction_range = player.pickup_range if "pickup_range" in player else 50.0
	
	# Move towards player if within attraction range
	if distance_to_player < attraction_range:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * move_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Give gems to player
		if body.has_method("add_gems"):
			body.add_gems(gem_value)
		
		# Remove the gem pickup
		queue_free()
