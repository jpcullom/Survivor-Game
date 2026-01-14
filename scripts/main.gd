extends Node2D

var upgrade_menu_scene = preload("res://scenes/ui/upgrade_menu.tscn")
var title_screen_scene = preload("res://scenes/ui/title_screen.tscn")

func _ready():
	print("[MAIN] Game started!")
	print("[MAIN] Tree paused status before pause: ", get_tree().paused)
	# Pause immediately for title screen
	get_tree().paused = true
	print("[MAIN] Tree paused status after pause: ", get_tree().paused)
	
	# Make sure window has focus for input
	get_window().grab_focus()
	
	# Show title screen
	print("[MAIN] Instantiating title screen...")
	var title_screen = title_screen_scene.instantiate()
	add_child(title_screen)
	print("[MAIN] Title screen added to tree")
	
	# Load and play background music
	var music_player = $BackgroundMusic
	if music_player:
		var music = load("res://audio/retro-8bit-happy-videogame-music-246631.mp3")
		music_player.stream = music
		music_player.volume_db = -10  # Adjust volume as needed
		if music is AudioStream:
			music.loop = true  # Enable looping
		music_player.play()
		print("Background music started")
	
	# Manually instantiate and add upgrade menu
	print("Loading upgrade menu scene...")
	var upgrade_menu = upgrade_menu_scene.instantiate()
	add_child(upgrade_menu)
	print("Upgrade menu added to scene tree")
