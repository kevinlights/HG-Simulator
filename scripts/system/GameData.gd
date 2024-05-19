extends Node2D

"""
This is a global node with all the game data.
"""

var first_start = false
# The menu id: start_menu : 0 | save_menu : 1 | playmenu : 2 | player_menu : 3
var last_menu_id := 0

# Contains the dictionaries that are generated by the player node.
var fighter_dictionaries := Array()

var group_modus = false
var are_there_arena_events = true
var is_over = false
var daytime = 0
var day = 1
# Sets how high the probability of death is, in 10 steps.
# Default number is 4 => 40% probability of death
var death_risk = 4

# Determines how many players participate in the game.
var member_number := 24
var winner_number := 1
# Contains all ids of fighters that need to be in a event
var activ_fighter := Array()
# Ids of fighters that are alive.
var alive_fighter := Array()
#Ids of fighters that have immunity
var imun_fighter := Array()
# Ids of fighters that are dead

# Contains the ids of fighters that control the cornucopia for a dayime.
var cornucopia_fighter := Array()

# Fallen players
var dead_fighter := Array()

# newest deaths
var tmp_death := Array()

# Contains all groups in the game, a fighter can belong to.
var group_names = ["District 1", "District 2", "District 3", "District 4", "District 5", "District 6", "District 7", "District 8", "District 9", "District 10", "District 11", "District 12"]
# Contains the event text and all fighter icons of a daytime
var event_queue := []

# Shop items that get added on the next daytime. (Contains the add text, no fighter ids or item points.)
var item_queue := []
var trap_queue := []
var immunity_queue := []

# Counts the fallen players.
var death_counter = 0

# The points for food/water that get used per day.
var food_points_per_day = 30
var water_points_per_day = 35


# First set up of the games.
func set_up_games(fighter:Array)->void:
	
	fighter_dictionaries = fighter
	var fighter_numbers = {}
	
	# Yeah, I used a dictionary instatt of an array.
	# This is a bug fix because for some reason the player ids duplicate themselves sometimes.
	for fighter in GameData.fighter_dictionaries:
		fighter_numbers[fighter["id"]] = 0
		
	activ_fighter = Array(fighter_numbers.keys())
	alive_fighter = Array(fighter_numbers.keys())
	
	activ_fighter.shuffle()
	
# Completely resets the game.
func reset_games():
	event_queue.clear()
	fighter_dictionaries.clear()
	alive_fighter.clear()
	activ_fighter.clear()
	member_number = 24
	winner_number = 1
	imun_fighter.clear()
	dead_fighter.clear()
	tmp_death.clear()
	cornucopia_fighter.clear()
	item_queue.clear()
	trap_queue.clear()
	group_modus = false
	are_there_arena_events = true
	is_over = false
	daytime = 0
	day = 1
	death_risk = 4
	death_counter = 0
	food_points_per_day = 30
	water_points_per_day = 35
	
# Resets the game partionally.
func simulate_again():
	event_queue.clear()
	activ_fighter.clear()
	imun_fighter.clear()
	dead_fighter.clear()
	tmp_death.clear()
	cornucopia_fighter.clear()
	item_queue.clear()
	trap_queue.clear()
	is_over = false
	daytime = 0
	day = 1
	death_counter = 0

func get_activ_fighter(number:int)-> Array:
	activ_fighter.shuffle()
	var fighter = Array()
	while (number > 0):
		fighter.push_back(activ_fighter.pop_front())
		number -= 1
	
	return fighter
	
func get_imun_fighter(number:int)->Array:
	imun_fighter.shuffle()
	var fighter = Array()
	while (number > 0):
		fighter.push_back(imun_fighter.pop_front())
		number -= 1
	
	return fighter
	
func update_active_fighter()->void:
	activ_fighter.clear()
	imun_fighter.clear()
	for fighter in alive_fighter: 
		if fighter_dictionaries[fighter]["imun"] == 0: 
			activ_fighter.push_front(fighter)
		else: imun_fighter.push_front(fighter)
		

	
func add_fallen_fighter(id:int)->void:
	alive_fighter.erase(id)
	death_counter += 1
	tmp_death.push_back(id)
	dead_fighter.push_back(id)
	

func get_shop_orders()->Array:
	var arg = item_queue
	arg += immunity_queue
	arg += trap_queue
	return arg
	
func clear_shop()-> void:
	immunity_queue.clear()
	item_queue.clear()
	trap_queue.clear()
	

# This function determines the final placement of all players.
# Players are placed based on kills and when they die.
# Players without immunity are placed before the players who have it.
func get_placing_of_winners()->Array:
	var result = Array()
	var tmp = Array()
	var fighter_a = alive_fighter

	var fighter_d = dead_fighter
	var current_kills = 0
	
	for fighter in fighter_a:
		if int(fighter_dictionaries[fighter]["kills"]) > current_kills: 
			current_kills = fighter_dictionaries[fighter]["kills"]
	
	while current_kills > -1:
		tmp.clear()
		for id in fighter_a:
			if int(fighter_dictionaries[id]["kills"]) == current_kills: 
				tmp.push_front(id)
		result += tmp
			
		current_kills -= 1
	
	current_kills = 0
	for fighter in fighter_d:
		if fighter_dictionaries[fighter]["kills"] > current_kills: 
			current_kills = fighter_dictionaries[fighter]["kills"]
	
	while current_kills > -1:
		tmp.clear()
		for id in  fighter_d:
			if int(fighter_dictionaries[id]["kills"]) == current_kills: 
				tmp.push_front(id)
		result += tmp
		
		current_kills -= 1
		
	return result
	
	
func update_fallen_fighter()->void:
# Maybe a function for the future, to show all deaths in daytimes at the end of the game.
	tmp_death.clear()

