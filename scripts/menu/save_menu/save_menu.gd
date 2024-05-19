extends Control


func _ready():
	if GameData.last_menu_id == 0:
		$text/save.visible = false
		$buttons/save.visible = false
		
	var files = SaveData.get_all_save_files()
	for file in files:
		var node = load("res://nodes/menu/save_menu/save_item.tscn")
		var item = node.instance()
		item.connect("play_animation", self, "show_hint")
		item.load_a_save(file)
		$scroll/vbox.add_child(item)


func _on_save_pressed():
	var node = load("res://nodes/menu/save_menu/save_item.tscn")
	var item = node.instance()
	item.connect("play_animation", self, "show_hint")
	item.set_up_save()
	$scroll/vbox.add_child(item)
	

func show_hint(text):
	$text/hint.text = text
	$text/ani.play("show_hint")

func _on_back_pressed():
	$szene_changer.visible = true
	var number = GameData.last_menu_id
	GameData.last_menu_id = 1
	match number:
		0: 
			if GameData.fighter_dictionaries.empty(): $szene_changer.change_szene("res://nodes/menu/start_menu/start_menu.tscn")
			else: $szene_changer.change_szene("res://nodes/menu/play_menu/playmenu.tscn")
		1: $szene_changer.change_szene("res://nodes/menu/save_menu/save_menu.tscn")
		2: $szene_changer.change_szene("res://nodes/menu/play_menu/playmenu.tscn")
	


func _on_back_mouse_entered():
	$text/back.bbcode_text = "[color=yellow]" + "Back" + "[/color]"


func _on_back_mouse_exited():
	$text/back.bbcode_text = "Back"


func _on_save_mouse_entered():
	$text/save.bbcode_text =  "[color=yellow]" + "Create new save" + "[/color]"


func _on_save_mouse_exited():
	$text/save.bbcode_text = "Create new save"
