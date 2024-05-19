extends Node2D

# This is a helper node that is for making player and update thier status.

# Creates the player dictionary, which are the tributes the game works with.
func create_new_player_dictionary(id:int, name:String, gender: int, MAX_HUNGER:int,
 MAX_THIRST:int, MAX_HEALTH:int, group:int, imun:int, alive:bool, n_death:bool)-> Dictionary:
	var player := {}
	player["id"] = id
	player["name"] = name
	player["gender"] = gender
	player["hunger"] = MAX_HUNGER
	player["thirst"] =  MAX_THIRST
	player["health"] =  MAX_HEALTH
	player["M_HUNGER"] = MAX_HUNGER
	player["M_THIRST"] = MAX_THIRST
	player["M_HEALTH"] = MAX_HEALTH
	player["food"] = 0
	player["water"] = 0
	player["healItem"] = 0
	player["kills"] = 0
	player["injury"] = 0
	player["group"] = group
	player["imun"] = imun
	player["alive"] = alive
	player["near_death"] = n_death
	
	return player


func reset_player(player:Dictionary)-> Dictionary:
	player["hunger"] = player["M_HUNGER"]
	player["thirst"] =  player["M_THIRST"]
	player["health"] =  player["M_HEALTH"]
	player["food"] = 0
	player["water"] = 0
	player["healItem"] = 0
	player["kills"] = 0
	player["injury"] = 0
	player["imun"] = 0
	player["alive"] = true
	player["near_death"] = false
	
	return player


func set_death(player:Dictionary)->Dictionary:
	player["hunger"] = 0
	player["thirst"] = 0
	player["health"] = 0
	player["imun"] = 0
	player["food"] = 0
	player["water"] = 0
	player["healItem"] = 0
	player["injury"] = 0
	return player

# Fighter owns for a daytime cornucopia and just carries 100 points each around.
# As reward they get also a daytime immunity.
func set_cornucopia_status(player:Dictionary)-> Dictionary:
	player["hunger"] = player["M_HUNGER"]
	player["thirst"] = player["M_THIRST"]
	player["health"] = player["M_HEALTH"]
	player["food"] = 100
	player["water"] = 100
	player["healItem"] = 100
	player["imun"] += 1
	return player
	
func update_hunger_thirst_and_health(player:Dictionary)-> Array:
	var arg = Array()
	var near_dead = false
	var text = null
	
	if player["hunger"] < 1: player["hunger"]= 1
	if player["thirst"] < 1: player["thirst"] = 1
	if player["health"] < 1: player["health"] = 1
	
	if player["hunger"] == 1 || player["thirst"] == 1 || player["health"] == 1: near_dead = true
	_check_if_item_is_needed(player, 0)
	_check_if_item_is_needed(player, 1)
	_check_if_item_is_needed(player, 2)
	
	if near_dead:
		if player["hunger"] == 1 || player["thirst"] == 1 || player["health"] == 1:
			if player["hunger"] == 1: text = "[color=purple]" + player["name"] + "[/color] is starved to death.\n\n"
			elif  player["thirst"] == 1:  text = "[color=purple]" + player["name"] + "[/color] has died of thirst.\n\n"
			elif  player["health"] == 1: text =  "[color=purple]" + player["name"] + "[/color] has died due to poor health.\n\n"
	arg.push_back(player)
	arg.push_back(text)
	return arg


# item_type : 0 hunger, 1 thirst, 2 health
# Injury points are deducted every morning and evening.
func _check_if_item_is_needed(player:Dictionary, item_type :int)-> Dictionary:
	var type_max_points = ["M_HUNGER", "M_THIRST", "M_HEALTH"][item_type]
	var type_points = ["hunger", "thirst", "health"][item_type]
	var item_label = ["food", "water", "healItem"][item_type]
	
	if type_points == "health" && player["injury"] != 0 && player["healItem"] != 0:
		# Injury points become less due to healing items.
		player["injury"] -= player["healItem"]
		if player["injury"] < 0: player["injury"] = 0
	
	if player[type_max_points] != player[type_points] && player[item_label] != 0:
		var fill = player[type_max_points] - player[type_points]
		if fill > player[item_label]:
			player[type_points] += player[item_label]
			player[item_label] = 0
		else:
			player[type_points] += fill
			player[item_label] -= fill
		
		
	return player


