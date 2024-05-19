extends Control
class_name szene_changer

signal szene_changed
var scene


func change_szene(new_szene):
	scene = new_szene
	$AnimationPlayer.play("fade_out")
	
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		emit_signal("szene_changed")
		get_tree().change_scene(scene)
		$AnimationPlayer.play("fade_in")
	
