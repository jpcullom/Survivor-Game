extends Node2D

class_name HealingAuraWeapon

var player = null
var heal_amount = 2  # Health restored per tick
var heal_interval = 10.0  # Seconds between heals
var cooldown: float = 10.0
var is_ready: bool = true
var auto_attack_timer: float = 0.0

# Visual effect
var aura_circle: Sprite2D = null
var aura_radius = 80.0

func _ready():
	set_process(true)
	create_aura_visual()
	print("[HealingAura] Healing weapon initialized - Heals ", heal_amount, " HP every ", heal_interval, " seconds")

func create_aura_visual():
	# Create a simple green circle to show the healing aura
	aura_circle = Sprite2D.new()
	add_child(aura_circle)
	
	# Create a circular texture
	var image = Image.create(160, 160, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	
	# Draw a green circle
	for x in range(160):
		for y in range(160):
			var dx = x - 80
			var dy = y - 80
			var distance = sqrt(dx * dx + dy * dy)
			if distance < aura_radius and distance > aura_radius - 10:
				var alpha = 0.3 * (1.0 - abs(distance - (aura_radius - 5)) / 5.0)
				image.set_pixel(x, y, Color(0.2, 1.0, 0.3, alpha))
	
	var texture = ImageTexture.create_from_image(image)
	aura_circle.texture = texture
	aura_circle.modulate = Color(0.2, 1.0, 0.3, 0.5)
	
	# Pulse animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(aura_circle, "scale", Vector2(1.1, 1.1), 1.0)
	tween.tween_property(aura_circle, "scale", Vector2(0.9, 0.9), 1.0)

func start_cooldown() -> void:
	is_ready = false
	await get_tree().create_timer(cooldown).timeout
	is_ready = true

func can_attack() -> bool:
	return is_ready and player != null

func attack():
	if not can_attack():
		return
	
	heal_player()
	start_cooldown()

func heal_player():
	if not player:
		return
	
	# Heal the player
	var old_health = player.health
	player.health = min(player.health + heal_amount, player.max_health)
	var actual_heal = player.health - old_health
	
	if actual_heal > 0:
		print("[HealingAura] Healed player for ", actual_heal, " HP (", player.health, "/", player.max_health, ")")
		
		# Visual feedback - flash the aura
		if aura_circle:
			var flash_tween = create_tween()
			flash_tween.tween_property(aura_circle, "modulate:a", 0.8, 0.1)
			flash_tween.tween_property(aura_circle, "modulate:a", 0.5, 0.3)

func _process(delta):
	if not player:
		return
	
	# Auto-attack on cooldown
	auto_attack_timer += delta
	if auto_attack_timer >= cooldown and can_attack():
		auto_attack_timer = 0
		attack()
	
	# Follow player
	global_position = player.global_position

# Upgrade functions
func upgrade_heal_amount():
	heal_amount += 1
	print("[HealingAura] Heal amount increased to: ", heal_amount)

func upgrade_heal_rate():
	cooldown = max(2.0, cooldown - 2.0)
	print("[HealingAura] Heal interval reduced to: ", cooldown, " seconds")

func upgrade_aura_size():
	aura_radius += 15.0
	if aura_circle:
		var scale_factor = aura_radius / 80.0
		aura_circle.scale = Vector2(scale_factor, scale_factor)
	print("[HealingAura] Aura radius increased to: ", aura_radius)
