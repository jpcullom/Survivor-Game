extends TileMap

# Procedural desert tilemap that generates around the player

var camera: Camera2D = null
var player = null
var tile_size: int = 512  # Size of the full repeating texture
var tile_scale: float = 0.5  # Scale down the tile (adjust this to make bigger/smaller)
var chunk_size: int = 8  # Tiles per chunk
var loaded_chunks = {}

func _ready():
	# Set the scale of the tilemap
	scale = Vector2(tile_scale, tile_scale)
	
	# Find the camera
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_node_or_null("Camera2D")
	
	# Generate initial chunks
	update_chunks()

func _process(_delta):
	if camera:
		update_chunks()

func update_chunks():
	if not camera:
		return
	
	var camera_pos = camera.get_screen_center_position()
	
	# Calculate which chunk the camera is in (accounting for scale)
	var scaled_tile_size = tile_size * tile_scale
	var camera_chunk_x = int(floor(camera_pos.x / (scaled_tile_size * chunk_size)))
	var camera_chunk_y = int(floor(camera_pos.y / (scaled_tile_size * chunk_size)))
	
	# Load chunks around the camera (3x3 grid of chunks)
	for offset_x in range(-1, 2):
		for offset_y in range(-1, 2):
			var chunk_x = camera_chunk_x + offset_x
			var chunk_y = camera_chunk_y + offset_y
			var chunk_key = Vector2i(chunk_x, chunk_y)
			
			if not loaded_chunks.has(chunk_key):
				generate_chunk(chunk_x, chunk_y)
				loaded_chunks[chunk_key] = true
	
	# Unload far chunks (optional, for memory management)
	var chunks_to_remove = []
	for chunk_key in loaded_chunks.keys():
		var dist_x = abs(chunk_key.x - camera_chunk_x)
		var dist_y = abs(chunk_key.y - camera_chunk_y)
		if dist_x > 2 or dist_y > 2:
			chunks_to_remove.append(chunk_key)
			clear_chunk(chunk_key.x, chunk_key.y)
	
	for chunk_key in chunks_to_remove:
		loaded_chunks.erase(chunk_key)

func generate_chunk(chunk_x: int, chunk_y: int):
	# Generate tiles for this chunk
	for x in range(chunk_size):
		for y in range(chunk_size):
			var tile_x = chunk_x * chunk_size + x
			var tile_y = chunk_y * chunk_size + y
			
			# Place the same repeating tile everywhere (0:0 in atlas)
			set_cell(0, Vector2i(tile_x, tile_y), 0, Vector2i(0, 0))

func clear_chunk(chunk_x: int, chunk_y: int):
	# Clear tiles in this chunk
	for x in range(chunk_size):
		for y in range(chunk_size):
			var tile_x = chunk_x * chunk_size + x
			var tile_y = chunk_y * chunk_size + y
			erase_cell(0, Vector2i(tile_x, tile_y))
