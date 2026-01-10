extends Node

class_name UpgradeSystem

var upgrades = []
var selected_upgrade = null

func _ready():
    initialize_upgrades()

func initialize_upgrades():
    upgrades.append({"name": "Health Boost", "description": "Increase maximum health by 20.", "effect": apply_health_boost})
    upgrades.append({"name": "Damage Increase", "description": "Increase weapon damage by 10%.", "effect": apply_damage_increase})
    upgrades.append({"name": "Speed Boost", "description": "Increase movement speed by 15%.", "effect": apply_speed_boost})

func apply_health_boost():
    # Logic to increase player's maximum health
    pass

func apply_damage_increase():
    # Logic to increase player's weapon damage
    pass

func apply_speed_boost():
    # Logic to increase player's movement speed
    pass

func select_upgrade(index):
    if index >= 0 and index < upgrades.size():
        selected_upgrade = upgrades[index]
        selected_upgrade["effect"].call()  # Apply the selected upgrade

func get_available_upgrades():
    return upgrades