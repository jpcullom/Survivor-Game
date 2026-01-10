extends Node2D

class_name WeaponBase

# Base stats that all weapons have
var damage: int = 10
var cooldown: float = 0.5
var attack_range: float = 100.0
var is_attacking: bool = false

# Reference to player
var player: CharacterBody2D = null

func _ready():
	pass

# Override this in child classes
func attack():
	pass

# Check if weapon can attack
func can_attack() -> bool:
	return not is_attacking

# Start cooldown after attack
func start_cooldown():
	is_attacking = true
	await get_tree().create_timer(cooldown).timeout
	is_attacking = false
