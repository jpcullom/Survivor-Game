extends CanvasLayer

@onready var dimmer = $Dimmer
@onready var dialogue_container = $DialogueContainer
@onready var portrait = $DialogueContainer/Portrait
@onready var text_box = $DialogueContainer/TextBox
@onready var dialogue_label = $DialogueContainer/TextBox/VBoxContainer/DialogueLabel
@onready var continue_label = $DialogueContainer/TextBox/ContinueLabel

var dialogue_queue = []
var current_dialogue_index = 0
var is_displaying = false
var game_started = false

# Dictionary mapping score thresholds to dialogue
var threshold_dialogues = {
	1000: [
		"You dumb dog guys, I'm gonna kill every last one of you!",
		"I'm gonna beat you up with my gun.",
		"I'm a frog okay? Get over it."
	],
	5000: [
		"Are you for real dog things? What's going on? I have dementia.",
		"Ffffffffff- I mean, oh crap. That's a lot of dog guy blood on my hands.",
		"Ohhhh, are those guys coyotes? I've been calling them dogs this whole time.",
	],
	10000: [
		"I don't want to live anymore, all I know is violence.",
		"My gun is tired of killing you.",
		"Take this motherfroggers!"
	]
}

var displayed_thresholds = []

func _ready():
	hide_dialogue()
	set_process_input(true)

func mark_game_started():
	game_started = true

func _input(event):
	print("[DIALOGUE] _input called, is_displaying=", is_displaying)
	if not is_displaying:
		return
		
	if event.is_action_pressed("ui_accept"):
		print("[DIALOGUE] ui_accept pressed!")
		advance_dialogue()
	elif event is InputEventMouseButton and event.pressed:
		print("[DIALOGUE] Mouse button pressed!")
		advance_dialogue()

func show_dialogue_for_threshold(threshold: int):
	if threshold in displayed_thresholds:
		return
		
	if threshold not in threshold_dialogues:
		return
		
	displayed_thresholds.append(threshold)
	dialogue_queue = threshold_dialogues[threshold].duplicate()
	current_dialogue_index = 0
	display_next_dialogue()

func display_next_dialogue():
	if current_dialogue_index >= dialogue_queue.size():
		hide_dialogue()
		return
	
	print("[DIALOGUE] Displaying dialogue index: ", current_dialogue_index)
	is_displaying = true
	get_tree().paused = true
	print("[DIALOGUE] Game paused, is_displaying set to true")
	
	# Show UI elements with animation
	dimmer.visible = true
	dialogue_container.visible = true
	print("[DIALOGUE] Dimmer visible, current color: ", dimmer.color)
	print("[DIALOGUE] Dimmer modulate before tween: ", dimmer.modulate)
	
	# Animate dimmer fade in
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	print("[DIALOGUE] Tween created with pause mode TWEEN_PAUSE_PROCESS")
	tween.tween_property(dimmer, "modulate:a", 0.7, 0.3)
	
	# Display current dialogue
	dialogue_label.text = dialogue_queue[current_dialogue_index]
	continue_label.visible = true

func advance_dialogue():
	print("[DIALOGUE] advance_dialogue called, index: ", current_dialogue_index)
	current_dialogue_index += 1
	
	if current_dialogue_index >= dialogue_queue.size():
		print("[DIALOGUE] All dialogue shown, hiding...")
		hide_dialogue()
	else:
		print("[DIALOGUE] Showing next dialogue line")
		dialogue_label.text = dialogue_queue[current_dialogue_index]

func hide_dialogue():
	print("[DIALOGUE] hide_dialogue called")
	is_displaying = false
	
	# Animate fade out
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	print("[DIALOGUE] Fade out tween created")
	tween.tween_property(dimmer, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		print("[DIALOGUE] Tween callback: hiding elements")
		dimmer.visible = false
		dialogue_container.visible = false
		if game_started:
			print("[DIALOGUE] Unpausing game")
			get_tree().paused = false
		else:
			print("[DIALOGUE] Game not started yet, keeping paused")
	)

func check_score_threshold(score: int):
	print("[DIALOGUE] check_score_threshold called with score: ", score)
	for threshold in threshold_dialogues.keys():
		if score >= threshold and threshold not in displayed_thresholds:
			print("[DIALOGUE] Threshold ", threshold, " reached!")
			show_dialogue_for_threshold(threshold)
			break
