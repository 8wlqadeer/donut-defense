extends Control
#when you press the back button, you go to the menu
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
