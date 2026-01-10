extends Node

class_name Weapon

var damage: int
var fire_rate: float
var range: float
var projectile_scene: PackedScene

func _ready():
    # Initialize weapon properties
    damage = 10
    fire_rate = 1.0
    range = 300.0

func fire(position: Vector2, direction: Vector2):
    if projectile_scene:
        var projectile = projectile_scene.instantiate()
        projectile.position = position
        projectile.set_direction(direction)
        get_parent().add_child(projectile)

func upgrade(new_damage: int, new_fire_rate: float, new_range: float):
    damage = new_damage
    fire_rate = new_fire_rate
    range = new_range