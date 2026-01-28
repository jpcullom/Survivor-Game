extends Node

# GameManager - Autoload singleton to handle the overall game state
# Note: No class_name needed since it's an autoload

var is_game_running: bool = false
var score: int = 0
var level: int = 1
var high_score: int = 0
var gems: int = 0  # Permanent currency for meta-progression
var unlocked_skills: Array = []  # Array of unlocked skill tree nodes

const SAVE_FILE_PATH = "user://savegame.save"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()
	# Don't auto-start game - let the title screen handle flow

# Function to save game data
func save_game():
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"high_score": high_score,
			"gems": gems,
			"unlocked_skills": unlocked_skills
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("[GameManager] Game saved! High score: ", high_score, ", Gems: ", gems)
	else:
		print("[GameManager] Failed to save game")

# Function to load game data
func load_game():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var save_data = json.data
				high_score = save_data.get("high_score", 0)
				gems = save_data.get("gems", 0)
				unlocked_skills = save_data.get("unlocked_skills", [])
				print("[GameManager] Game loaded! High score: ", high_score, ", Gems: ", gems, ", Skills: ", unlocked_skills.size())
			else:
				print("[GameManager] Failed to parse save file")
		else:
			print("[GameManager] Failed to open save file")
	else:
		print("[GameManager] No save file found, starting fresh")
		high_score = 0
		gems = 0
		unlocked_skills = []

# Function to clear save data
func clear_save_data():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("[GameManager] Save file deleted")
	
	# Reset values
	high_score = 0
	gems = 0
	unlocked_skills = []
	print("[GameManager] Save data cleared!")

# Function to start the game
func start_game():
	is_game_running = true
	score = 0
	level = 1

# Function to end the game
func end_game():
	is_game_running = false
	# Always save to persist gems and skill progress
	save_game()
