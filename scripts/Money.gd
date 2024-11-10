extends Label
#references to label
@onready var money_label = $"."
#every frame, does change money function
func _process(delta):
	_change_money()
#shows money 
func _change_money():
	money_label.text = "Money: " + str(GameManaging.money)
