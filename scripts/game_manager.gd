extends Node

# GameManager class to handle the overall game state
class_name GameManager

var is_game_running: bool = false
var score: int = 0
var level: int = 1
var high_score: int = 0

const SAVE_FILE_PATH = "user://savegame.save"

# Called when the node enters the scene tree for the first time.
func _ready():
    load_game()
    start_game()

# Function to save game data
func save_game():
    var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if save_file:
        var save_data = {
            "high_score": high_score
        }
        save_file.store_string(JSON.stringify(save_data))
        save_file.close()
        print("[GameManager] Game saved! High score: ", high_score)
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
                print("[GameManager] Game loaded! High score: ", high_score)
            else:
                print("[GameManager] Failed to parse save file")
        else:
            print("[GameManager] Failed to open save file")
    else:
        print("[GameManager] No save file found, starting fresh")
        high_score = 0

# Function to start the game
func start_game():
    is_game_running = true
    score = 0
    level = 1
    # Initialize other game elements here

# Function to pause the game
func pause_game():
    is_game_running = false
    # Implement pause logic here

# Function to resume the game
func resume_game():
    is_game_running = true
    # Implement resume logic here

# Function to end the game
func end_game():
    is_game_running = false
    # Check and update high score
    if score > high_score:
        high_score = score
        print("[GameManager] New high score: ", high_score)
        save_game()
    # Implement game over logic here
    # Show final score and other relevant information

# Function to update the score
func update_score(points: int):
    score += points
    # Update score display in HUD if necessary

# Function to advance to the next level
func next_level():
    level += 1
    # Implement level transition logic here