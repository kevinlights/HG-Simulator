extends TextureRect


"""
This node is an icon that indicates the status of a fighter.
"""


func set_icon_up_via_dictionary(player:Dictionary) ->void:
	if player["alive"]: 
		$name.bbcode_text = "[color=yellow]" + player["name"] + "[/color]" + "\n"
		$status.text = "Status: Alive"
	else: 
		$name.bbcode_text = "[color=purple]" + player["name"] + "[/color]" + "\n"
		$status.text = "Status: Dead"
	
	$name.bbcode_text += "Gender: " + ["Male", "Female", "Non binary"][player["gender"]] + "\n"
	$name.bbcode_text +=  "Group: " + GameData.group_names[player["group"]]  + "\n"
	if player["kills"] > 0:  $name.bbcode_text += "Kills: " + str( player["kills"]) + "\n"
	if player["food"] > 0: $name.bbcode_text += "Food item points: " + str(player["food"]) + "\n"
	if player["water"] > 0: $name.bbcode_text += "Water item points: " + str(player["water"]) + "\n"
	if player["healItem"] > 0: $name.bbcode_text += "Health item points: " + str(player["healItem"]) + "\n"
	if player["injury"]  > 0: $name.bbcode_text += "Injury points: " + str(player["injury"]) + "\n"
	if player["imun"] > 0: $name.bbcode_text += "Immunity in daytimes: " + str(player["imun"])
	
	
	$hunger.text = "Hunger: " + str(player["hunger"])
	$health.text = "Health: " + str(player["health"])
	$thirst.text = "Thirst: " + str(player["thirst"])


