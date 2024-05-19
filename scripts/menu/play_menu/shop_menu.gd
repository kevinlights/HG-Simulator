extends Control

signal exit_shop()

"""
This scene is the shop of the game.
"""

var first = true
var icons
var food = 100
var water = 100
var health = 100 
var imun = 8
var randy = RandomNumberGenerator.new()
var last_day = -1
var current_fav = 0

# The first time when the shop is opened the icons need to be loaded. 
func first_set_up():
	first = false
	var counter = 0
	while counter < GameData.member_number: 
		var node = load("res://nodes/menu/play_menu/icon_button.tscn")
		var icon = node.instance()
		$icon_scroll/vbox.add_child(icon)
		counter += 1
		
	
func set_up_shop():
	if first: first_set_up()
	icons = get_tree().get_nodes_in_group("icon_button")
	var fighter = GameData.alive_fighter
	var counter = 0 
	while counter < icons.size():
		if counter < fighter.size(): 
			icons[counter].id = fighter[counter]
			icons[counter].set_icon_up_via_dictionary(GameData.fighter_dictionaries[fighter[counter]])
		else:  icons[counter].queue_free()
		counter += 1
	if last_day != GameData.day || !GameData.alive_fighter.has(current_fav):
		set_popular_tribut()
		last_day = GameData.day
		
		
func set_popular_tribut()->void:
	randy.randomize()
	var fighter = GameData.alive_fighter[randy.randi()%GameData.alive_fighter.size()]
	$label/fav_text.text = "The most popular tribut that\n day is " + GameData.fighter_dictionaries[fighter]["name"] + "."
	current_fav = fighter


func _on_immun_focus_exited():
	if $buttons/immun.text.is_valid_integer(): 
		var number = int($buttons/immun.text)
		if number > 99999: number = 99999
		if number < 0: number = 0
		imun = number
	else: $buttons/immun.text = str(imun)



func _on_water_focus_exited():
	if $buttons/water.text.is_valid_integer(): 
		var number = int($buttons/water.text)
		if number > 99999: number = 99999
		if number < 0: number = 0
		water = number
	else: $buttons/water.text = str(water)


func _on_health_focus_exited():
	if $buttons/health.text.is_valid_integer():
		var number = int($buttons/health.text)
		if number > 99999: number = 99999
		if number < 0: number = 0
		health = number
	else: $buttons/health.text = str(health)
		


func _on_food_focus_exited():
	if $buttons/food.text.is_valid_integer():
		var number = int($buttons/food.text)
		if number > 99999: number = 99999
		if number < 0: number = 0
		food = number
	else: $buttons/food.text = food


func _on_add_items_pressed():
	if GameData.is_over:
		$label/hint_3.text = "The games are over, you can no\nlonger buy anything in the shop."
		$animation.play("text_popup")
		return
	
	if (food == 0 && water == 0 && health == 0): return
	var counter = 0
	icons = get_tree().get_nodes_in_group("icon_button")
	for icon in icons:
		if icon.is_activ: 
			counter += 1
			GameData.fighter_dictionaries[icon.id]["food"] += food
			GameData.fighter_dictionaries[icon.id]["water"] += water
			GameData.fighter_dictionaries[icon.id]["healItem"] += health
			icon.set_icon_up_via_dictionary(GameData.fighter_dictionaries[icon.id])
			var text = "[color=yellow]" + GameData.fighter_dictionaries[icon.id]["name"] + "[/color] receives several items from an unknown sponsor.\n\n"
			GameData.immunity_queue.push_back(text)
			icon.switch_button()
	if counter != 0: 
		$label/hint_3.text = "Item points have been added."
		$animation.play("text_popup")


func _on_add_immun_pressed():
	if GameData.is_over:
		$label/hint_3.text = "The games are over, you can no\nlonger buy anything in the shop."
		$animation.play("text_popup")
		return
	
	if imun == 0: return
	var counter = 0
	icons = get_tree().get_nodes_in_group("icon_button")
	for icon in icons:
		if icon.is_activ: 
			counter += 1
			GameData.fighter_dictionaries[icon.id]["imun"] += imun
			icon.set_icon_up_via_dictionary(GameData.fighter_dictionaries[icon.id])
			var text = "[color=yellow]" + GameData.fighter_dictionaries[icon.id]["name"] + "[/color] receives immunity.\n\n"
			GameData.immunity_queue.push_back(text)
			icon.switch_button()
	if counter != 0: 
		$label/hint_3.text = "Immunity points have been added."
		$animation.play("text_popup")


func _on_add_death_pressed():
	if GameData.is_over:
		$label/hint_3.text = "The games are over, you can no\nlonger buy anything in the shop."
		$animation.play("text_popup")
		return
	
	var death_icons = Array()
	icons = get_tree().get_nodes_in_group("icon_button")
	for icon in icons:
		if icon.is_activ: death_icons.push_back(icon)
	var death_allow = GameData.member_number - GameData.winner_number - GameData.death_counter - death_icons.size() > -1
	if death_allow:
		var counter = 0
		while (counter < death_icons.size()):
			GameData.fighter_dictionaries[death_icons[counter].id]["alive"] = false
			GameData.add_fallen_fighter(death_icons[counter].id)
			GameData.fighter_dictionaries[death_icons[counter].id] =  $player.set_death(GameData.fighter_dictionaries[death_icons[counter].id])
			var text = "[color=purple]" + GameData.fighter_dictionaries[death_icons[counter].id]["name"] + "[/color] died due to a trap.\n\n"
			GameData.trap_queue.push_back(text)
			death_icons[counter].queue_free()
			counter += 1
		if counter != 0: 
			$label/hint_3.text = "The selected tributes have been terminated."
			$animation.play("text_popup")
	else:
		var too_much = (GameData.member_number - GameData.winner_number - GameData.death_counter - death_icons.size())*-1
		$label/hint_3.text = "You have selected "+ str(too_much) + " tributes too many."
		$animation.play("text_popup")
		
		
	if !GameData.alive_fighter.has(current_fav): set_popular_tribut()


func _on_exit_pressed():
	self.visible = false
	


func _on_add_items_mouse_entered():
	$label/add_item_points.bbcode_text = "[color=yellow]" + "Add item points" + "[/color]"


func _on_add_items_mouse_exited():
	$label/add_item_points.bbcode_text =  "Add item points"


func _on_add_immun_mouse_entered():
	$label/add_imun.bbcode_text = "[color=yellow]" + "Add" + "[/color]"


func _on_add_immun_mouse_exited():
	$label/add_imun.bbcode_text  =  "Add"


func _on_add_death_mouse_entered():
	$label/add_dead.bbcode_text  = "[color=yellow]" + "Kill" + "[/color]"


func _on_add_death_mouse_exited():
	$label/add_dead.bbcode_text  =  "Kill"
