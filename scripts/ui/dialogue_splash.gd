extends CanvasLayer

@onready var dimmer = $Dimmer
@onready var dialogue_container = $DialogueContainer
@onready var portrait = $DialogueContainer/Portrait
@onready var coyote_portrait = $DialogueContainer/CoyotePortrait
@onready var text_box = $DialogueContainer/TextBox
@onready var coyote_text_box = $DialogueContainer/CoyoteTextBox
@onready var dialogue_label = $DialogueContainer/TextBox/VBoxContainer/DialogueLabel
@onready var coyote_dialogue_label = $DialogueContainer/CoyoteTextBox/VBoxContainer/DialogueLabel
@onready var continue_label = $DialogueContainer/TextBox/ContinueLabel
@onready var coyote_continue_label = $DialogueContainer/CoyoteTextBox/ContinueLabel

var dialogue_queue = []
var current_dialogue_index = 0
var is_displaying = false

# Dictionary mapping score thresholds to dialogue
# Each entry is now a dictionary with 'character' ("frog" or "coyote") and 'text'
var threshold_dialogues = {
	1000: [
		{"character": "frog", "text": "What is this? Some kind of desert?"},
		{"character": "coyote", "text": "Howdy there, frog."},
		{"character": "frog", "text": "Ew you're gross, I'm gonna beat you up with my gun."},
		{"character": "frog", "text": "Unlucky for you, I'm good at shooting stuff."}
	],
	5000: [
		{"character": "frog", "text": "You guys are weird. I hate you."},
		{"character": "coyote", "text": "Please stop that's really mean."},
		{"character": "frog", "text": "Sorry."},
		{"character": "frog", "text": "I'm gonna keep shooting you and using my powerups on you though."},
		{"character": "coyote", "text": "Aw man :("},
	],
	10000: [
		{"character": "frog", "text": "I don't want to live anymore, all I know is violence."},
		{"character": "coyote", "text": "So does that mean you'll stop?"},
		{"character": "frog", "text": "..."},
		{"character": "frog", "text": "No."}
	]
}

var displayed_thresholds = []

func _ready():
	add_to_group("dialogue_splash")
	hide_dialogue()
	set_process_input(true)

func _input(event):
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
	
	# Get current dialogue entry
	var dialogue_entry = dialogue_queue[current_dialogue_index]
	var character = dialogue_entry["character"]
	var text = dialogue_entry["text"]
	
	# Show/hide appropriate portrait and text box
	if character == "frog":
		portrait.visible = true
		coyote_portrait.visible = false
		text_box.visible = true
		coyote_text_box.visible = false
		dialogue_label.text = text
		continue_label.visible = true
	elif character == "coyote":
		portrait.visible = false
		coyote_portrait.visible = true
		text_box.visible = false
		coyote_text_box.visible = true
		coyote_dialogue_label.text = text
		coyote_continue_label.visible = true

func advance_dialogue():
	print("[DIALOGUE] advance_dialogue called, index: ", current_dialogue_index)
	current_dialogue_index += 1
	
	if current_dialogue_index >= dialogue_queue.size():
		print("[DIALOGUE] All dialogue shown, hiding...")
		hide_dialogue()
	else:
		print("[DIALOGUE] Showing next dialogue line")
		var dialogue_entry = dialogue_queue[current_dialogue_index]
		var character = dialogue_entry["character"]
		var text = dialogue_entry["text"]
		
		# Show/hide appropriate portrait and text box
		if character == "frog":
			portrait.visible = true
			coyote_portrait.visible = false
			text_box.visible = true
			coyote_text_box.visible = false
			dialogue_label.text = text
		elif character == "coyote":
			portrait.visible = false
			coyote_portrait.visible = true
			text_box.visible = false
			coyote_text_box.visible = true
			coyote_dialogue_label.text = text

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
		print("[DIALOGUE] Unpausing game")
		get_tree().paused = false
	)

func check_score_threshold(score: int):
	for threshold in threshold_dialogues.keys():
		if score >= threshold and threshold not in displayed_thresholds:
			print("[DIALOGUE] Threshold ", threshold, " reached!")
			show_dialogue_for_threshold(threshold)
			break

func show_frog_overload():
	print("[DIALOGUE] FROG OVERLOAD TRIGGERED!")
	is_displaying = true
	get_tree().paused = true
	
	# Show UI elements with animation
	dimmer.visible = true
	dialogue_container.visible = true
	
	# Animate dimmer fade in
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(dimmer, "modulate:a", 0.7, 0.3)
	
	# Display FROG OVERLOAD message
	dialogue_label.text = "FROOOOOOG OVERLOOOOAD!!!"
	continue_label.visible = true
	
	# Auto-hide after a short delay
	await get_tree().create_timer(2.0, true, false, true).timeout
	hide_dialogue()
