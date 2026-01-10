extends Area2D

var gold_value = 5
var move_speed = 150.0
var attraction_range = 150.0
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
	
	# Move towards player if within attraction range
	if distance_to_player < attraction_range:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * move_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Give gold to player
		if body.has_method("add_gold"):
			body.add_gold(gold_value)
		
		# Remove the gold pickup
		queue_free()
