extends Area2D

var damage: int = 15
var orbit_speed: float = 2.0  # Radians per second
var orbit_radius: float = 80.0
var current_angle: float = 0.0
var player = null
var debug_counter = 0

func _enter_tree():
	print("[Orbital] _enter_tree() called! self=", self, " position=", position)

func _ready():
	print("[Orbital] _ready() START - self=", self, " player=", player, " position=", global_position)
	print("[Orbital] visible=", visible, " z_index=", z_index)
	print("[Orbital] process_mode=", process_mode, " is_processing=", is_processing())
	print("[Orbital] Checking children:")
	for child in get_children():
		print("  - ", child.name, ": ", child, " visible=", child.visible if child.has_method("is_visible") else "N/A")
	
	# Set up collision detection
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	print("[Orbital] _ready() COMPLETE")

func _process(delta: float) -> void:
	if not player:
		if debug_counter == 0:
			print("[Orbital] ERROR: No player in _process")
			debug_counter = 60
		return
	
	# Update orbital position
	current_angle += orbit_speed * delta
	if current_angle > TAU:  # TAU = 2*PI
		current_angle -= TAU
	
	# Calculate position around player
	var offset = Vector2(
		cos(current_angle) * orbit_radius,
		sin(current_angle) * orbit_radius
	)
	global_position = player.global_position + offset
	
	# Debug log first frame
	if debug_counter == 0:
		print("[Orbital] First position update: player=", player.global_position, " offset=", offset, " final=", global_position, " visible=", visible)
		debug_counter = 1

func set_player(p) -> void:
	player = p

func set_angle(angle: float) -> void:
	current_angle = angle

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
