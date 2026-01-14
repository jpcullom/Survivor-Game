extends CanvasLayer

@onready var dimmer = $Dimmer
@onready var title_image = $TitleImage
@onready var start_label = $StartLabel

var is_showing = true

func _ready():
	print("[TITLE] Title screen _ready() called")
	print("[TITLE] Tree paused status: ", get_tree().paused)
	# Game should already be paused from main.gd
	is_showing = true
	
	# Fade in the title screen
	dimmer.modulate.a = 0
	title_image.modulate.a = 0
	start_label.modulate.a = 0
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(title_image, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(start_label, "modulate:a", 1.0, 0.5)
	
	# Make the "Press to Start" text blink
	start_blink_animation()

func _input(event):
	print("[TITLE] _input called, is_showing=", is_showing)
	if not is_showing:
		return
	
	if event.is_action_pressed("ui_accept"):
		print("[TITLE] Space pressed, starting game...")
		start_game()
	elif event is InputEventMouseButton and event.pressed:
		print("[TITLE] Mouse clicked, starting game...")
		start_game()

func start_game():
	print("[TITLE] start_game() called")
	if not is_showing:
		return
		
	is_showing = false
	print("[TITLE] Unpausing game...")
	
	# Mark that the game has started so dialogue can unpause
	var dialogue_splash = get_node_or_null("/root/Main/DialogueSplash")
	if dialogue_splash and dialogue_splash.has_method("mark_game_started"):
		dialogue_splash.mark_game_started()
	
	# Fade out
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(dimmer, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(title_image, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(start_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		get_tree().paused = false
		queue_free()
	)

func start_blink_animation():
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_loops()
	tween.tween_property(start_label, "modulate:a", 0.3, 0.8)
	tween.tween_property(start_label, "modulate:a", 1.0, 0.8)
