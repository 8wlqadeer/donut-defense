extends Control

#When back button is pressed, switches to the game scene
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
#When a value on the volume slider is changed, the volume of the game changes accordingly
func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,value/5)
#When the mute textbox is toggled, the game will be muted
func _on_check_box_toggled(toggled_on):
	AudioServer.set_bus_mute(0,toggled_on)
#This changes the resolutions, if option 0 of the option box is selected, the resolution becomes 1920,1080, and 
#so on and so forth
func _on_resolutions_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))

func _on_highscore_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/Highscore.tscn")
	
