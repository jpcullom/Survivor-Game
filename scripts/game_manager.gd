extends Node

# GameManager class to handle the overall game state
class_name GameManager

var is_game_running: bool = false
var score: int = 0
var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    start_game()

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