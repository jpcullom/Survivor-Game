extends CanvasLayer

@onready var gem_count_label = $Control/MarginContainer/VBoxContainer/Header/GemCountLabel
@onready var skills_container = $Control/MarginContainer/VBoxContainer/ScrollContainer/SkillsContainer
@onready var scroll_container = $Control/MarginContainer/VBoxContainer/ScrollContainer
@onready var start_game_button = $Control/MarginContainer/VBoxContainer/ButtonContainer/StartGameButton
@onready var clear_data_button = $Control/ClearDataButton

var game_manager = null
var skill_tree = null
var purchasable_buttons = []  # Array of buttons that can be interacted with
var selected_index = 0  # Currently selected button index

func _ready():
	print("[SkillTree] _ready() called")
	print("[SkillTree] Pause state on load: ", get_tree().paused)
	
	# Unpause so menu can receive input
	get_tree().paused = false
	
	# Get game manager reference (autoload singleton)
	game_manager = GameManager
	if not game_manager:
		print("[SkillTreeMenu] Error: Could not find GameManager")
		return
	
	print("[SkillTree] Found GameManager with ", game_manager.gems, " gems")
	
	# Create skill tree instance
	skill_tree = load("res://scripts/skill_tree.gd").new()
	skill_tree._initialize_skill_tree()
	
	# Display current gems
	update_gem_count()
	
	# Display all skills organized by tier
	display_skills()

func _input(event):
	if event.is_action_pressed("ui_down"):
		print("[SkillTree] Down arrow pressed")
		select_next()
		if get_viewport():
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		print("[SkillTree] Up arrow pressed")
		select_previous()
		if get_viewport():
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		print("[SkillTree] Enter/Space pressed")
		activate_selected()
		if get_viewport():
			get_viewport().set_input_as_handled()

func select_next():
	if purchasable_buttons.size() == 0:
		return
	
	selected_index = (selected_index + 1) % purchasable_buttons.size()
	print("[SkillTree] Selected index: ", selected_index, "/", purchasable_buttons.size())
	update_selection()

func select_previous():
	if purchasable_buttons.size() == 0:
		return
	
	selected_index = (selected_index - 1 + purchasable_buttons.size()) % purchasable_buttons.size()
	print("[SkillTree] Selected index: ", selected_index, "/", purchasable_buttons.size())
	update_selection()

func update_selection():
	if purchasable_buttons.size() == 0:
		return
	
	# Remove highlight from all buttons
	for i in range(purchasable_buttons.size()):
		var button = purchasable_buttons[i]
		if i == selected_index:
			button.modulate = Color(1.5, 1.5, 0.8)  # Bright highlight
			button.grab_focus()
			
			# Special handling for buttons outside the scroll container
			if button == start_game_button or button == clear_data_button:
				print("[SkillTree] Special button selected: ", button.text)
				# No scrolling needed for buttons outside scroll container
			else:
				# Scroll to make button visible
				await get_tree().process_frame  # Wait for layout
				var panel = button.get_parent().get_parent()  # Get the PanelContainer
				var button_global_pos = panel.global_position.y
				var scroll_global_pos = scroll_container.global_position.y
				var relative_pos = button_global_pos - scroll_global_pos
				
				print("[SkillTree] Button global Y: ", button_global_pos, ", Scroll global Y: ", scroll_global_pos, ", Relative: ", relative_pos)
				
				# If button is below visible area, scroll down
				if relative_pos > scroll_container.size.y - 100:
					scroll_container.scroll_vertical += int(relative_pos - scroll_container.size.y + 100)
				# If button is above visible area, scroll up
				elif relative_pos < 0:
					scroll_container.scroll_vertical += int(relative_pos)
				
				print("[SkillTree] Scroll position: ", scroll_container.scroll_vertical)
		else:
			# Reset to original color based on button state
			if button == start_game_button:
				button.modulate = Color(1, 1, 1)  # White for Start Game
			elif button.disabled:
				if "LOCKED" in button.text:
					button.modulate = Color(0.5, 0.5, 0.5)
				elif "UNLOCKED" in button.text:
					button.modulate = Color(0.5, 1, 0.5)
				else:
					button.modulate = Color(1, 0.5, 0.5)
			else:
				button.modulate = Color(1, 1, 0.5)

func activate_selected():
	if purchasable_buttons.size() == 0 or selected_index >= purchasable_buttons.size():
		print("[SkillTree] Cannot activate - invalid index")
		return
	
	var button = purchasable_buttons[selected_index]
	print("[SkillTree] Activating button at index ", selected_index)
	print("[SkillTree] Button disabled: ", button.disabled)
	print("[SkillTree] Button text: ", button.text)
	
	if not button.disabled:
		print("[SkillTree] Emitting pressed signal")
		button.pressed.emit()
	else:
		print("[SkillTree] Button is disabled, cannot activate")

func update_gem_count():
	if game_manager:
		gem_count_label.text = "Gems: %d" % game_manager.gems

func display_skills():
	# Clear existing skills
	for child in skills_container.get_children():
		child.queue_free()
	
	# Reset purchasable buttons array
	purchasable_buttons.clear()
	selected_index = 0
	
	# Add Clear Data button to navigation (at the top)
	purchasable_buttons.append(clear_data_button)
	
	# Group skills by tier
	var tier_1_skills = []
	var tier_2_skills = []
	var tier_3_skills = []
	
	for skill_id in skill_tree.skill_nodes:
		var skill = skill_tree.skill_nodes[skill_id]
		if skill.prerequisites.size() == 0:
			tier_1_skills.append(skill)
		elif skill.cost >= 15:
			tier_3_skills.append(skill)
		else:
			tier_2_skills.append(skill)
	
	# Display Tier 1
	add_tier_header("TIER 1 - FOUNDATION", Color(0.5, 1, 0.5))
	for skill in tier_1_skills:
		add_skill_button(skill)
	
	# Display Tier 2
	add_tier_header("TIER 2 - ADVANCED", Color(0.5, 0.8, 1))
	for skill in tier_2_skills:
		add_skill_button(skill)
	
	# Display Tier 3
	add_tier_header("TIER 3 - MASTERY", Color(1, 0.8, 0.3))
	for skill in tier_3_skills:
		add_skill_button(skill)
	
	# Add Start Game button to navigation
	purchasable_buttons.append(start_game_button)
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	
	# Initialize selection on first available button
	if purchasable_buttons.size() > 0:
		update_selection()

func add_tier_header(title: String, color: Color):
	var header = Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 20)
	header.modulate = color
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skills_container.add_child(header)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	skills_container.add_child(spacer)

func add_skill_button(skill):
	var is_unlocked = skill.id in game_manager.unlocked_skills
	var can_purchase = skill_tree.can_purchase_skill(skill.id, game_manager.unlocked_skills, game_manager.gems)
	var prerequisites_met = true
	for prereq in skill.prerequisites:
		if not prereq in game_manager.unlocked_skills:
			prerequisites_met = false
			break
	
	# Create skill panel
	var panel = PanelContainer.new()
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)
	
	# Skill info (left side)
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Skill name
	var name_label = Label.new()
	name_label.text = skill.name
	name_label.add_theme_font_size_override("font_size", 18)
	if is_unlocked:
		name_label.modulate = Color(0.5, 1, 0.5)  # Green for unlocked
	elif not prerequisites_met:
		name_label.modulate = Color(0.5, 0.5, 0.5)  # Gray for locked
	info_vbox.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = skill.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_label)
	
	# Prerequisites
	if skill.prerequisites.size() > 0:
		var prereq_text = "Requires: "
		for i in range(skill.prerequisites.size()):
			var prereq_id = skill.prerequisites[i]
			var prereq_skill = skill_tree.get_skill(prereq_id)
			if prereq_skill:
				prereq_text += prereq_skill.name
				if i < skill.prerequisites.size() - 1:
					prereq_text += ", "
		var prereq_label = Label.new()
		prereq_label.text = prereq_text
		prereq_label.add_theme_font_size_override("font_size", 12)
		prereq_label.modulate = Color(0.8, 0.8, 0.8)
		info_vbox.add_child(prereq_label)
	
	hbox.add_child(info_vbox)
	
	# Purchase button (right side)
	var button = Button.new()
	button.custom_minimum_size = Vector2(120, 60)
	
	if is_unlocked:
		button.text = "UNLOCKED"
		button.disabled = true
		button.modulate = Color(0.5, 1, 0.5)
	elif not prerequisites_met:
		button.text = "LOCKED"
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5)
	elif can_purchase:
		button.text = "Purchase\n%d Gems" % skill.cost
		button.pressed.connect(_on_skill_purchased.bind(skill.id))
		button.modulate = Color(1, 1, 0.5)
	else:
		button.text = "%d Gems\n(Need %d)" % [skill.cost, skill.cost - game_manager.gems]
		button.disabled = true
		button.modulate = Color(1, 0.5, 0.5)
	
	# Add all buttons to navigation (so you can browse even locked skills)
	purchasable_buttons.append(button)
	
	hbox.add_child(button)
	
	skills_container.add_child(panel)

func _on_skill_purchased(skill_id: String):
	if not game_manager or not skill_tree:
		return
	
	var skill = skill_tree.get_skill(skill_id)
	if not skill:
		return
	
	# Check if we can actually purchase
	if not skill_tree.can_purchase_skill(skill_id, game_manager.unlocked_skills, game_manager.gems):
		return
	
	# Deduct gems
	game_manager.gems -= skill.cost
	
	# Add skill to unlocked list
	game_manager.unlocked_skills.append(skill_id)
	
	# Save immediately
	game_manager.save_game()
	
	print("[SkillTreeMenu] Purchased skill: ", skill.name)
	
	# Refresh display
	update_gem_count()
	display_skills()

func _on_start_game_button_pressed():
	print("[SkillTree] Start Game button pressed!")
	print("[SkillTree] Current pause state: ", get_tree().paused)
	# Unpause the game and load main scene
	get_tree().paused = false
	print("[SkillTree] Pause state after unpause: ", get_tree().paused)
	print("[SkillTree] Changing scene to main.tscn...")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_clear_data_button_pressed():
	print("[SkillTree] Clear Data button pressed!")
	if game_manager:
		game_manager.clear_save_data()
		# Refresh the display to show 0 gems and no unlocked skills
		update_gem_count()
		display_skills()
		print("[SkillTree] Save data cleared and display refreshed")
