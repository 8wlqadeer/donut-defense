extends Control

# when play button button is pressed, switches to the game scene
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

# when options button pressed, switches to options scene
func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/option_menu.tscn")

# when exit button pressed, quits the game
func _on_exit_pressed():
	get_tree().quit()
#when credits button pressed, switches to credits scene
func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/credits.tscn")

# when how to play pressed, goes to how to play scene
func _on_how_to_play_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/HowToPlay.tscn")
