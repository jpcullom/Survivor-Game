extends CanvasLayer

@onready var health_label = $Control/HealthContainer/HealthLabel
@onready var health_progress_bar = $Control/HealthProgressBar
@onready var score_label = $Control/ScoreLabel
@onready var gold_label = $Control/GoldLabel
@onready var gold_progress_bar = $Control/GoldProgressBar
@onready var gem_label = $Control/GemLabel
@onready var high_score_label = $Control/HighScoreLabel
@onready var weapon_slots_container = $Control/WeaponSlotsContainer
@onready var lives_label = $Control/LivesLabel

var player = null
var score = 0
var gold = 0
var gems = 0
var high_score = 0
var dialogue_splash = null
var weapon_slots = []  # Array of weapon slot panels

# Weapon name to display mapping
var weapon_display_names = {
	"bullet": "B",
	"pulse": "P",
	"orbital": "O",
	"boomerang": "R",
	"lightning": "L",
	"grenade": "G",
	"meteor": "M",
	"healing_aura": "H"
}

# Weapon sprites
var weapon_sprites = {
	"bullet": preload("res://sprites/pistol.png"),
	"boomerang": preload("res://sprites/boomerang.png"),
	"meteor": preload("res://sprites/meteor.png"),
	"grenade": preload("res://sprites/grenade.png"),
	"lightning": preload("res://sprites/lightning.png"),
	"orbital": preload("res://sprites/orbital.png"),
	"pulse": preload("res://sprites/pulse.png")
}

func _ready():
	add_to_group("hud")
	# Wait one frame for everything to be ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	dialogue_splash = get_node_or_null("/root/Main/DialogueSplash")
	
	# Load high score from game manager
	var game_manager = GameManager
	if game_manager:
		high_score = game_manager.high_score
		gems = game_manager.gems
	
	if not player:
		print("Warning: HUD couldn't find player!")
	
	if not dialogue_splash:
		print("Warning: HUD couldn't find DialogueSplash!")
	
	# Create lives label if it doesn't exist
	if not lives_label:
		lives_label = Label.new()
		lives_label.name = "LivesLabel"
		$Control.add_child(lives_label)
		lives_label.add_theme_font_size_override("font_size", 20)
		lives_label.anchor_left = 1.0
		lives_label.anchor_right = 1.0
		lives_label.offset_left = -100
		lives_label.offset_right = -10
		lives_label.offset_top = 10
		lives_label.offset_bottom = 40
		lives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	# Create weapon slots
	create_weapon_slots()

func _process(delta):
	if player:
		health_label.text = "Health: %d/%d" % [player.health, player.max_health]
		
		# Update health progress bar
		if health_progress_bar:
			var health_percent = (float(player.health) / float(player.max_health)) * 100 if player.max_health > 0 else 0
			health_progress_bar.value = clamp(health_percent, 0, 100)
		
		# Update gold progress bar (show progress from last threshold to next)
		if gold_progress_bar:
			var prev_threshold = calculate_previous_threshold()
			var next_threshold = calculate_next_threshold()
			var gold_since_last = gold - prev_threshold
			var threshold_range = next_threshold - prev_threshold
			var progress = float(gold_since_last) / float(threshold_range) if threshold_range > 0 else 0.0
			gold_progress_bar.value = clamp(progress * 100, 0, 100)
	
	score_label.text = "Score: %d" % score
	gold_label.text = "Gold: %d / %d" % [gold, calculate_next_threshold() if player else 0]
	gem_label.text = "Gems: %d" % gems
	
	# Update lives display
	if lives_label and player and "lives" in player:
		var heart_text = ""
		for i in range(player.lives):
			heart_text += "♥ "
		lives_label.text = heart_text.strip_edges()
		# Color red
		lives_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	
	if high_score_label:
		high_score_label.text = "High Score: %d" % high_score

func add_score(amount):
	score += amount
	
	# Update high score if current score exceeds it
	if score > high_score:
		high_score = score
	
	# Check if we've hit a dialogue threshold
	if dialogue_splash:
		dialogue_splash.check_score_threshold(score)

func update_gold(amount):
	gold = amount

func calculate_next_threshold() -> int:
	# Match the threshold calculation from upgrade_menu
	# Threshold for current level
	if player:
		return int(50 * pow(2, player.player_level))
	return 100

func calculate_previous_threshold() -> int:
	# Calculate the previous level's threshold
	if player and player.player_level > 1:
		return int(50 * pow(2, player.player_level - 1))
	return 0

func create_weapon_slots():
	# Create container if it doesn't exist
	if not weapon_slots_container:
		weapon_slots_container = HBoxContainer.new()
		weapon_slots_container.name = "WeaponSlotsContainer"
		$Control.add_child(weapon_slots_container)
		weapon_slots_container.add_theme_constant_override("separation", 5)
		
		# Center horizontally at top of screen
		weapon_slots_container.anchor_left = 0.5
		weapon_slots_container.anchor_right = 0.5
		weapon_slots_container.anchor_top = 0.0
		weapon_slots_container.offset_top = 10
	
	# Clear existing slots
	for slot in weapon_slots:
		if is_instance_valid(slot):
			slot.queue_free()
	weapon_slots.clear()
	
	# Get max weapon slots from player
	var max_slots = 6  # Default
	if player and "max_weapon_slots" in player:
		max_slots = player.max_weapon_slots
	
	# Update container offset for centering
	var slot_width = 40
	var separation = 5
	var total_width = max_slots * slot_width + (max_slots - 1) * separation
	weapon_slots_container.offset_left = -total_width / 2
	
	# Create weapon slot panels
	for i in range(max_slots):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(40, 40)
		
		# Create texture rect for weapon sprite
		var texture_rect = TextureRect.new()
		texture_rect.name = "WeaponTexture"
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_rect.offset_left = 4
		texture_rect.offset_top = 4
		texture_rect.offset_right = -4
		texture_rect.offset_bottom = -4
		
		# Create label for fallback text (for weapons without sprites)
		var label = Label.new()
		label.name = "WeaponLabel"
		label.text = ""
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 20)
		
		slot_panel.add_child(texture_rect)
		slot_panel.add_child(label)
		weapon_slots_container.add_child(slot_panel)
		weapon_slots.append(slot_panel)
	
	update_weapon_slots()

func update_weapon_slots():
	if not player:
		return
	
	var slot_index = 0
	var max_slots = weapon_slots.size()  # Use actual slot count
	for weapon_name in ["bullet", "pulse", "orbital", "boomerang", "lightning", "grenade", "meteor", "healing_aura"]:
		if player.unlocked_weapons[weapon_name]:
			if slot_index < max_slots:
				var slot_panel = weapon_slots[slot_index]
				var texture_rect = slot_panel.get_node("WeaponTexture")
				var label = slot_panel.get_node("WeaponLabel")
				
				# Use sprite if available, otherwise use text
				if weapon_name in weapon_sprites:
					texture_rect.texture = weapon_sprites[weapon_name]
					label.text = ""
					
					# Apply weapon-specific scaling
					if weapon_name == "boomerang":
						texture_rect.scale = Vector2(0.5, 0.5)
					elif weapon_name == "bullet":
						texture_rect.scale = Vector2(0.9, 0.9)
					elif weapon_name == "meteor":
						texture_rect.scale = Vector2(1.4, 1.4)
					elif weapon_name == "grenade":
						texture_rect.scale = Vector2(0.8, 0.8)				
					elif weapon_name == "lightning":
						texture_rect.scale = Vector2(1, 1)									
					elif weapon_name == "orbital":
						texture_rect.scale = Vector2(0.8, 0.8)					
					else:
						texture_rect.scale = Vector2(1.0, 1.0)
				else:
					texture_rect.texture = null
					label.text = weapon_display_names[weapon_name]
				
				# Make the panel more visible
				var style = StyleBoxFlat.new()
				style.bg_color = Color(0.3, 0.6, 0.3, 0.8)
				style.border_width_left = 2
				style.border_width_top = 2
				style.border_width_right = 2
				style.border_width_bottom = 2
				style.border_color = Color(0.5, 0.9, 0.5, 1.0)
				slot_panel.add_theme_stylebox_override("panel", style)
				slot_index += 1
