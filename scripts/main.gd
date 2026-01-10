extends Node2D

var upgrade_menu_scene = preload("res://scenes/ui/upgrade_menu.tscn")

func _ready():
	print("Game started!")
	# Make sure window has focus for input
	get_window().grab_focus()
	
	# Manually instantiate and add upgrade menu
	print("Loading upgrade menu scene...")
	var upgrade_menu = upgrade_menu_scene.instantiate()
	add_child(upgrade_menu)
	print("Upgrade menu added to scene tree")
