extends CanvasLayer

@onready var health_label = $Control/HealthContainer/HealthLabel
@onready var score_label = $Control/ScoreLabel
@onready var gold_label = $Control/GoldLabel

var player = null
var score = 0
var gold = 0
var dialogue_splash = null

func _ready():
	# Wait one frame for everything to be ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	dialogue_splash = get_node_or_null("/root/Main/DialogueSplash")
	
	if not player:
		print("Warning: HUD couldn't find player!")
	
	if not dialogue_splash:
		print("Warning: HUD couldn't find DialogueSplash!")

func _process(delta):
	if player:
		health_label.text = "Health: %d/%d" % [player.health, player.max_health]
	
	score_label.text = "Score: %d" % score
	gold_label.text = "Gold: %d" % gold

func add_score(amount):
	score += amount
	
	# Check if we've hit a dialogue threshold
	if dialogue_splash:
		dialogue_splash.check_score_threshold(score)

func update_gold(amount):
	gold = amount
