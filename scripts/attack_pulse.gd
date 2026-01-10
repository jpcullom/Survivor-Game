extends Node2D

# Attack pulse visual effect

@onready var outer_circle = $OuterCircle
@onready var inner_circle = $InnerCircle

var lifetime = 0.5  # How long the pulse lasts in seconds
var max_radius = 100  # Maximum radius (should match attack range)
var time_elapsed = 0.0

func _ready():
	# Generate circle polygons
	update_circles(0)

func _process(delta):
	time_elapsed += delta
	
	if time_elapsed >= lifetime:
		queue_free()
		return
	
	# Calculate progress (0 to 1)
	var progress = time_elapsed / lifetime
	
	# Update circle sizes (expand outward)
	var current_radius = progress * max_radius
	update_circles(current_radius)
	
	# Fade out as it expands
	var alpha = 1.0 - progress
	outer_circle.color.a = alpha * 0.4
	inner_circle.color.a = alpha * 0.6

func update_circles(radius):
	# Generate circle polygons
	var segments = 32
	var outer_points = PackedVector2Array()
	var inner_points = PackedVector2Array()
	
	for i in range(segments + 1):
		var angle = (float(i) / segments) * TAU
		var outer_point = Vector2(cos(angle), sin(angle)) * radius
		var inner_point = Vector2(cos(angle), sin(angle)) * (radius * 0.85)
		
		outer_points.append(outer_point)
		inner_points.append(inner_point)
	
	outer_circle.polygon = outer_points
	inner_circle.polygon = inner_points

func set_attack_range(range_value):
	max_radius = range_value
