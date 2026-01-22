extends Node

# Skill Tree System for permanent meta-progression
# Skills are purchased with gems and persist between runs

class_name SkillTree

# Skill node definition
class SkillNode:
	var id: String
	var name: String
	var description: String
	var cost: int  # Gem cost
	var prerequisites: Array[String]  # IDs of required skills
	var stat_bonuses: Dictionary  # e.g., {"max_health": 10, "move_speed": 0.1}
	
	func _init(p_id: String, p_name: String, p_desc: String, p_cost: int, p_prereqs: Array[String] = [], p_bonuses: Dictionary = {}):
		id = p_id
		name = p_name
		description = p_desc
		cost = p_cost
		prerequisites = p_prereqs
		stat_bonuses = p_bonuses

# Define all skill nodes
var skill_nodes: Dictionary = {}

func _ready():
	_initialize_skill_tree()

func _initialize_skill_tree():
	# TIER 1 - Starting nodes (no prerequisites)
	skill_nodes["health_boost_1"] = SkillNode.new(
		"health_boost_1",
		"Vitality I",
		"Increase max health by 10",
		5,
		[],
		{"max_health": 10}
	)
	
	skill_nodes["speed_boost_1"] = SkillNode.new(
		"speed_boost_1",
		"Swiftness I",
		"Increase movement speed by 10%",
		5,
		[],
		{"move_speed": 0.1}
	)
	
	skill_nodes["damage_boost_1"] = SkillNode.new(
		"damage_boost_1",
		"Power I",
		"Increase all weapon damage by 10%",
		5,
		[],
		{"damage_multiplier": 0.1}
	)
	
	skill_nodes["pickup_range_1"] = SkillNode.new(
		"pickup_range_1",
		"Magnetism I",
		"Increase pickup range by 20",
		3,
		[],
		{"pickup_range": 20}
	)
	
	# TIER 2 - Intermediate nodes
	skill_nodes["health_boost_2"] = SkillNode.new(
		"health_boost_2",
		"Vitality II",
		"Increase max health by 20",
		10,
		["health_boost_1"],
		{"max_health": 20}
	)
	
	skill_nodes["speed_boost_2"] = SkillNode.new(
		"speed_boost_2",
		"Swiftness II",
		"Increase movement speed by 15%",
		10,
		["speed_boost_1"],
		{"move_speed": 0.15}
	)
	
	skill_nodes["damage_boost_2"] = SkillNode.new(
		"damage_boost_2",
		"Power II",
		"Increase all weapon damage by 15%",
		10,
		["damage_boost_1"],
		{"damage_multiplier": 0.15}
	)
	
	skill_nodes["starting_gold"] = SkillNode.new(
		"starting_gold",
		"Wealthy Start",
		"Start each run with 50 gold",
		8,
		[],
		{"starting_gold": 50}
	)
	
	skill_nodes["attack_speed_1"] = SkillNode.new(
		"attack_speed_1",
		"Quick Hands I",
		"Increase attack speed by 10%",
		7,
		[],
		{"attack_speed": 0.1}
	)
	
	# TIER 3 - Advanced nodes
	skill_nodes["health_boost_3"] = SkillNode.new(
		"health_boost_3",
		"Vitality III",
		"Increase max health by 30",
		20,
		["health_boost_2"],
		{"max_health": 30}
	)
	
	skill_nodes["extra_life"] = SkillNode.new(
		"extra_life",
		"Second Chance",
		"Start each run with 1 extra life",
		25,
		["health_boost_2"],
		{"extra_lives": 1}
	)
	
	skill_nodes["damage_boost_3"] = SkillNode.new(
		"damage_boost_3",
		"Power III",
		"Increase all weapon damage by 25%",
		20,
		["damage_boost_2"],
		{"damage_multiplier": 0.25}
	)
	
	skill_nodes["critical_chance"] = SkillNode.new(
		"critical_chance",
		"Critical Strike",
		"5% chance to deal double damage",
		15,
		["damage_boost_2"],
		{"critical_chance": 0.05}
	)
	
	skill_nodes["weapon_slot"] = SkillNode.new(
		"weapon_slot",
		"Arsenal Expansion",
		"Unlock 7th weapon slot",
		30,
		["damage_boost_2", "speed_boost_2"],
		{"max_weapon_slots": 1}
	)
	
	skill_nodes["exp_boost"] = SkillNode.new(
		"exp_boost",
		"Fast Learner",
		"Gain 20% more XP from kills",
		12,
		[],
		{"exp_multiplier": 0.2}
	)

# Check if a skill can be purchased
func can_purchase_skill(skill_id: String, unlocked_skills: Array, current_gems: int) -> bool:
	if not skill_nodes.has(skill_id):
		return false
	
	var skill = skill_nodes[skill_id]
	
	# Already unlocked?
	if skill_id in unlocked_skills:
		return false
	
	# Can afford?
	if current_gems < skill.cost:
		return false
	
	# Prerequisites met?
	for prereq in skill.prerequisites:
		if not prereq in unlocked_skills:
			return false
	
	return true

# Get all stat bonuses from unlocked skills
func get_total_bonuses(unlocked_skills: Array) -> Dictionary:
	var total_bonuses = {}
	
	for skill_id in unlocked_skills:
		if skill_nodes.has(skill_id):
			var skill = skill_nodes[skill_id]
			for stat in skill.stat_bonuses:
				if not total_bonuses.has(stat):
					total_bonuses[stat] = 0
				total_bonuses[stat] += skill.stat_bonuses[stat]
	
	return total_bonuses

# Get skill node by ID
func get_skill(skill_id: String) -> SkillNode:
	return skill_nodes.get(skill_id, null)

# Get all available skills (prerequisites met, not purchased)
func get_available_skills(unlocked_skills: Array, current_gems: int) -> Array:
	var available = []
	
	for skill_id in skill_nodes:
		if can_purchase_skill(skill_id, unlocked_skills, current_gems):
			available.append(skill_nodes[skill_id])
	
	return available
