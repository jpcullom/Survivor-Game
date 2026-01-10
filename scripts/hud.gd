extends CanvasLayer

@onready var health_label = $Control/HealthContainer/HealthLabel
@onready var score_label = $Control/ScoreLabel

var player = null
var score = 0

func _ready():
	# Wait one frame for everything to be ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("Warning: HUD couldn't find player!")

func _process(delta):
	if player:
		health_label.text = "Health: %d/%d" % [player.health, player.max_health]
	
	score_label.text = "Score: %d" % score

func add_score(amount):
	score += amount
