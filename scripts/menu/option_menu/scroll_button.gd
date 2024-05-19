extends TextureRect

var id = 0
var type = 0

signal scroll_button_pressed(id, type)

func _ready():
	pass # Replace with function body.

func set_up_scroll_button(_id,_type, text):
	id = _id
	type = _type
	$text.text = text
	

func _on_button_pressed():
	emit_signal("scroll_button_pressed", id, type)
