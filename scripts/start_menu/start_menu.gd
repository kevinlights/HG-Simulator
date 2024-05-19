extends Control



func _ready():
	if !GameData.first_start:
		OS.center_window() #-> For Desktop only.
		GameData.first_start = true
	

func _on_start_pressed():
	$szene_changer.visible = true
	GameData.last_menu_id = 0
	$szene_changer.change_szene("res://nodes/menu/option_menu/player_menu.tscn")


func _on_load_pressed():
	$szene_changer.visible = true
	GameData.last_menu_id = 0
	$szene_changer.change_szene("res://nodes/menu/save_menu/save_menu.tscn")


func _on_edit_events_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit(0)


func _on_start_mouse_entered():
	$text/start.bbcode_text =  "[color=yellow]" + "New Game" + "[/color]"


func _on_start_mouse_exited():
	$text/start.bbcode_text = "New Game"


func _on_load_mouse_entered():
	$text/load.bbcode_text  =  "[color=yellow]" + "Load Game" + "[/color]"


func _on_load_mouse_exited():
	$text/load.bbcode_text  = "Load Game"


func _on_edit_events_mouse_entered():
	$text/edit_events.bbcode_text =  "[color=yellow]" + "Edit events" + "[/color]"


func _on_edit_events_mouse_exited():
	$text/edit_events.bbcode_text = "Edit events"


func _on_quit_mouse_entered():
	$text/quit.bbcode_text  =  "[color=yellow]" + "Quit game" + "[/color]"


func _on_quit_mouse_exited():
	$text/quit.bbcode_text  = "Quit game"
