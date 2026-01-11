extends Node2D

# Random desert tilemap background that follows the camera

var tile_size: int = 256  # Size of each tile from your tileset
var camera: Camera2D = null
var player = null

# Tile cache to avoid recreating tiles
var tile_cache = {}
var visible_tiles = []

# Desert tileset
var tileset_texture = null
var tile_positions = []  # Store different tile positions in the tileset

func _ready():
	# Load the tileset
	tileset_texture = load("res://sprites/BackgroundTileset.png")
	
	# Define tile positions from your tileset (x, y in pixels, based on the layout)
	# These are the different tile variations in your tileset
	tile_positions = [
		Vector2(0, 0),      # Top-left tile
		Vector2(256, 0),    # Top-middle tile  
		Vector2(512, 0),    # Top-right small
		Vector2(512, 256),  # Right middle
		Vector2(512, 512),  # Bottom right
		Vector2(0, 256),    # Left middle large
		Vector2(256, 256),  # Center large with cacti
		Vector2(0, 640),    # Bottom left small
		Vector2(256, 640),  # Bottom middle small
		Vector2(512, 640),  # Bottom right small with flower
	]
	
	# Find the camera
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_node_or_null("Camera2D")

func _process(_delta):
	if camera:
		update_tiles()
		queue_redraw()

func update_tiles():
	if not camera:
		return
	
	var camera_pos = camera.get_screen_center_position()
	var viewport_size = get_viewport_rect().size
	
	# Calculate which tiles should be visible
	var tiles_x = int(viewport_size.x / tile_size) + 4  # Extra tiles for smooth scrolling
	var tiles_y = int(viewport_size.y / tile_size) + 4
	
	var start_tile_x = int(camera_pos.x / tile_size) - tiles_x / 2
	var start_tile_y = int(camera_pos.y / tile_size) - tiles_y / 2
	
	# Generate tile keys for visible area
	var needed_tiles = []
	for x in range(tiles_x):
		for y in range(tiles_y):
			var tile_x = start_tile_x + x
			var tile_y = start_tile_y + y
			var tile_key = Vector2i(tile_x, tile_y)
			needed_tiles.append(tile_key)
	
	visible_tiles = needed_tiles

func _draw():
	if not camera or not tileset_texture:
		return
	
	# Draw all visible tiles
	for tile_key in visible_tiles:
		var world_pos = Vector2(tile_key.x * tile_size, tile_key.y * tile_size)
		
		# Use tile position as seed for consistent random selection
		var tile_seed = hash(tile_key)
		var tile_index = abs(tile_seed) % tile_positions.size()
		var src_rect = Rect2(tile_positions[tile_index], Vector2(tile_size, tile_size))
		
		# Draw tile relative to camera
		var camera_pos = camera.get_screen_center_position()
		var viewport_size = get_viewport_rect().size
		var screen_pos = world_pos - camera_pos + viewport_size / 2
		
		draw_texture_rect_region(tileset_texture, 
			Rect2(screen_pos, Vector2(tile_size, tile_size)),
			src_rect)
