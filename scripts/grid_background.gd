extends ColorRect

# Grid background script to draw a visible grid pattern

var grid_size: int = 64  # Size of each grid cell

func _ready():
	pass

func _draw():
	var viewport_size = get_viewport_rect().size
	
	# Draw vertical lines
	for x in range(0, int(viewport_size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), Color(0.3, 0.3, 0.3, 1), 1)
	
	# Draw horizontal lines
	for y in range(0, int(viewport_size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), Color(0.3, 0.3, 0.3, 1), 1)
