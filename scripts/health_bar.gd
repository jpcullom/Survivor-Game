extends Node2D

@onready var health_fill = $HealthFill
@onready var background = $Background

var max_health = 100
var current_health = 100
var bar_width = 40.0
var bar_height = 5.0

func _ready():
	# Set up the bar dimensions
	background.size = Vector2(bar_width, bar_height)
	health_fill.size = Vector2(bar_width, bar_height)
	update_health_bar()

func update_health(health_value, max_health_value):
	current_health = health_value
	max_health = max_health_value
	update_health_bar()

func update_health_bar():
	# Calculate health percentage
	var health_percent = float(current_health) / float(max_health)
	health_percent = clamp(health_percent, 0.0, 1.0)
	
	# Update the fill width by adjusting scale
	health_fill.scale.x = health_percent
	
	# Change color based on health percentage
	if health_percent > 0.6:
		health_fill.color = Color(0, 0.8, 0, 1)  # Green
	elif health_percent > 0.3:
		health_fill.color = Color(1, 0.8, 0, 1)  # Yellow
	else:
		health_fill.color = Color(1, 0, 0, 1)  # Red
	
	# Hide health bar if at full health (optional - uncomment if you want this)
	# visible = health_percent < 1.0
