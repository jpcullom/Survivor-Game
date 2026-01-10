extends CanvasLayer

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel

func _ready():
	# Hide by default
	hide()

func show_game_over(final_score: int):
	score_label.text = "Final Score: %d" % final_score
	show()
	# Pause the game but allow UI to still function
	get_tree().paused = true

func _on_restart_button_pressed():
	# Unpause the game
	get_tree().paused = false
	# Reload the current scene
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
