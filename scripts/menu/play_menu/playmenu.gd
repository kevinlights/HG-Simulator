extends Control


"""
This scene is the heart of the game, where everything get displayed of the game.
"""

# This is to move in the event_queue, to know if a event needs to be loaded or saved.
var index := 0
var queue_size := 0

var randy = RandomNumberGenerator.new()

var cornucopia_text := ""
var game_over = 0


func _ready():
	#test_data() #-> Test data just for testing this scene without the need to create players by hand.
	set_up_icons()
	if GameData.last_menu_id == 1:
		if GameData.is_over: game_over = 2
		queue_size = GameData.event_queue.size()
		index =  GameData.event_queue.size()
		$text/main_text.bbcode_text = GameData.event_queue[index-1]["text"]
		$text/day.text = str(GameData.event_queue[index-1]["day"])
		$text/daytime.text = GameData.event_queue[index-1]["daytime"]
		GameData.last_menu_id = 2
		if !$text/main_text.text.begins_with("The game is about to start and the horn is about to sound."):
			$event_planner.set_up_events(1)
			$event_planner.set_up_events(2)
			
		return
	# The first text that is shown before the bloodbath.
	$text/main_text.bbcode_text = "The game is about to start and the horn is about to sound."
	$text/main_text.bbcode_text +=  "\nYou can buy items in the shop before the game starts."
	save_event()
	index += 1
	queue_size += 1
	GameData.last_menu_id = 2

	
# Just the test data and the set up for this -> 99 players to test things. 
# Don't test this scene without test data.
func test_data ():
	var arg = Array()
	var names = ["Feuerherz", "Sandsturm", "Graustreif", "Gelbzahn", "Blaustern", "Braunstern", "Rotschweif","Tüpfelblatt","Löwenherz"]
	names += ["Weißpelz","Dunkelstreif","Langschweif","Sturmwind", "Glanzfell", "Mausefell", "Kurzschweif","Rosenschweif"]
	names += ["Frostfell", "Buntgesicht", "Goldblüte","Kleinohr","Flickenpelz", "Tupfenschweif", "Rußpelz", "Farnpelz"]
	names += ["Wieselpfote", "Lichtherz", "Wolkenschweif", "Dornenkralle", "Rauchfell", "Aschenpelz", "Brombeerstern", "Eichhornschweif"]
	var gender = [0,1,0,1,1,0,0,1,0,0,0,0,0,1,1,0,1,1,1,1,0,0,1,1,0,0,1,0,0,1,0,0,1]
	
	
	names += ["Feuerherz", "Sandsturm", "Graustreif", "Gelbzahn", "Blaustern", "Braunstern", "Rotschweif","Tüpfelblatt","Löwenherz"]
	names += ["Weißpelz","Dunkelstreif","Langschweif","Sturmwind", "Glanzfell", "Mausefell", "Kurzschweif","Rosenschweif"]
	names += ["Frostfell", "Buntgesicht", "Goldblüte","Kleinohr","Flickenpelz", "Tupfenschweif", "Rußpelz", "Farnpelz"]
	names += ["Wieselpfote", "Lichtherz", "Wolkenschweif", "Dornenkralle", "Rauchfell", "Aschenpelz", "Brombeerstern", "Eichhornschweif"]
	gender += [0,1,0,1,1,0,0,1,0,0,0,0,0,1,1,0,1,1,1,1,0,0,1,1,0,0,1,0,0,1,0,0,1]
	
		
	names += ["Feuerherz", "Sandsturm", "Graustreif", "Gelbzahn", "Blaustern", "Braunstern", "Rotschweif","Tüpfelblatt","Löwenherz"]
	names += ["Weißpelz","Dunkelstreif","Langschweif","Sturmwind", "Glanzfell", "Mausefell", "Kurzschweif","Rosenschweif"]
	names += ["Frostfell", "Buntgesicht", "Goldblüte","Kleinohr","Flickenpelz", "Tupfenschweif", "Rußpelz", "Farnpelz"]
	names += ["Wieselpfote", "Lichtherz", "Wolkenschweif", "Dornenkralle", "Rauchfell", "Aschenpelz", "Brombeerstern", "Eichhornschweif"]
	gender += [0,1,0,1,1,0,0,1,0,0,0,0,0,1,1,0,1,1,1,1,0,0,1,1,0,0,1,0,0,1,0,0,1]
	

	var counter = 0
	var group_number = 0
	while counter < names.size():
		# This defines the group number for the players.
		group_number = counter % 3
		var fighter = $player.create_new_player_dictionary(counter, names[counter], gender[counter],
		100,100,100, group_number,0, true, false)
		arg.push_back(fighter)
		counter += 1
	
	# Data set up.
	GameData.member_number = names.size()
	GameData.set_up_games(arg)


"""This function updates all the icons of each player."""

func update_icons()->void:
	var icons = get_tree().get_nodes_in_group("icon")
	var ids = GameData.dead_fighter
	var counter  = ids.size()-1
	var i_counter = 0
	
	# Update all players that are alive.
	for fighter in GameData.alive_fighter:
			icons[i_counter].set_icon_up_via_dictionary(GameData.fighter_dictionaries[fighter])
			i_counter += 1
			
	# This loop is backwards so that the last tribute that died is right on the top.
	while counter > -1:
			icons[i_counter].set_icon_up_via_dictionary(GameData.fighter_dictionaries[ids[counter]])
			counter -= 1
			i_counter += 1
	
	
"""This function is there to first set up all icons, it loads the icons and adds them to the vbox."""

func set_up_icons()->void:
	var counter = 0

	while counter < GameData.member_number: 
		var node = load("res://nodes/menu/play_menu/char_icon.tscn")
		var icon = node.instance()
		icon.set_icon_up_via_dictionary(GameData.fighter_dictionaries[counter])
		$icon_scroll/vbox.add_child(icon)
		counter += 1
		
	
"""This function creates normal events or arena events and adds the text of them to main_text"""
	
func make_new_events():
	#The probability of an arena event is 10%.
	# Determine if there are arena events.
	randy.randomize()
	var ran = 0
	if GameData.are_there_arena_events: ran = randy.randi_range(1,10)
	if ran== 4 && GameData.daytime != 0: $event_planner.set_up_events(3)
	
	# Set the time of day for events.
	var time = 1
	if GameData.daytime == 4 || ran == 4 && GameData.daytime != 0: time = 2
		
	# Creates for all normal fighters and those with immunity events and adds the text to main_text.
	while !GameData.activ_fighter.empty(): 
		$text/main_text.bbcode_text += $event_planner.chose_random_event(time) + "\n\n"
	for fallen in GameData.tmp_death: GameData.fighter_dictionaries[fallen] = $player.set_death(GameData.fighter_dictionaries[fallen])
	while !GameData.imun_fighter.empty():
		$text/main_text.bbcode_text += $event_planner.chose_random_event_imun(time) + "\n\n"
		
	# If there is an arena event the normal night events need to be loaded.
	if ran== 4 && GameData.daytime != 0: $event_planner.set_up_events(2)


# Functions for save and load daytimes.
func save_event()->void:
	var event_dictionary = {}
	event_dictionary["text"] = $text/main_text.bbcode_text
	event_dictionary["day"] = $text/day.text
	event_dictionary["daytime"] = $text/daytime.text
	GameData.event_queue.push_back(event_dictionary)
	
func load_event()->void:
	$text/main_text.bbcode_text = GameData.event_queue[index-1]["text"]
	$text/day.text = GameData.event_queue[index-1]["day"]
	$text/daytime.text =  GameData.event_queue[index-1]["daytime"]
	
	
"""The function determines which players own the cornucopia for a daytime."""
	
func set_control_over_cornucopia():
	GameData.cornucopia_fighter.clear()
	GameData.update_active_fighter()
	var number := 0
	var fighter_id = GameData.activ_fighter
	fighter_id += GameData.imun_fighter
	fighter_id.shuffle()
	cornucopia_text = "The following tributes took control of the cornucopia: "
	
	#This determines how many players can occupy the cornucopia.
	# Max_member is the maximum of players that can do this at the moment.
	var max_member = GameData.member_number - GameData.death_counter
	if max_member > 20: number = 7
	elif max_member > 10: number = 4
	elif max_member > 5: number = 2
	else: number = 1
	
	# Adds the player names to the cornucopia_text and the players receive immunity for a daytime and 100 item points.
	randy.randomize()
	number = randy.randi_range(1,number)
	while number > 0:
		var id = fighter_id.pop_back()
		GameData.cornucopia_fighter.push_back(id)
		GameData.fighter_dictionaries[id] = $player.set_cornucopia_status(GameData.fighter_dictionaries[id])
		if number > 1: cornucopia_text += "[color=yellow]" + GameData.fighter_dictionaries[id]["name"] + "[/color], "
		else: cornucopia_text += " [color=yellow]" + GameData.fighter_dictionaries[id]["name"] + "[/color].\n\n"
		number -= 1

# This function checks if the games are over and there is a winner
func look_out_for_winner()-> int:
	var win = 0
	var group_win = false
	# Checks if there is win over the group mode.
	if GameData.group_modus:
		var groups = {}
		for fighter in GameData.alive_fighter:
			groups[GameData.fighter_dictionaries[fighter]["group"]] = "0"
		if groups.keys().size() == 1: group_win = true
	
	
	if GameData.alive_fighter.size() == GameData.winner_number || group_win: 
		win = 1
		cornucopia_text = "The games are over.\n"
		if GameData.alive_fighter.size() == 1: 
			cornucopia_text += "The winner is [color=yellow]" + GameData.fighter_dictionaries[GameData.alive_fighter[0]]["name"]  + "[/color].\n\n"
		else:
			 cornucopia_text += "The winners are "
			 var fighter = GameData.alive_fighter.size()-1 
			 while fighter > -1:
				 cornucopia_text +=   "[color=yellow]" + GameData.fighter_dictionaries[GameData.alive_fighter[fighter]]["name"] + "[/color], "
				 fighter -= 1
			 cornucopia_text[cornucopia_text.length()-2] = ".\n\n"
			
		cornucopia_text += "The ranking of tributes:\n\n"
		var placement = GameData.get_placing_of_winners()
		var place = 1
		for tribut in placement:
			var color = "[color=yellow]"
			if !GameData.fighter_dictionaries[tribut]["alive"]: color = "[color=purple]"
			cornucopia_text += str(place) + "st place:  " + color + GameData.fighter_dictionaries[tribut]["name"] + "[/color] | "
			cornucopia_text += "Kills: " + str(GameData.fighter_dictionaries[tribut]["kills"]) + "\n\n"
			place += 1
		
	return win

func _on_next_pressed():
	$text/main_text.scroll_to_line(0)
	# Normal set_up for the queue
	index += 1
	if index <= queue_size:
		load_event()
		return
	else: 
		## If the games are over and the end card is shown.
		if game_over == 2: 
			$endcard.visible = true
			return 
		queue_size += 1
		
	
	if game_over == 1: 
		$text/main_text.bbcode_text = cornucopia_text
		cornucopia_text = ""
		game_over += 1
		save_event()
		return

	
	if GameData.daytime == 2 || GameData.daytime == 4:
		randy.randomize()
		if randi() % 3 == 1: set_control_over_cornucopia()
		
		
	# The new daytime gets set up.
	GameData.update_active_fighter()
	if GameData.daytime != 0: $text/daytime.text = "Daytime:  " + ["Morning", "Day", "Evening", "Night"][GameData.daytime-1]
	$text/day.text = "Day: " + str(GameData.day)
	$text/main_text.bbcode_text = ""
	
	# Orders from the shop get proessed and added as text to the main text.
	for order in GameData.get_shop_orders(): $text/main_text.bbcode_text += order
	
	GameData.update_active_fighter()
	# If tributes control the cornucopia the text will be added.
	if !cornucopia_text.empty():
		$text/main_text.bbcode_text += cornucopia_text
		cornucopia_text = ""
	
	# This sets the different events for daytimes.
	# 0: Bloodbath (normal event), 1: Morning (search event)
	# 2: day (normal event) 3: Evening (search event) 
	# 4: night (normal events)
	if GameData.daytime % 2 == 0: make_new_events()
	else: 
		$text/main_text.bbcode_text += $event_planner.search_event_for_all_fighters()
		if !GameData.imun_fighter.empty(): $text/main_text.bbcode_text += $event_planner.search_event_for_imun_fighters()
	
	save_event()
	GameData.update_fallen_fighter()
	update_icons()
	GameData.clear_shop()
	
	# Checks if the games are over or not.
	if look_out_for_winner() == 1: 
		GameData.is_over = true
		game_over = 1
		return
		
	# After the bloodbath the normal events for day and night get loaded.
	if GameData.daytime == 0:
		$event_planner.set_up_events(1)
		$event_planner.set_up_events(2)
		
	# The next daytime needs to be set.
	GameData.daytime += 1
	if GameData.daytime > 4: 
		GameData.daytime = 1
		GameData.day += 1
	

func _on_back_pressed():
	if index > 1:
		index -= 1
		if index >= queue_size: index = queue_size -1
		load_event()


func _on_shop_pressed():
	$shop_menu.set_up_shop()
	$shop_menu.visible = true


func _on_go_back_pressed():
	$endcard.visible = false


func _on_exit_pressed():
	GameData.reset_games()
	$szene_changer.visible = true
	$szene_changer.change_szene("res://nodes/menu/option_menu/player_menu.tscn")


func _on_again_pressed():
	
	# Sets the game up to simulate with same players again.
	GameData.simulate_again()
	
	var counter = 0
	while counter < GameData.fighter_dictionaries.size():
		GameData.fighter_dictionaries[counter] = $player.reset_player(GameData.fighter_dictionaries[counter])
		counter += 1
		
	GameData.set_up_games(GameData.fighter_dictionaries)
	$szene_changer.visible = true
	$szene_changer.change_szene("res://nodes/menu/play_menu/playmenu.tscn")



func _on_TextureButton_pressed():
	$endcard.visible = false


# This is for the buttons that change color if you hover with the mouse over them.
func _on_menu_mouse_entered():
	$text/menu.bbcode_text = "[color=yellow]" + "Menu" + "[/color]"


func _on_menu_mouse_exited():
	$text/menu.bbcode_text = "Menu" 


func _on_back_mouse_entered():
	$text/back.bbcode_text = "[color=yellow]" + "Back" + "[/color]"


func _on_back_mouse_exited():
	$text/back.bbcode_text =  "Back" 


func _on_shop_mouse_entered():
	$text/shop.bbcode_text = "[color=yellow]" + "Shop" + "[/color]"


func _on_shop_mouse_exited():
	$text/shop.bbcode_text =  "Shop"


func _on_next_mouse_entered():
	$text/next.bbcode_text  = "[color=yellow]" + "Next" + "[/color]"


func _on_next_mouse_exited():
	$text/next.bbcode_text  = "Next"


func _on_back_game_pressed():
	$menu.visible = false


func _on_save_pressed():
	$szene_changer.visible = true
	GameData.last_menu_id = 2
	$szene_changer.change_szene("res://nodes/menu/save_menu/save_menu.tscn")


func _on_quit_pressed():
	GameData.reset_games()
	$szene_changer.visible = true
	$szene_changer.change_szene("res://nodes/menu/start_menu/start_menu.tscn")

func _on_menu_pressed():
	$menu.visible = true
