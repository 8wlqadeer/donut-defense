extends Control

var highscore:int = 0
#when you press the back button, you go to the menu
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")

func _process(delta):
	if GameManaging.score > highscore:
		highscore = GameManaging.score
	else:
		pass
	$MarginContainer/VBoxContainer/Highscore.text = "Highscore: " + str(highscore)
