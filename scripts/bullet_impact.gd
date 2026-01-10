extends Node2D

var lifetime = 0.3  # How long the effect lasts
var max_radius = 20.0  # Maximum size of the pulse
var time_elapsed = 0.0

@onready var outer_circle = $OuterCircle
@onready var inner_circle = $InnerCircle

func _ready():
	# Generate circle polygons
	generate_circle(outer_circle, 15.0)
	generate_circle(inner_circle, 10.0)
	
	# Set colors
	outer_circle.color = Color(1, 1, 0, 0.6)  # Yellow
	inner_circle.color = Color(1, 1, 1, 0.8)  # White
	
	# Auto-despawn after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	time_elapsed += delta
	
	# Calculate progress (0 to 1)
	var progress = time_elapsed / lifetime
	
	# Expand
	var scale_factor = 1.0 + (progress * 0.5)
	scale = Vector2.ONE * scale_factor
	
	# Fade out
	modulate.a = 1.0 - progress

func generate_circle(polygon: Polygon2D, radius: float):
	var points = []
	var num_points = 32
	
	for i in range(num_points):
		var angle = (float(i) / num_points) * TAU
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	
	polygon.polygon = PackedVector2Array(points)
