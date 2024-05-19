extends Control


var death_risk  = [0, 1, 2, 4, 6, 8, 10]
var death_label =  ["No deaths", "very low", "low", "middle", "high", "very high", "fatal"]
var death_counter = 3


func _ready():
	load_fighter()
	#OS.center_window() #-> For Desktop only.
	#GameData.member_number = 2
	#var counter = 0
	#while counter < 3:
	#	var node = load("res://nodes/menu/option_menu/player_icon.tscn")
	#	var icon = node.instance()
	#	if counter != 2: icon.set_up()
	#	icon.id = counter
	#	icon.connect("delete_icon", self, "delete_icon")
	#	icon.connect("need_new_icon", self, "add_icon")
	#	$label/scroll/vbox.add_child(icon)
	#	counter += 1


func load_fighter():
	var file = File.new()
	var counter = 0
	file.open("user://fighter.dat",1)
	var data = file.get_var()
	file.close()
	for fighter in data["player"]:
		var node = load("res://nodes/menu/option_menu/player_icon.tscn")
		var icon = node.instance()
		icon.set_up_icon_via_fighter(fighter)
		icon.connect("delete_icon", self, "delete_icon")
		icon.connect("need_new_icon", self, "add_icon")
		$label/scroll/vbox.add_child(icon)
		counter += 1
	var node = load("res://nodes/menu/option_menu/player_icon.tscn")
	var icon = node.instance()
	icon.id = counter
	GameData.member_number = counter
	icon.connect("delete_icon", self, "delete_icon")
	icon.connect("need_new_icon", self, "add_icon")
	$label/scroll/vbox.add_child(icon)
	$label/player_number.text = "Current number of players: " + str(counter)
	
	
# set_up_icon_via_fighter(player:Dictionary)
func delete_icon(id):
	
	var icons = get_tree().get_nodes_in_group("icon")
	if icons.size() > 3: 
		var counter = 0
		while counter < icons.size():
			if icons[counter].id == id: icons[counter].queue_free()
			counter += 1
		counter = 0
		icons = get_tree().get_nodes_in_group("icon")
		for icon in icons:
			icon.id = counter
			counter += 1
			
		$label/player_number.text = "Current number of players: " + str(icons.size()-2)
		GameData.member_number = icons.size()-2
		_on_winners_focus_exited()
	
	
func add_icon(id):
	var icons = get_tree().get_nodes_in_group("icon")
	icons[id-1].set_up()
	var node = load("res://nodes/menu/option_menu/player_icon.tscn")
	var icon = node.instance()
	icon.id = id +1
	icon.connect("delete_icon", self, "delete_icon")
	icon.connect("need_new_icon", self, "add_icon")
	$label/scroll/vbox.add_child(icon)
	$label/player_number.text = "Current number of players: " + str(icons.size())
	GameData.member_number = icons.size()
	_on_winners_focus_exited()


func _on_winners_focus_exited():
	if $button/winners.text.is_valid_integer():
		var number = int($button/winners.text)
		if number < 1: number = 1
		if number >= GameData.member_number: number = GameData.member_number-1
		GameData.winner_number = number
	$button/winners.text = str(GameData.winner_number)


func _on_group_pressed():
	GameData.group_modus = !GameData.group_modus
	if GameData.group_modus:
		$button/winners.text = "1"
		$button/winners.readonly = true
	else: $button/winners.readonly = false


func _on_arena_pressed():
	GameData.are_there_arena_events = !GameData.are_there_arena_events


func _on_water_need_focus_exited():
	if $button/water_need.text.is_valid_integer():
		var number = int($button/water_need.text)
		if number < 0: number = 0
		GameData.water_points_per_day = number
	$button/water_need.text = str(GameData.water_points_per_day)


func _on_food_need_focus_exited():
	if $button/food_need.text.is_valid_integer():
		var number = int($button/food_need.text)
		if number < 0: number = 0
		GameData.food_points_per_day = number
	$button/food_need.text = str(GameData.food_points_per_day)


func _on_death_risk_left_pressed():
	death_counter -= 1
	if death_counter <= -1: death_counter = 6
	$label/probability.text = death_label[death_counter]
	GameData.death_risk = death_risk[death_counter]


func _on_death_risk_right_pressed():
	death_counter += 1
	if death_counter >= 7: 
		death_counter = 0
	$label/probability.text = death_label[death_counter]
	GameData.death_risk = death_risk[death_counter]
	

func generate_player_dictionaries():
	var icons = get_tree().get_nodes_in_group("icon")
	icons.pop_back()
	var tributes = Array()
	var counter = 0
	for icon in icons:
		var info = icon.get_icon_information()
		var player = $player.create_new_player_dictionary(counter, info[0], info[1],
		info[2], info[3], info[4], info[5],0,true,false)
		tributes.push_back(player)
		counter += 1
	GameData.set_up_games(tributes)
	var data = {}
	data["player"] = tributes
	var file = File.new()
	file.open("user://fighter.dat",2)
	file.store_var(data)
	file.close()
		
func _on_start_button_pressed():
	generate_player_dictionaries()
	$szene_changer.visible = true
	$szene_changer.change_szene("res://nodes/menu/play_menu/playmenu.tscn")


func _on_start_button_focus_entered():
	$label/start.bbcode_text = "[color=yellow]" + "Start game" + "[/color]"

func _on_start_button_focus_exited():
	$label/start.bbcode_text = "Start game"


func _on_back_button_pressed():
	$szene_changer.visible = true
	$szene_changer.change_szene("res://nodes/menu/start_menu/start_menu.tscn")


func _on_back_button_mouse_entered():
	$label/back.bbcode_text =  "[color=yellow]" + "Go back" + "[/color]"


func _on_back_button_mouse_exited():
	$label/back.bbcode_text = "Go back"
