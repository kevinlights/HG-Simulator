extends Node2D


const main_p = "user://"
const save_key = "7640hwhlksC1bshsa13wms"
const event_key = "fDmah3622qanyh37sdf24"

func _ready():
	var dir = Directory.new()
	if !dir.dir_exists(main_p + "/saves"): dir.make_dir_recursive(main_p + "/saves")
	if !dir.dir_exists(main_p + "/events"): dir.make_dir_recursive(main_p + "/events")
	if !dir.file_exists(main_p + "fighter.dat"):
		var data = {}
		var player := {}
		player["id"] = 0
		player["name"] = "Name"
		player["gender"] = 0
		player["hunger"] = 100
		player["thirst"] =  100
		player["health"] =  100
		player["M_HUNGER"] = 100
		player["M_THIRST"] = 100
		player["M_HEALTH"] = 100
		player["food"] = 0
		player["water"] = 0
		player["healItem"] = 0
		player["kills"] = 0
		player["injury"] = 0
		player["group"] = 0
		player["imun"] = 0
		player["alive"] = true
		player["near_death"] = false
		data["player"] = [player, player]
		var file = File.new()
		file.open(main_p + "fighter.dat",2)
		file.store_var(data)
		file.close()
	
	
func save_GameData()->Dictionary:
	var file = File.new()
	var counter = 0
	var time = OS.get_datetime()
	var minute = time["minute"]
	if minute < 10: minute = "0" + str(time["minute"])
	else: minute = str(time["minute"])
	var time_string = str(time["year"]) + "-" + str(time["month"]) + "-" + str(time["day"]) + " | " + str(time["hour"]) + ":" + minute
	var save_text = "Tributes: " + str(GameData.member_number) + " | Fallen tributes: " + str(GameData.death_counter)
	
	var file_name = "save_" +str(GameData.member_number) + str(GameData.death_counter) + str(time["year"]) + str(time["month"]) + str(time["day"])
	while file.file_exists(file_name):
		file_name = "save_" +str(GameData.member_number) + str(GameData.death_counter) + str(time["year"]) + str(time["month"]) + str(time["day"]) + str(counter)
		counter += 1
	
	file_name += ".dat"
	
	var data = {}
	data["member_size"] = GameData.member_number
	data["time_string"] = time_string
	data["save_text"] = save_text
	data["file_name"] = file_name
	data["day"] = GameData.day
	data["daytime"] = GameData.daytime
	data["death_risk"] = GameData.death_risk
	data["winner"] = GameData.winner_number
	data["is_over"] = GameData.is_over
	data["arena_events_there"] = GameData.are_there_arena_events
	data["group_modus"] = GameData.group_modus
	data["group_names"] = GameData.group_names
	data["water_points"] = GameData.water_points_per_day
	data["food_points"] = GameData.food_points_per_day
	data["fighter"] = GameData.fighter_dictionaries
	data["alive_fighter"] = GameData.alive_fighter
	data["dead_fighter"] = GameData.dead_fighter
	data["activ_fighter"] = GameData.activ_fighter
	data["imun_fighter"] = GameData.imun_fighter
	data["imun_queue"] = GameData.immunity_queue
	data["corn_fighter"] = GameData.cornucopia_fighter
	data["event_queue"] = GameData.event_queue
	data["trap_queue"] = GameData.trap_queue
	data["item_queue"] = GameData.item_queue
	data["death_counter"] = GameData.death_counter
	file.open_encrypted_with_pass(main_p + "/saves/" + file_name,2, save_key)
	file.store_var(data)
	file.close()
	return data

func overwrite_file(file_name:String)->Dictionary:
	var dir = Directory.new()
	dir.remove(main_p + "/saves/" + file_name)
	var data = save_GameData()
	return data


func dry_load_GameData(file_name:String)-> Dictionary:
	var file = File.new()
	file.open_encrypted_with_pass(main_p + "/saves/" + file_name,1, save_key)
	var data = file.get_var()
	file.close()
	return data
	

func load_GameData(file_name:String)->Dictionary:
	var file = File.new()
	file.open_encrypted_with_pass(main_p + "/saves/" + file_name,1, save_key)
	var data = file.get_var()
	file.close()
	
	GameData.member_number = data["member_size"] 
	GameData.day = data["day"] 
	GameData.daytime = data["daytime"] 
	GameData.death_risk = data["death_risk"]
	GameData.winner_number = data["winner"]
	GameData.is_over = data["is_over"]
	GameData.are_there_arena_events = data["arena_events_there"]
	GameData.group_modus = data["group_modus"]
	GameData.group_names = data["group_names"]
	GameData.water_points_per_day = data["water_points"]
	GameData.food_points_per_day = data["food_points"]
	GameData.fighter_dictionaries = data["fighter"]
	GameData.alive_fighter = data["alive_fighter"]
	GameData.dead_fighter = data["dead_fighter"]
	GameData.activ_fighter = data["activ_fighter"] 
	GameData.imun_fighter = data["imun_fighter"]
	GameData.immunity_queue = data["imun_queue"]
	GameData.cornucopia_fighter = data["corn_fighter"]
	GameData.event_queue = data["event_queue"]
	GameData.trap_queue = data["trap_queue"]
	GameData.item_queue = data["item_queue"]
	GameData.death_counter = data["death_counter"]
	
	return data

func get_all_save_files()->Array:
	var files = []
	var dir = Directory.new()
	if dir.open(main_p + "/saves/") == OK:
		dir.list_dir_begin(true,true)
		var file = dir.get_next()
		while !file.empty():
			files.push_back(file)
			file = dir.get_next()
		dir.list_dir_end()
	return files

