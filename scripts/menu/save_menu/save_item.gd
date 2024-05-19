extends TextureRect


signal play_animation(text)
var file_name = ""
const main_p = "user://"


func set_up_save()->void:
	var data = SaveData.save_GameData()
	$overlay/date.text = "Date:\n" + data["time_string"]
	$overlay/status.text = "Game status:\n" + str(data["save_text"])
	file_name = data["file_name"]
	$save_item_plus.visible = false
	$overlay.visible = true
	
	
func load_a_save(file_path:String)->void:
	var data = SaveData.dry_load_GameData(file_path)
	$overlay/date.text = "Date:\n" + data["time_string"]
	$overlay/status.text = "Game status:\n" + str(data["save_text"])
	file_name = data["file_name"]
	$save_item_plus.visible = false
	$overlay.visible = true
	

func _on_b_overwrite_pressed():
	var data = SaveData.overwrite_file(file_name)
	$overlay/date.text = "Date:\n" + data["time_string"]
	$overlay/status.text = "Game status:\n" + str(data["save_text"])
	file_name = data["file_name"]
	emit_signal("play_animation", "Save was overwritten\nsuccessfully.")


func _on_b_delete_pressed():
	var dir = Directory.new()
	dir.remove(main_p + "/saves/" + file_name)
	emit_signal("play_animation", "Save was deleted\nsuccessfully.")
	self.queue_free()


func _on_b_load_pressed():
	var data = SaveData.load_GameData(file_name)
	$overlay/date.text = "Date:\n" + data["time_string"]
	$overlay/status.text = "Game status:\n" + str(data["save_text"])
	file_name = data["file_name"]
	$save_item_plus.visible = false
	$overlay.visible = true
	emit_signal("play_animation", "Save was loaded\nsuccessfully.")


func _on_b_overwrite_mouse_entered():
	$overlay/l_overwrite.bbcode_text =  "[color=yellow]" + "overwrite" + "[/color]"


func _on_b_overwrite_mouse_exited():
	$overlay/l_overwrite.bbcode_text =  "overwrite" 


func _on_b_delete_mouse_entered():
	$overlay/l_delete.bbcode_text =  "[color=yellow]" + "delete" + "[/color]"


func _on_b_delete_mouse_exited():
	$overlay/l_delete.bbcode_text = "delete"


func _on_b_load_mouse_entered():
	$overlay/l_load.bbcode_text =  "[color=yellow]" + "load" + "[/color]"


func _on_b_load_mouse_exited():
	$overlay/l_load.bbcode_text =  "load" 
