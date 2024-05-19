extends Node2D

"""
This node dynamically loads the events and selects a random event and then updates the players.
"""


# This dictionary contains personal pronouns
var personal_pro = {}
#This dictionary contains the events for the day or the bloodbath, not both at the same time.
var day_events := {}
#This dictionary contains the events for the night or the arena events, not both at the same time.
var night_events := {}
var randy := RandomNumberGenerator.new()
# Contians the start text of an arena event.
var event_text = ""


func _ready():
	# Loads and sets up the bloodbath events and personal pronouns for the game start. 
	personal_pro = load_jsonfile("res://json/pronom_eng.json")
	set_up_events(0)
	
# Loads and sets up following events:
# daytime -> 0: bloodbath, 1: day, 2: night, 3: arena event.
# A single event is a dictionary.
func set_up_events(daytime:int)-> void:
	var data = load_jsonfile("res://json/" + ["bloodbath.json", "day.json", "night.json", "event.json"][daytime])
	var event
	var keys
	if daytime < 2:
		# Events for bloodbath or day.
		day_events.clear()
		event = day_events
	else:
		# Events for night or arena event.
		 night_events.clear()
		 event = night_events
		
		# This gets the keys of all loaded events (bloodbath, day or night)
	if daytime < 3: keys = data.keys()
	else:
		# This choses a random arena event and loads it.
		# An arena event is a dictionary within a dictionary.
		randy.randomize()
		keys = data.keys()
		data = data[keys[randy.randi() % keys.size()]]
		keys = data.keys()
		# The arena event start text must be buffered and loaded later.
		event_text = data["start"]
		# The key Start must be removed from the dictionary, 
		#because it does not appear in the normal dictionaries for events.
		keys.erase("start")
	for key in keys:
		# Loads all events via keys and puts them inside the current event dictionary.
		# The event dictionary (day or night) have the following key structure.
		# Key: Number of players_number of deaths. Ex. -> 1_1 (On player is in the event and dies)
		# The events are stored in an array under the matching key like 1_1. 
		var member =  data[key]["member_size"]
		var deaths = 0
		if data[key]["deaths"] != null:  deaths = data[key]["deaths"].size()
		var event_key = str(member)+ "_" + str(deaths)
		if event.has(event_key): event[event_key].push_back(data[key])
		else: event[event_key] = [data[key]]
		
# This fuction gives a string of the event text back.
# Creates a quest event for all players to search for a source of water or food or for medicinal herbs.
func search_event_for_all_fighters() -> String:
	var text = ""
		
	var daytime = GameData.daytime
	var counter = 0
	
	
	while (counter < GameData.activ_fighter.size()):
		var fighter_id = GameData.get_activ_fighter(1)[0]
		var food_need
		var water_need
		var fighter = GameData.fighter_dictionaries[fighter_id]
		
		# This determines how much water, food the player needs.
		# Subsequently, these points are deducted from the player.
		# Hunger, thirst and health is always deducted in the morning or evening.
		if GameData.food_points_per_day % 2 == 0: food_need= GameData.food_points_per_day / 2
		else:
			if daytime == 1:  food_need= GameData.food_points_per_day / 2
			else:  food_need= (GameData.food_points_per_day / 2) + 1
		
		if GameData.water_points_per_day % 2 == 0: water_need = GameData.water_points_per_day / 2
		else:
			if daytime == 1: water_need = GameData.water_points_per_day / 2
			else: water_need = (GameData.water_points_per_day/ 2) + 1
			
		
		GameData.fighter_dictionaries[fighter_id]["hunger"] -= food_need
		GameData.fighter_dictionaries[fighter_id]["thirst"] -= water_need
		if fighter["injury"] > 0: fighter["health"] -= fighter["injury"]
		var arg = $player.update_hunger_thirst_and_health(fighter)
		GameData.fighter_dictionaries[fighter_id] = arg[0]
		
		# Checks whether a player is allowed to die or not.
		var dead_allow = (GameData.member_number - GameData.death_counter - GameData.winner_number) != 0
		#Players die when they have only one hunger, thirst, or food point left and 
		#have not been able to replenish that number with supplies.
		if arg[1] != null && dead_allow:
			# Player has died and death gets set.
			GameData.fighter_dictionaries[fighter_id]["alive"] = false
			text += arg[1]
			GameData.add_fallen_fighter(fighter_id)
			GameData.fighter_dictionaries[fighter_id] = $player.set_death(GameData.fighter_dictionaries[fighter_id])
		else:
			# The probability that the player finds what he is looking for is 50%.
			if randi() % 2 == 1: text +=  "[color=yellow]"+  fighter["name"] + "[/color] is wandering around without finding anything interesting.\n\n"
			else:
				
				# Specifies what the player is looking for. Is always the thing in which he/she has the fewest points.
				var status = [fighter["thirst"],fighter["hunger"], fighter["health"]]
				var search_number = status.find(status.min())
				
				match search_number:
					# A player can find a maximum of half of his maximum number of points in the respective type.
					0:
						text +=  "[color=yellow]"+  fighter["name"] + "[/color] finds a water source.\n\n"
						GameData.fighter_dictionaries[fighter_id]["water"] = randi() % (fighter["M_THIRST"]/2)
					1:
						text +=  "[color=yellow]"+  fighter["name"] + "[/color] finds a food source.\n\n"
						GameData.fighter_dictionaries[fighter_id]["food"] = randi() % (fighter["M_HUNGER"]/2)
					2:
						text +=  "[color=yellow]"+  fighter["name"] + "[/color] finds medicinal herbs.\n\n"
						GameData.fighter_dictionaries[fighter_id]["healItem"] = randi() % (fighter["M_HEALTH"]/2)
	GameData.update_active_fighter()
	return text


# This is the same quest event only players can't die and they always have an immunity point deducted.
func search_event_for_imun_fighters()-> String:
	var text := ""
	var daytime = GameData.daytime
	var counter = 0
	while (counter < GameData.imun_fighter.size()):
		var fighter_id = GameData.get_imun_fighter(1)[0]
		var food_need
		var water_need
		var fighter = GameData.fighter_dictionaries[fighter_id]
		
		if GameData.food_points_per_day % 2 == 0: food_need= GameData.food_points_per_day / 2
		else:
			if daytime == 1:  food_need= GameData.food_points_per_day / 2
			else:  food_need= (GameData.food_points_per_day / 2) + 1
		
		if GameData.water_points_per_day % 2 == 0: water_need = GameData.water_points_per_day / 2
		else:
			if daytime == 1: water_need = GameData.water_points_per_day / 2
			else: water_need = (GameData.water_points_per_day/ 2) + 1
		
		GameData.fighter_dictionaries[fighter_id]["hunger"] -= food_need
		GameData.fighter_dictionaries[fighter_id]["thirst"] -= water_need
		if fighter["injury"] > 0: fighter["health"] -= fighter["injury"]
		var arg = $player.update_hunger_thirst_and_health(fighter)
		GameData.fighter_dictionaries[fighter_id] = arg[0]
		
		if randi() % 2 == 1: text +=  "[color=yellow]"+  fighter["name"] + "[/color] is wandering around without finding anything interesting.\n\n"
		else:
			var status = [fighter["thirst"],fighter["hunger"], fighter["health"]]
			var search_number = status.find(status.min())
				

			match search_number:
				0:
					text +=  "[color=yellow]"+  fighter["name"] + "[/color] finds a water source.\n\n"
					GameData.fighter_dictionaries[fighter_id]["water"] = randi() % (fighter["M_THIRST"]/2)
				1:
						text +=  "[color=yellow]"+  fighter["name"] + "[/color] finds a food source.\n\n"
						GameData.fighter_dictionaries[fighter_id]["food"] = randi() % (fighter["M_HUNGER"]/2)
				2:
						text +=  "[color=yellow]"+  fighter["name"] + "[/color] finds medicinal herbs.\n\n"
						GameData.fighter_dictionaries[fighter_id]["healItem"] = randi() % (fighter["M_HEALTH"]/2)
		
		GameData.fighter_dictionaries[fighter_id]["imun"] -= 1
		if GameData.fighter_dictionaries[fighter_id]["imun"] == 0: 
			if !GameData.cornucopia_fighter.has(fighter_id): text += "[color=yellow]" + GameData.fighter_dictionaries[fighter_id]["name"] +"[/color] loses immunity.\n\n"
			
	GameData.update_active_fighter()
	
	return text


# The same function as the one below only that players do not die and lose an immunity point.
func chose_random_event_imun(daytime:int)->String:
	var text = ""
	var loses_imun = ""
	var event
	var max_member = GameData.imun_fighter.size()
	
	if !event_text.empty():
		text = "An Arena event occurs:\n\n" + event_text + "\n\n"
		event_text = ""
		
	
	if daytime < 2: event = day_events
	else: event = night_events
	var event_keys = Array()
	for key in event.keys():
			if int(key[0]) <= max_member && int(key[2]) == 0: event_keys.push_back(key)
	var all_events = Array()
	for key in event_keys:
		all_events += event[key]
	
	randy.randomize()
	if randy.randi() % 2 == 0: all_events.shuffle()
	randy.randomize()
	if randy.randi() % 2 == 0: all_events.shuffle()
	randy.randomize()
	event = all_events[randy.randi() % all_events.size()]
	var fighter_ids = GameData.get_imun_fighter(event["member_size"])
	
	# Sets up the event text
	text += event["text"]
	var counter = 1
	for id in fighter_ids:
		var color =  "[color=yellow]"
		var name = "#name_" + str(counter)
		var replace_name = color + GameData.fighter_dictionaries[id]["name"] + "[/color]"
		text = text.replace(name, replace_name)
		GameData.fighter_dictionaries[id]["imun"] -= 1
		if GameData.fighter_dictionaries[id]["imun"] == 0: 
			if !GameData.cornucopia_fighter.has(id):
				loses_imun = color + GameData.fighter_dictionaries[id]["name"] +"[/color] loses immunity."
			
		var gender_counter = 1
		var gender 
		while gender_counter < 11:
			match GameData.fighter_dictionaries[id]["gender"]:
				0: gender = personal_pro[str(gender_counter)].m
				1: gender = personal_pro[str(gender_counter)].w
				2: gender = personal_pro[str(gender_counter)].d
				
			
			text = text.replace(personal_pro[str(gender_counter)].re + "_" + str(counter), gender)
			gender_counter += 1
			
		counter += 1
		
	
	if !loses_imun.empty(): text += "\n\n" + loses_imun
	return text


# This function selects a random event and returns the event text as a string.
# daytime -> 0: day, 1: night.
func chose_random_event(daytime:int)-> String:
	var text := ""
	# The maximum number of players and deaths is set.
	var max_member = GameData.activ_fighter.size()
	var max_death = GameData.alive_fighter.size() - GameData.winner_number
	if max_death > max_member : max_death = max_member
	var event
	
	#Here the arena event start text is loaded if it was previously cached.
	if !event_text.empty():
		text = "An Arena event occurs:\n\n" + event_text + "\n\n"
		event_text = ""
	
	if daytime < 2: event = day_events
	else: event = night_events
	var event_keys = Array()
	
	# Get random normal or fatal events.
	randy.randomize()
	if  max_death != 0:
		# All matching event keys are picked and put into an array.
		var ran = randy.randi_range(1,10)
		if ran <= GameData.death_risk:
			#Get fatal events
			for key in event.keys():
				if int(key[0]) <= max_member && int(key[2]) <= max_death && int(key[2]) != 0: event_keys.push_back(key)
		else:
			#Get normal events
			for key in event.keys():
				if int(key[0]) <= max_member && int(key[2]) == 0: event_keys.push_back(key)
	else:
		#Get normal events
		for key in event.keys():
			if int(key[0]) <= max_member && int(key[2]) == 0: event_keys.push_back(key)
	
	# Packs all events into an array based on the keys that were previously selected.
	var all_events = Array()
	for key in event_keys:
		all_events += event[key]
	
	# This for better random results.
	randy.randomize()
	if randy.randi() % 2 == 0: all_events.shuffle()
	randy.randomize()
	if randy.randi() % 2 == 0: all_events.shuffle()
	randy.randomize()
	
	# Randomly selects an event out of all events via event key.
	event = all_events[randy.randi() % all_events.size()]
	var fighter_ids = GameData.get_activ_fighter(event["member_size"])
	update_fighter_status(fighter_ids, event)
	
	# Sets up the event text.
	text += event["text"]
	var counter = 1
	for id in fighter_ids:
		var color =  "[color=yellow]"
		if !GameData.fighter_dictionaries[id]["alive"]: 
			color = "[color=purple]"
		var name = "#name_" + str(counter)
		var replace_name = color + GameData.fighter_dictionaries[id]["name"] + "[/color]"
		text = text.replace(name, replace_name)
		var gender_counter = 1
		var gender 
		while gender_counter < 11:
			match GameData.fighter_dictionaries[id]["gender"]:
				0: gender = personal_pro[str(gender_counter)].m
				1: gender = personal_pro[str(gender_counter)].w
				2: gender = personal_pro[str(gender_counter)].d
			
			text = text.replace(personal_pro[str(gender_counter)].re + "_" + str(counter), gender)
			gender_counter += 1
			
		counter += 1
		
	
	return text

# Fighter_ids -> the ids of the players that take part in a event.
# Event -> the event itself, that is a dictionary.
func update_fighter_status(fighter_ids:Array, event: Dictionary)->void:
	var status = ["hunger", "thirst", "health", "food", "water", "healItem", "kills", "injury"]
	var status_max = ["M_HUNGER", "M_THIRST", "M_HEALTH"]
	
	# A status is an array like this -> [1,20,2,20,3,20] that is in the event dictionary.
	# Every status except death has two variables (Death only has the number of the player).
	# The first is the number of the player.
	# The secound is the value that gets added to the player status.
	# Number of player != Player id. 
	
	
	var counter = 1
	while counter < (fighter_ids.size() + 1):
		# This variable retrieves the location of the current player's number from the array.
		var stat_id = (counter *2) - 2
		var fighter 
		var status_counter = 0
		
		while status_counter < 8:
			if event[status[status_counter]] != null:
				if status_counter  < 3:
					
					if event[status[status_counter]].size() > stat_id: 
						# Updates changes of hunger, thirst and health of the current player.
						# Checks if the points over max or under 1 and corrects these.
						fighter = GameData.fighter_dictionaries[fighter_ids[event[status[status_counter]][stat_id]-1]]
						fighter[status[status_counter]] += event[status[status_counter]][stat_id+1]
						if fighter[status[status_counter]] > fighter[status_max[status_counter]]:  fighter[status[status_counter]] = fighter[status_max[status_counter]]
						if  fighter[status[status_counter]] < 1: fighter[status[status_counter]] = 1
				else: 
					if event[status[status_counter]].size() > stat_id: 
						# Adds items or kills to the current player.
						fighter = GameData.fighter_dictionaries[fighter_ids[event[status[status_counter]][stat_id]-1]]
						fighter[status[status_counter]] += event[status[status_counter]][stat_id+1]
			status_counter += 1
			
		if event["deaths"] != null:
			# Sets the death of the fighters.
			if event["deaths"].size() > counter-1:
				fighter = GameData.fighter_dictionaries[fighter_ids[event["deaths"][counter-1]-1]]
				GameData.add_fallen_fighter(fighter_ids[event["deaths"][counter-1]-1])
				GameData.fighter_dictionaries[fighter_ids[event["deaths"][counter-1]-1]]["alive"] = false
				
				
		counter += 1
		

# This function is for loading a json file.
func load_jsonfile (path):
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		print("[load_json_file] Error loading JSON file '" + str(path) + "'.")
		print("\tError: ", result_json.error)
		print("\tError Line: ", result_json.error_line)
		print("\tError String: ", result_json.error_string)
		return null
	var obj = result_json.result
	file.close()
	return obj

