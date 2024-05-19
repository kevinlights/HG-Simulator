extends TextureRect

signal delete_icon(id)
signal need_new_icon(id)

var id = 0

var gender = ["Male", "Female", "Non binary"]
var gender_number = 0
var group_number = 0
var hunger_points = 100
var thirst_points = 100
var health_points = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	var counter = 0
	var icons = Array()

	while counter < gender.size():
		var node = load("res://nodes/menu/option_menu/scroll_button.tscn")
		var icon = node.instance()
		icon.set_up_scroll_button(counter,0,gender[counter])
		icon.connect("scroll_button_pressed", self, "update_scroll_button")
		$char/gender_scroll/vbox.add_child(icon)
		counter += 1
		
	counter = 0
	while counter < GameData.group_names.size():
		var node = load("res://nodes/menu/option_menu/scroll_button.tscn")
		var icon = node.instance()
		icon.set_up_scroll_button(counter,1,GameData.group_names[counter])
		icon.connect("scroll_button_pressed", self, "update_scroll_button")
		$char/group_scroll/vbox.add_child(icon)
		counter += 1


func set_up_icon_via_fighter(player:Dictionary):
	id = player["id"]
	update_scroll_button(player["gender"], 0)
	update_scroll_button(player["group"], 1)
	hunger_points = player["hunger"]
	$char/hunger_points.text = str(hunger_points)
	thirst_points = player["thirst"]
	$char/thirst_points.text = str(thirst_points)
	health_points = player["health"] 
	$char/health_points.text = str(health_points)
	$char/name.text = player["name"] 
	$add.visible = false
	$char.visible = true
	$x_button.visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update_scroll_button(id, type):
	if type == 0:
		$char/gender_scroll.visible = false
		$char/gender_text.visible = true
		$char/gender_button.visible = true
		gender_number = id
		$char/gender_text.text = gender[id]
	else:
		$char/group_scroll.visible = false
		$char/group_text.visible = true
		$char/group_button.visible = true
		group_number = id
		$char/group_text.text = GameData.group_names[id]

func _on_gender_button_pressed():
	$char/gender_scroll.visible = true
	$char/gender_text.visible = false
	$char/gender_button.visible = false


func _on_group_button_pressed():
	$char/group_scroll.visible = true 
	$char/group_text.visible = false
	$char/group_button.visible = false


func _on_hunger_points_focus_exited():
	if $char/hunger_points.text.is_valid_integer():
		var number = int($char/hunger_points.text)
		if number < 2: number = 2
		if number > 99999: number = 99999
		hunger_points = number
	$char/hunger_points.text = str(hunger_points)


func _on_thirst_points_focus_exited():
	if $char/thirst_points.text.is_valid_integer():
		var number = int($char/thirst_points.text)
		if number < 2: number = 2
		if number > 99999: number = 99999
		thirst_points = number
	$char/thirst_points.text = str(thirst_points)


func _on_health_points_focus_exited():
	if $char/health_points.text.is_valid_integer():
		var number = int($char/health_points.text)
		if number < 2: number = 2
		if number > 99999: number = 99999
		health_points = number
	$char/health_points.text = str(health_points)
	
func get_icon_information()->Array:
	var result = Array()
	result.push_back($char/name.text)
	result.push_back(gender_number)
	result.push_back(hunger_points)
	result.push_back(thirst_points)
	result.push_back(health_points)
	result.push_back(group_number)
	
	return result
	

func _on_x_button_pressed():
	emit_signal("delete_icon", id)
	
func set_up():
	$add.visible = false
	$char.visible = true
	$x_button.visible = true
	
func turn_back():
	$add.visible = true
	$char.visible = false
	$x_button.visible = false
	
	
func _on_add_button_pressed():
	$add.visible = false
	$char.visible = true
	$x_button.visible = true
	emit_signal("need_new_icon", id)
